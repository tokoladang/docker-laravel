FROM php:8.0-cli-alpine3.12

# RUN \
#     curl -sfL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
#     chmod +x /usr/bin/composer                                                                     && \
#     composer self-update --clean-backups 2.0.8                                    && \
#     apk update && \
#     apk add --no-cache \
#     tzdata \
#     nginx \
#     libzip \
#     libpng \
#     libwebp \
#     libjpeg-turbo \
#     libxpm \
#     freetype \
#     postgresql-libs \
#     unzip \
#     libstdc++ \
#     supervisor

# ENV TZ Asia/Jakarta

# # Install dependencies
# RUN set -ex; \
#     \
#     apk add --no-cache --virtual .build-deps \
#         $PHPIZE_DEPS \
#         bzip2-dev \
#         freetype-dev \
#         libjpeg-turbo-dev \
#         libpng-dev \
#         libtool \
#         libwebp-dev \
#         libxpm-dev \
#         libzip-dev \
#         pcre-dev \
#         postgresql-dev \
#         zlib-dev \
#         curl-dev \
#         openssl-dev \
#         pcre2-dev \
#     ; \
#     \
#     docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp --with-xpm; \
#     docker-php-ext-install pcntl exif bz2 gd opcache zip bcmath pdo_pgsql sockets; \
#     pecl install redis; \
#     docker-php-ext-enable redis; \
#     docker-php-source extract && \
#     mkdir /usr/src/php/ext/swoole && \
#     curl -sfL https://github.com/swoole/swoole-src/archive/master.tar.gz -o swoole.tar.gz && \
#     tar xfz swoole.tar.gz --strip-components=1 -C /usr/src/php/ext/swoole && \
#     docker-php-ext-configure swoole \
#         --enable-http2   \
#         --enable-openssl \
#         --enable-swoole-curl --enable-swoole-json && \
#     docker-php-ext-install -j$(nproc) swoole && \
#     rm -f swoole.tar.gz $HOME/.composer/*-old.phar && \
#     docker-php-source delete && \
#     apk del .build-deps

# RUN addgroup -g 1000 -S ladang && \
#     adduser -s /bin/sh -D -u 1000 -S ladang -G ladang && \
#     mkdir /home/ladang/app && \
#     chown ladang:ladang /home/ladang/app

# COPY etc /etc

COPY run.sh /run.sh
# RUN chmod u+rwx /run.sh

# COPY --chown=ladang:ladang index.php /home/ladang/app/public/index.php

# WORKDIR /home/ladang/app

# EXPOSE 80

# ENTRYPOINT ["/run.sh"]
# CMD ["app"]
