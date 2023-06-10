#!/bin/bash

kill_port_80() {
    pids=$(sudo lsof -t -i :80)
    if [ -z "$pids" ]; then
        echo "No processes found running on port 80."
    else
        for pid in $pids; do
            echo "Killing process with PID $pid running on port 80."
            sudo kill $pid
        done
    fi
}

sudo rm -r /etc/nginx/sites-available/default

DOMAIN_NAME=""

# Ask for the domain name first
if [ ! -z "$1" ]; then
  DOMAIN_NAME="$1"
else
  read -p "Enter domain name e.g. api.pagebunnii.com (leave empty if not using domain name): " DOMAIN_NAME
fi

# Get the latest PHP version number
PHP_VERSION=$(sudo apt-cache search php | grep -oP 'php\d\.\d' | sort -V | tail -n 1)

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

sudo nginx -t
sudo systemctl status nginx

# Kill processes running on port 80 before restarting Nginx
kill_port_80

sudo systemctl restart nginx
sudo systemctl status nginx
sudo certbot --nginx
