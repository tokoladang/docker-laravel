FROM php:8.5-cli-alpine

ARG REDIS_VERSION=6.3.0 \
    SWOOLE_VERSION=6.2.3

ENV ENABLE_SERVER=1 \
    ENABLE_WORKER=0 \
    # for development only
    ENABLE_AUTORELOAD=0 \
    TZ=Asia/Jakarta

RUN set -ex; \
    \
    apk update && \
    apk add --no-cache \
    inotify-tools \
    tzdata \
    libpq \
    libstdc++ \
    tini \
    su-exec

# Install dependencies
RUN set -ex; \
    \
    curl -sfL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    chmod +x /usr/bin/composer                                                                     && \
    composer self-update --clean-backups && \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        libtool \
        linux-headers \
        pcre2-dev \
        postgresql-dev \
        zlib-dev \
    ; \
    \
    docker-php-ext-install -j$(nproc) pcntl pdo_pgsql sockets; \
    pecl install redis-${REDIS_VERSION}; \
    docker-php-ext-enable redis; \
    docker-php-source extract && \
    mkdir /usr/src/php/ext/swoole && \
    curl -sfL https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz -o swoole.tar.gz && \
    tar xfz swoole.tar.gz --strip-components=1 -C /usr/src/php/ext/swoole && \
    docker-php-ext-install -j$(nproc) swoole && \
    rm -f swoole.tar.gz $HOME/.composer/*-old.phar && \
    docker-php-source delete && \
    apk del .build-deps

RUN addgroup -g 1000 -S ladang && \
    adduser -s /bin/sh -D -u 1000 -S ladang -G ladang && \
    mkdir /home/ladang/app && \
    chown ladang:ladang /home/ladang/app

COPY ./rootfilesystem/ /

ENV OCTANE_WORKER=auto

WORKDIR /home/ladang/app

EXPOSE 8000

ENTRYPOINT ["/sbin/tini", "-g", "--", "/entrypoint.sh"]
CMD ["app"]
