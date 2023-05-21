#!/bin/bash

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

sudo rm -r setup-server.sh
