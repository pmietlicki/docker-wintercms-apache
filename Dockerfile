# Use PHP 8.2 with Apache as the base image
FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
  cron git-core jq unzip vim zip \
  && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN apt-get update && apt-get install -y \
  libjpeg-dev libpng-dev libpq-dev libsqlite3-dev libwebp-dev libzip-dev \
  && docker-php-ext-configure zip --with-zip \
  && docker-php-ext-configure gd --with-jpeg --with-webp \
  && docker-php-ext-install exif gd mysqli opcache pdo_pgsql pdo_mysql zip \
  && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install and enable Redis extension
RUN pecl install -o -f redis \
  && rm -rf /tmp/pear \
  && docker-php-ext-enable redis

# Configure PHP opcache settings
RUN echo 'opcache.memory_consumption=128\nopcache.interned_strings_buffer=8\nopcache.max_accelerated_files=4000\nopcache.revalidate_freq=2\nopcache.fast_shutdown=1\nopcache.enable_cli=1' \
  > /usr/local/etc/php/conf.d/docker-oc-opcache.ini

# Configure additional PHP settings
RUN echo 'log_errors=on\ndisplay_errors=off\nupload_max_filesize=32M\npost_max_size=32M\nmemory_limit=128M' \
  > /usr/local/etc/php/conf.d/docker-oc-php.ini

# Allow Composer to run as root
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install Composer with prestissimo for faster package installs
RUN curl -sS https://getcomposer.org/installer | php -- --1 --install-dir=/usr/local/bin --filename=composer \
  && /usr/local/bin/composer global require hirak/prestissimo

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set environment variables
ENV WINTERCMS_TAG v1.2.3
ENV DB_CONNECTION sqlite
ENV DB_DATABASE storage/database.sqlite

# Set up volume for persistent storage
VOLUME ["/var/www/html"]

# Set permissions for web server
RUN chown -R www-data:www-data /var/www/html

# Set group write permissions for specific directories
RUN find . -type d \( -path './plugins' -or  -path './storage' -or  -path './themes' -or  -path './plugins/*' -or  -path './storage/*' -or  -path './themes/*' \) -exec chmod g+ws {} \;

# Set up cron for artisan schedule
RUN echo "* * * * * /usr/local/bin/php /var/www/html/artisan schedule:run > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/winter-cron && \
  crontab /etc/cron.d/winter-cron

# Create bash scripts for artisan, tinker, and winter
RUN echo 'exec php artisan "$@"' > /usr/local/bin/artisan && \
  echo 'exec php artisan tinker' > /usr/local/bin/tinker && \
  echo '[ $# -eq 0 ] && exec php artisan winter || exec php artisan winter:"$@"' > /usr/local/bin/winter && \
  sed -i '1s;^;#!/bin/bash\n[ "$PWD" != "/var/www/html" ] \&\& echo " - Helper must be run from /var/www/html" \&\& exit 1\n;' /usr/local/bin/artisan /usr/local/bin/tinker /usr/local/bin/winter && \
  chmod +x /usr/local/bin/artisan /usr/local/bin/tinker /usr/local/bin/winter

# Copy the installation script and make it executable
COPY install-winter-cms.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/install-winter-cms.sh

# Copy the entrypoint script and make it executable
COPY docker-wn-entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-wn-entrypoint

# Define entrypoint and command
ENTRYPOINT ["docker-wn-entrypoint"]
CMD ["apache2-foreground"]