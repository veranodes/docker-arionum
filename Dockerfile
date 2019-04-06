# Author: Cuong Tran
#
# Build: docker build -t veranodes/arionum:0.1 .
# Run: docker run -d -p 9000:9000 --name app-run veranodes/arionum:0.1
#

FROM php:7.2-fpm

LABEL maintainer="cuongtransc@gmail.com"

ENV REFRESHED_AT 2019-01-14

RUN apt-get update -qq
RUN apt-get install -y libfcgi-bin libgmp-dev
RUN docker-php-ext-install -j$(nproc) gmp

# Install PDO
RUN docker-php-ext-install pdo pdo_mysql

# Install bcmath
RUN docker-php-ext-install bcmath

RUN ln -s /usr/local/bin/php /usr/bin/php

COPY healthcheck/php-fpm-healthcheck /usr/local/bin/php-fpm-healthcheck

COPY . /app/
WORKDIR /app

EXPOSE 9000

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s \
    CMD php-fpm-healthcheck || exit 1

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php-fpm"]
