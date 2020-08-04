FROM php:7.2-apache
RUN a2enmod rewrite expires
COPY default-ssl.conf /etc/apache2/sites-available/
COPY apache2-foreground /usr/local/bin/
RUN chmod +x /usr/local/bin/apache2-foreground
RUN set -eux; apt-get update; apt-get install -y libzip-dev zlib1g-dev libpng-dev sendmail cron git-core libjpeg62-turbo-dev
RUN docker-php-ext-install pdo pdo_mysql zip mbstring
RUN docker-php-ext-configure gd --with-jpeg-dir=/usr \
  && docker-php-ext-install -j "$(nproc)" gd
RUN apt-get install -y certbot
RUN curl -sS https://getcomposer.org/installer | php \
  && chmod +x composer.phar && mv composer.phar /usr/local/bin/composer \
  && composer global require hirak/prestissimo --no-plugins --no-scripts
COPY --chown=www-data:www-data src /var/www/html
RUN chmod a+w /var/www/html/bootstrap/cache
RUN chmod -R a+w /var/www/html/storage
RUN chmod -R a+w /var/www/html/public/uploads
COPY cronjobs /etc/cron.d/

WORKDIR /var/www/html
# Convendria usar --no-dev --prefer-dist ?
RUN composer install
#Convendria hacer RUN php artisan config:cache ?
RUN chown -R www-data:www-data .

EXPOSE 80
EXPOSE 443
