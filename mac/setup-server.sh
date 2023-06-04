#!/bin/bash

# Set default values
BACKUP_SERVER=""
MYSQL_DATABASE=""
MYSQL_USER=""
MYSQL_PASSWORD=""
DOMAIN_NAME=""

# Ask for the domain name first
if [ ! -z "$1" ]; then
  DOMAIN_NAME="$1"
else
  read -p "Enter domain name e.g. api.pagebunnii.com (leave empty if not using domain name): " DOMAIN_NAME
fi

# Ask if the user wants to use the domain name for the MYSQL_DATABASE and MYSQL_USER values
if [ ! -z "$DOMAIN_NAME" ]; then
  read -p "Do you want to use your domain name for the database name and user? (y/n): " USE_DOMAIN_NAME
  if [ "$USE_DOMAIN_NAME" == "y" ]; then
    MYSQL_DATABASE=$(echo "$DOMAIN_NAME" | sed 's/https\?:\/\///' | sed 's/\..*//')
    MYSQL_USER="$MYSQL_DATABASE-user"
  fi
fi

# Check if command line arguments are provided for the other values
if [ ! -z "$2" ]; then
  MYSQL_DATABASE="$2"
else
  if [ -z "$MYSQL_DATABASE" ]; then
    read -p "Enter database name: " MYSQL_DATABASE
  fi
fi

if [ ! -z "$3" ]; then
  MYSQL_USER="$3"
else
  if [ -z "$MYSQL_USER" ]; then
    read -p "Enter database user: " MYSQL_USER
  fi
fi

if [ ! -z "$4" ]; then
  MYSQL_PASSWORD="$4"
else
  read -p "Do you want to use your own password or generate a new one? (own/generate): " PASSWORD_CHOICE
  if [ "$PASSWORD_CHOICE" == "own" ]; then
    read -sp "Enter database password: " MYSQL_PASSWORD
    echo ""
  else
    # Generate a random password
    MYSQL_PASSWORD=$(LC_ALL=C </dev/urandom tr -dc 'a-zA-Z0-9!@#$%^&*()-_=+' | fold -w 16 | head -n 1)
    echo "Generated MySQL password: $MYSQL_PASSWORD"
  fi
fi

if [ ! -z "$5" ]; then
  BACKUP_SERVER="$5"
else
  read -p "Enter backup server username (leave empty if not using a backup server): " BACKUP_SERVER
fi

# Get the latest PHP version number
PHP_VERSION=$(sudo apt-cache search php | grep -oP 'php\d\.\d' | sort -V | tail -n 1)

echo -e "\n📦 Updating package list... \n"
# Updating package list
sudo apt update

echo -e "\n📦 Installing curl... \n"
# Installing curl
sudo apt install curl -y

echo -e "\n📦 Installing Node.js LTS version... \n"
# Installing Node.js LTS version
sudo curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

echo -e "\n✅ Checking Node.js and npm version... \n"
# Checking Node.js and npm version
sudo node --version
sudo npm --version

echo -e "\n📦 Installing latest version of PM2... \n"
# Installing latest version of PM2
sudo npm install pm2@latest -g

echo -e "\n📦 Installing Nginx... \n"
# Installing Nginx
sudo apt install nginx -y
sudo apt install software-properties-common -y
sudo apt install mysql-server -y
sudo apt install mysql-client -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt install "${PHP_VERSION}" -y
sudo apt install "${PHP_VERSION}-fpm" -y
sudo apt install "${PHP_VERSION}-mysql" -y

# Check if the domain name is provided
if [ -z "$DOMAIN_NAME" ]; then
  DOMAIN_NAME="localhost"
  REDIRECT_SERVER=""
else
  REDIRECT_SERVER="server {
    listen 80;
    server_name $(curl ifconfig.me);
    return 301 http://${DOMAIN_NAME};
  }"
fi

# Replace the document root in the Nginx configuration file
sudo bash -c "cat > /etc/nginx/sites-available/default" << EOL
server {
  listen 80 default_server;
  listen [::]:80 default_server;

  root /var/www/html;

  index index.php index.html index.htm index.nginx-debian.html;

  server_name ${DOMAIN_NAME};

  location / {
    proxy_pass http://localhost:3000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_cache_bypass \$http_upgrade;
    proxy_connect_timeout 600s;
    proxy_send_timeout 600s;
    proxy_read_timeout 600s;
  }

  location ~ \.php$ {
    include snippets/fastcgi-php.conf;

    fastcgi_pass unix:/var/run/php/${PHP_VERSION}-fpm.sock;
  }
}

${REDIRECT_SERVER}
EOL


# Create the database, user, and grant privileges
sudo mysql <<EOF
CREATE DATABASE $MYSQL_DATABASE DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'localhost';
GRANT SELECT, SHOW VIEW, RELOAD, REPLICATION CLIENT, LOCK TABLES, PROCESS ON *.* TO '$MYSQL_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

sudo systemctl restart nginx

sudo chown -R www-data:www-data /var/www

if [ ! -z "$BACKUP_SERVER" ]; then
  # Add your backup script here
  echo "Backup server is set up."
fi

echo -e "\n✅ Removing the setup script... \n"
# Removing the setup script

sudo mv /var/www/html/index.nginx-debian.html /var/www/html/index.html

curl -sSL https://raw.githubusercontent.com/cookii-king/express-api-setup/main/mac/create-ssl-certificate.sh -o create-ssl-certificate.sh && chmod +x create-ssl-certificate.sh && ./create-ssl-certificate.sh

curl -sSL https://raw.githubusercontent.com/cookii-king/express-api-setup/main/mac/create-express-api.sh -o create-express-api.sh && chmod +x create-express-api.sh && ./create-express-api.sh "$DOMAIN_NAME"

echo "Go to http://${DOMAIN_NAME:-$(curl ifconfig.me)} to view your Express Api. 😁"

sudo rm -r setup-server.sh
