FROM php:7-fpm-alpine

ENV XDEBUG_VERSION 2.3.3
ENV PHP_MEMORY_LIMIT 256M
ENV PHP_MAX_EXECUTION_TIME 120

RUN docker-php-source extract \
    && apk --no-cache --update add \
       libxml2-dev \
       libpng \
       libpng-dev \
       libjpeg-turbo \
       libjpeg-turbo-dev \
       freetype-dev \
       freetype \
       curl \
       icu-dev \
       g++ \
       autoconf \
       make \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/* \
    && docker-php-ext-configure bcmath \
    && docker-php-ext-configure json \
    && docker-php-ext-configure session \
    && docker-php-ext-configure ctype \
    && docker-php-ext-configure tokenizer \
    && docker-php-ext-configure simplexml \
    && docker-php-ext-configure dom \
    && docker-php-ext-configure mbstring \
    && docker-php-ext-configure zip \
    && docker-php-ext-configure iconv \
    && docker-php-ext-configure xml \
    && docker-php-ext-configure opcache \
    && docker-php-ext-configure pdo \
    && docker-php-ext-configure pdo_mysql \
    && docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ \
      --with-jpeg-dir=/usr/include/ \
      --with-png-dir=/usr/include/ \
    && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-install -j${NPROC} gd \
    && docker-php-source delete

RUN docker-php-ext-install bcmath \
    json \
    session \
    ctype \
    tokenizer \
    simplexml \
    dom \
    mbstring \
    zip \
    iconv \
    xml \
    opcache \
    pdo \
    pdo_mysql
RUN apk update \
    && apk add ca-certificates wget \
    && update-ca-certificates
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug

# Xdebug settings.
COPY ./xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install mhsendmail
RUN apk update && apk add \
     go \
     git
RUN mkdir /root/go
ENV GOPATH=/root/go
ENV PATH=$PATH:$GOPATH/bin
RUN go get github.com/mailhog/mhsendmail
RUN cp /root/go/bin/mhsendmail /usr/bin/mhsendmail
COPY ./php.ini /usr/local/etc/php/conf.d/docker-php.ini

# Cleanup
RUN rm -rf /tmp/* \
    && rm -rf /var/cache/apk/* \
    && rm -rf tmp/*
