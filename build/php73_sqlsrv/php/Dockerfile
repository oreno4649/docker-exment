FROM php:7.3-fpm
ARG LARAVEL_VERSION="6.*"
ARG EXMENT_VERSION="~4.0"

# install php-ext
RUN apt-get update && apt-get install -y git wget gnupg vim unzip libxml2-dev libpng-dev libzip-dev libonig-dev \
  && docker-php-ext-install mbstring dom gd zip \
  && apt-get clean


# Append ODBC Driver
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
  && curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list \
  && apt-get update \
  && apt-get install -y unixodbc-dev libgssapi-krb5-2 \
  && ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools


# install driver
RUN pecl install sqlsrv && pecl install pdo_sqlsrv && docker-php-ext-enable sqlsrv && docker-php-ext-enable pdo_sqlsrv


# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


# install exment
RUN mkdir /var/www/exment
WORKDIR /var/www/exment
