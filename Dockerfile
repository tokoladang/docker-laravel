FROM php:7.4-fpm-alpine3.12

RUN apk add --no-cache \
    nginx \
    imagemagick \
    libzip \
    libpng \
    libwebp \
    libjpeg-turbo \
    libxpm \
    freetype \
    postgresql-libs \
    unzip \
    supervisor

# Install dependencies
RUN set -ex; \
    \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        bzip2-dev \
        freetype-dev \
        imagemagick-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libtool \
        libwebp-dev \
        libxpm-dev \
        libzip-dev \
        pcre-dev \
        postgresql-dev \
        zlib-dev \
    ; \
    \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp --with-xpm; \
    docker-php-ext-install pcntl exif bz2 gd opcache zip bcmath pdo_pgsql pdo_mysql; \
    pecl install redis; \
    docker-php-ext-enable redis; \
    pecl install imagick; \
    docker-php-ext-enable imagick; \
    apk del .build-deps

RUN EXPECTED_COMPOSER_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig) && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '${EXPECTED_COMPOSER_SIGNATURE}') { echo 'Composer.phar Installer verified'; } else { echo 'Composer.phar Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \
    addgroup -g 1000 -S ladang && \
    adduser -s /bin/sh -D -u 1000 -S ladang -G ladang && \
    mkdir /home/ladang/app && \
    chown ladang:ladang /home/ladang/app


COPY etc /etc

COPY run.sh /run.sh
RUN chmod u+rwx /run.sh

COPY --chown=ladang:ladang index.php /home/ladang/app/public/index.php

WORKDIR /home/ladang/app

EXPOSE 443 80

ENTRYPOINT ["/run.sh"]
CMD ["app"]
