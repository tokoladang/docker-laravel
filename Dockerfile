FROM php:7.4-fpm-alpine3.12

RUN apk add --no-cache \
    nginx \
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
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libxpm-dev \
        libzip-dev \
        postgresql-dev \
        zlib-dev \
    ; \
    \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp --with-xpm; \
    docker-php-ext-install bz2 gd opcache zip bcmath pdo_pgsql; \
    pecl install redis-5.2.0; \
    docker-php-ext-enable redis; \
    apk del .build-deps

RUN EXPECTED_COMPOSER_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig) && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '${EXPECTED_COMPOSER_SIGNATURE}') { echo 'Composer.phar Installer verified'; } else { echo 'Composer.phar Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \
    addgroup -g 1000 -S tokoladang && \
    adduser -s /bin/sh -D -u 1000 -S tokoladang -G tokoladang && \
    mkdir /home/tokoladang/app && \
    chown tokoladang:tokoladang /home/tokoladang/app


COPY etc /etc

COPY run.sh /run.sh
RUN chmod u+rwx /run.sh

COPY --chown=tokoladang:tokoladang index.php /home/tokoladang/app/public/index.php

WORKDIR /home/tokoladang/app

EXPOSE 443 80

ENTRYPOINT ["/run.sh"]
CMD ["app"]