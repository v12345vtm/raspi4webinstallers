#!/bin/bash

set -e

#########################################
# Configuration and install in 1 cli command : wget -O- https://raw.githubusercontent.com/v12345vtm/raspi4webinstallers/main/cmsmadesimple.sh | bash
#########################################

 

echo "=========================================="
echo " CMS Made Simple Installer"
echo " Raspberry Pi 4"
echo "=========================================="

DB_NAME="cmsms"
DB_USER="cmsmsuser"
DB_PASS="cmsmspassword"

INSTALLER_URL="https://s3.amazonaws.com/cmsms/downloads/15249/cmsms-2.2.22-install.zip"

echo
echo "Updating system..."
sudo apt update
sudo apt -y upgrade

echo
echo "Installing required packages..."
sudo apt install -y \
apache2 \
mariadb-server \
php \
libapache2-mod-php \
php-mysql \
php-gd \
php-xml \
php-curl \
php-mbstring \
php-zip \
php-intl \
php-soap \
php-cli \
php-bcmath \
unzip \
wget

echo
echo "Starting services..."
sudo systemctl enable apache2 mariadb
sudo systemctl restart apache2
sudo systemctl restart mariadb

echo
echo "Creating database..."
sudo mysql <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

echo
echo "Preparing web root..."

sudo rm -rf /var/www/html/*
cd /var/www/html

echo
echo "Downloading CMS Made Simple installer..."
sudo wget -O cmsms-install.zip "$INSTALLER_URL"

echo
echo "Extracting installer..."
sudo unzip -o cmsms-install.zip

sudo rm cmsms-install.zip

sudo chown -R www-data:www-data /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;

IP=$(hostname -I | awk '{print $1}')

echo
echo "=========================================="
echo "Installation complete!"
echo
echo "Open:"
echo
echo "    http://${IP}/cmsms-2.2.22-install.php"
echo
echo "Database settings:"
echo
echo "Host:      localhost"
echo "Database:  ${DB_NAME}"
echo "User:      ${DB_USER}"
echo "Password:  ${DB_PASS}"
echo
echo "After installation, delete:"
echo "    /var/www/html/cmsms-2.2.22-install.php"
echo "=========================================="
