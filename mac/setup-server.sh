#!/bin/bash

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

  root /var/www/html/wordpress;

  index index.php index.html index.htm index.nginx-debian.html;

  server_name api.${DOMAIN_NAME};

  location / {
    proxy_pass http://localhost:3000;
    try_files \$uri \$uri/ /index.php?\$args;
  }

  location ~ \.php$ {
    include snippets/fastcgi-php.conf;

    fastcgi_pass unix:/var/run/php/${PHP_VERSION}-fpm.sock;
  }
}

${REDIRECT_SERVER}
EOL

echo -e "\n✅ Removing the setup script... \n"
# Removing the setup script

sudo mv /var/www/html/index.nginx-debian.html /var/www/html/index.html

curl -sSL https://raw.githubusercontent.com/cookii-king/express-api-setup/main/mac/create-ssl-certificate.sh -o create-ssl-certificate.sh && chmod +x create-ssl-certificate.sh && ./create-ssl-certificate.sh

echo "Go to http://${DOMAIN_NAME:-$(curl ifconfig.me)} to view your Express Api. 😁"

sudo rm -r setup-server.sh
