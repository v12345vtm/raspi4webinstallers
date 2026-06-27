#!/bin/bash

set -e

#########################################
# Configuration and install in 1 cli command : wget -O- https://raw.githubusercontent.com/v12345vtm/raspi4webinstallers/main/cmsmadesimple.sh | bash
#########################################

CMS_DB="cmsms"
CMS_USER="cmsmsuser"
CMS_PASS="cmsmspassword"

WEBROOT="/var/www/html"

#########################################

echo "Updating system..."
sudo apt update
sudo apt -y upgrade

echo "Installing Apache, MariaDB and PHP..."

sudo apt install -y \
apache2 \
mariadb-server \
wget \
unzip \
php \
libapache2-mod-php \
php-mysql \
php-gd \
php-xml \
php-curl \
php-zip \
php-mbstring \
php-intl \
php-soap \
php-cli \
php-json \
php-bcmath

echo "Enabling Apache..."
sudo systemctl enable apache2
sudo systemctl restart apache2

echo "Enabling MariaDB..."
sudo systemctl enable mariadb
sudo systemctl start mariadb

echo "Creating database..."

sudo mysql <<EOF

CREATE DATABASE IF NOT EXISTS ${CMS_DB};

CREATE USER IF NOT EXISTS '${CMS_USER}'@'localhost'
IDENTIFIED BY '${CMS_PASS}';

GRANT ALL PRIVILEGES
ON ${CMS_DB}.*
TO '${CMS_USER}'@'localhost';

FLUSH PRIVILEGES;

EOF

echo "Downloading CMS Made Simple..."

cd /tmp

LATEST=$(wget -qO- https://www.cmsmadesimple.org/downloads/latest)

wget -O cmsms.tar.gz "$LATEST"

sudo rm -rf ${WEBROOT:?}/*

sudo tar xzf cmsms.tar.gz

DIR=$(find . -maxdepth 1 -type d -name "cmsmadesimple*" | head -n1)

sudo cp -r "$DIR"/* "$WEBROOT"

sudo chown -R www-data:www-data "$WEBROOT"

sudo find "$WEBROOT" -type d -exec chmod 755 {} \;

sudo find "$WEBROOT" -type f -exec chmod 644 {} \;

echo "Creating upload directories..."

sudo mkdir -p "$WEBROOT/uploads"
sudo mkdir -p "$WEBROOT/tmp"
sudo mkdir -p "$WEBROOT/admin/tmp/cache"

sudo chown -R www-data:www-data "$WEBROOT/uploads"
sudo chown -R www-data:www-data "$WEBROOT/tmp"
sudo chown -R www-data:www-data "$WEBROOT/admin"

sudo systemctl restart apache2

IP=$(hostname -I | awk '{print $1}')

echo
echo "========================================="
echo
echo "CMS Made Simple installed."
echo
echo "Open:"
echo
echo "http://$IP"
echo
echo "Database:"
echo "  Database : $CMS_DB"
echo "  User     : $CMS_USER"
echo "  Password : $CMS_PASS"
echo
echo "Finish the installation in your browser."
echo
echo "========================================="
