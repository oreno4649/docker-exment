ARG PHP_VERSION

FROM php:${PHP_VERSION}-fpm

# install php-ext
RUN apt-get update && apt-get install -y git wget gnupg vim unzip libxml2-dev libpng-dev libzip-dev libonig-dev default-mysql-client\
  && docker-php-ext-install mbstring dom gd zip pdo_mysql\
  && apt-get clean \

RUN apt-get install -y default-mysql-client && docker-php-ext-install pdo_mysql
# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY .env /var/www/exment/.env
WORKDIR /var/www/exment