FROM php:8.1-cli-alpine3.15

RUN \
    curl -sfL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    chmod +x /usr/bin/composer                                                                     && \
    composer self-update --clean-backups 2.2.6                                    && \
    apk update && \
    apk add --no-cache \
    tzdata \
    libzip \
    libpq \
    unzip \
    libstdc++ \
    supervisor

ENV TZ Asia/Jakarta

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
    ; \
    \
    docker-php-ext-install pcntl exif bz2 opcache zip bcmath pdo_pgsql sockets; \
    pecl install redis; \
    docker-php-ext-enable redis; \
    docker-php-source extract && \
    mkdir /usr/src/php/ext/swoole && \
    curl -sfL https://github.com/swoole/swoole-src/archive/master.tar.gz -o swoole.tar.gz && \
    tar xfz swoole.tar.gz --strip-components=1 -C /usr/src/php/ext/swoole && \
    docker-php-ext-configure swoole \
        --enable-http2   \
        --enable-swoole-pgsql \
        --enable-openssl \
        --enable-sockets --enable-swoole-curl --enable-swoole-json && \
    docker-php-ext-install -j$(nproc) swoole && \
    rm -f swoole.tar.gz $HOME/.composer/*-old.phar && \
    docker-php-source delete && \
    apk del .build-deps

RUN addgroup -g 1000 -S ladang && \
    adduser -s /bin/sh -D -u 1000 -S ladang -G ladang && \
    mkdir /home/ladang/app && \
    chown ladang:ladang /home/ladang/app

COPY etc /etc

COPY entrypoint.sh /entrypoint.sh
RUN chmod u+rwx /entrypoint.sh

WORKDIR /home/ladang/app

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD ["app"]
