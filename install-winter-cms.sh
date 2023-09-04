#!/bin/bash

# Clone Winter CMS repository
git clone https://github.com/wintercms/winter -b $WINTERCMS_TAG --depth 1 .

# Run Composer install with no interaction, prefer dist, and no scripts
COMPOSER_MEMORY_LIMIT=-1 composer install --no-interaction --prefer-dist --no-scripts

# Clear Composer cache
composer clearcache

# Change owner to root temporarily
RUN chown -R root:root /var/www/html

# Check git status and checkout modules
git status && git checkout modules/.

# Remove git repository data
rm -rf .git

# Set group write permissions for specific directories
find . -type d \( -path './plugins' -or  -path './storage' -or  -path './themes' -or  -path './plugins/*' -or  -path './storage/*' -or  -path './themes/*' \) -exec chmod g+ws {} \;

# Generate a unique Laravel application key
php artisan key:generate

# Create and set permissions for SQLite database
touch /var/www/html/storage/database.sqlite
chmod 666 /var/www/html/storage/database.sqlite

# Run Laravel migrations to initialize the database schema
php artisan migrate

# Install winter CMS and drivers plugin
php artisan winter:install && php artisan plugin:install winter.drivers

# Initializing winter CMS
php artisan winter:up

echo 'Set ownership to www-data for /var/www/html'

# Set permissions for web server
chown -R www-data:www-data /var/www/html