FROM php:${PHP_VERSION}-fpm

# install php-ext
RUN apt-get update && apt-get install -y git wget gnupg vim unzip libxml2-dev libpng-dev libzip-dev libonig-dev \
  && docker-php-ext-install mbstring dom gd zip \
  && apt-get clean

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# install exment
RUN mkdir /var/www/exment
WORKDIR /var/www/exment