FROM php:8.5-cli-alpine

ARG TARGETARCH

ARG REDIS_VERSION=6.3.0
ARG SWOOLE_VERSION=6.2.3
ARG OTEL_VERSION=0.7.0
ARG PROTOBUF_VERSION=5.36.2

ENV ENABLE_SERVER=1
ENV ENABLE_WORKER=0

# for development only
ENV ENABLE_AUTORELOAD=0

ENV OCTANE_WORKER=auto
ENV OCTANE_TASK_WORKER=auto
ENV OCTANE_MAX_REQUESTS=500

ENV TZ=Asia/Jakarta

RUN set -ex; \
    \
    apk update && \
    apk add --no-cache \
    inotify-tools \
    tzdata \
    libpq \
    libstdc++ \
    supervisor

# Install dependencies
RUN set -ex; \
    \
    curl -sfL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    chmod +x /usr/bin/composer                                                                     && \
    composer self-update --clean-backups && \
    case "$TARGETARCH" in \
      amd64) apk_arch=x86_64 ;; \
      arm64) apk_arch=aarch64 ;; \
      *) echo "Unsupported architecture: $TARGETARCH" >&2; exit 1 ;; \
    esac && \
    curl -sfL https://github.com/open-telemetry/opentelemetry-php-distro/releases/download/v${OTEL_VERSION}/opentelemetry-php-distro_${OTEL_VERSION}_${apk_arch}.apk -o /tmp/otel-distro.apk && \
    apk add --allow-untrusted --no-cache /tmp/otel-distro.apk && \
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
    pecl install protobuf-${PROTOBUF_VERSION}; \
    docker-php-ext-enable redis protobuf; \
    docker-php-source extract && \
    mkdir /usr/src/php/ext/swoole && \
    curl -sfL https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz -o swoole.tar.gz && \
    tar xfz swoole.tar.gz --strip-components=1 -C /usr/src/php/ext/swoole && \
    docker-php-ext-install -j$(nproc) swoole && \
    rm -f /tmp/otel-distro.apk swoole.tar.gz $HOME/.composer/*-old.phar && \
    docker-php-source delete && \
    apk del .build-deps

RUN addgroup -g 1000 -S ladang && \
    adduser -s /bin/sh -D -u 1000 -S ladang -G ladang && \
    mkdir /home/ladang/app && \
    chown ladang:ladang /home/ladang/app

COPY ./rootfilesystem/ /

ENV PHP_MEMORY_LIMIT=512M

WORKDIR /home/ladang/app

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["app"]
