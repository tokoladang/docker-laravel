FROM php:8.1-cli-alpine3.15

ENV ENABLE_SERVER=1
ENV ENABLE_WORKER=0

# for development only
ENV ENABLE_AUTORELOAD=0

ENV TZ Asia/Jakarta

RUN \
    curl -sfL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    chmod +x /usr/bin/composer                                                                     && \
    composer self-update --clean-backups 2.2.6                                    && \
    apk update && \
    apk add --no-cache \
    inotify-tools \
    tzdata \
    libzip \
    libpq \
    freetype \
    libpng \
    libwebp \
    libjpeg-turbo \
    libxpm \
    unzip \
    libstdc++ \
    supervisor

# Install dependencies
RUN set -ex; \
    \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        bzip2-dev \
        curl-dev \
        libtool \
        libzip-dev \
        openssl-dev \
        pcre-dev \
        pcre2-dev \
        postgresql-dev \
        zlib-dev \
        libwebp-dev \
        libxpm-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
    ; \
    \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp --with-xpm; \
    docker-php-ext-install pcntl exif bz2 gd opcache zip bcmath pdo_pgsql sockets; \
    pecl install redis; \
    docker-php-ext-enable redis; \
    docker-php-source extract && \
    mkdir /usr/src/php/ext/openswoole && \
    curl -sfL https://github.com/openswoole/swoole-src/archive/v4.11.1.tar.gz -o swoole.tar.gz && \
    tar xfz swoole.tar.gz --strip-components=1 -C /usr/src/php/ext/openswoole && \
    docker-php-ext-configure openswoole \
        --enable-http2   \
        --enable-openssl \
        --enable-sockets --enable-swoole-curl --enable-swoole-json --with-postgres && \
    docker-php-ext-install -j$(nproc) --ini-name zzz-docker-php-ext-openswoole.ini openswoole && \
    rm -f swoole.tar.gz $HOME/.composer/*-old.phar && \
    docker-php-source delete && \
    apk del .build-deps

RUN addgroup -g 1000 -S ladang && \
    adduser -s /bin/sh -D -u 1000 -S ladang -G ladang && \
    mkdir /home/ladang/app && \
    chown ladang:ladang /home/ladang/app

COPY ./rootfilesystem/ /

WORKDIR /home/ladang/app

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["app"]
