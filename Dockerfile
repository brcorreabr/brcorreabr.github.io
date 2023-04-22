FROM php:8.2.5-apache

RUN apt-get update -y && apt-get upgrade -y

RUN docker-php-ext-install pdo pdo_mysql

RUN a2enmod rewrite
RUN a2enmod ssl

RUN DEBIAN_FRONTEND='noninteractive' apt-get update -y && apt-get upgrade -y && apt-get install wget -y --fix-missing --no-install-recommends \
        net-tools \
        iputils-ping \
        openssh-client \
        git \
        default-mysql-client \
        zip \
        gcc \
        vim \
        curl \
        unzip \
        build-essential \
        libxml2-dev \
        libcurl4-openssl-dev \
        pkg-config \
        libssl-dev \
        && docker-php-ext-install -j$(nproc) pdo_mysql gettext soap

RUN pecl install xdebug-3.2.0 && docker-php-ext-enable xdebug

RUN echo "xdebug.mode=develop" | tee -a /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini > /dev/null && \
    echo "xdebug.start_with_request=yes" | tee -a /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini > /dev/null && \
    echo "xdebug.client_host=host.docker.internal" | tee -a /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini > /dev/null && \
    echo "xdebug.var_display_max_data=-1" | tee -a /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini > /dev/null && \
    echo "xdebug.var_display_max_depth=-1" | tee -a /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini > /dev/null

# Geração de tokens RSA para OAuth 2.0
RUN mkdir /var/www/html/keys
WORKDIR /var/www/html/keys

RUN openssl genrsa -out private.key 2048

RUN openssl rsa -in private.key -pubout -out public.key

COPY docker-entrypoint /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT [ "docker-entrypoint" ]

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

WORKDIR /var/www/html

EXPOSE 80