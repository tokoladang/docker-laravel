FROM tokoladang/laravel:latest

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/bin/sh", "/docker-entrypoint.sh"]

CMD ["composer"]