FROM ubuntu:16.04

MAINTAINER Massimiliano Arione <garakkio@gmail.com>

# Set correct environment variables
ENV HOME /root
ENV LANG it_IT.UTF-8
ENV LC_ALL it_IT.UTF-8

# MYSQL ROOT PASSWORD
ARG MYSQL_ROOT_PASS=root

ARG DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update && apt-get install -y locales --no-install-recommends && locale-gen it_IT.UTF-8

RUN \
    apt-get update && apt-get install -y software-properties-common && add-apt-repository -y -u ppa:ondrej/php && \
    apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    mcrypt \
    wget \
    openssl \
    locales \
    --no-install-recommends && rm -r /var/lib/apt/lists/* \
    && apt-get --purge autoremove -y

# OpenSSL
RUN mkdir -p /usr/local/openssl/include/openssl/ && \
    ln -s /usr/include/openssl/evp.h /usr/local/openssl/include/openssl/evp.h && \
    mkdir -p /usr/local/openssl/lib/ && \
    ln -s /usr/lib/x86_64-linux-gnu/libssl.a /usr/local/openssl/lib/libssl.a && \
    ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/local/openssl/lib/

# MYSQL
RUN bash -c 'debconf-set-selections <<< "mysql-server-5.7 mysql-server/root_password password $MYSQL_ROOT_PASS"' && \
        bash -c 'debconf-set-selections <<< "mysql-server-5.7 mysql-server/root_password_again password $MYSQL_ROOT_PASS"' && \
        DEBIAN_FRONTEND=noninteractive apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -qqy mysql-server-5.7
        
# PHP Extensions
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y -qq php7.1-mcrypt php7.1-zip php7.1-xml php7.1-mbstring php7.1-curl php7.1-json php7.1-mysql php7.1-tokenizer php7.1-cli

# Libraries needed for wkhtmltopdf
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -qq libxext6 libxrender1 libfontconfig1

# Time Zone
RUN echo "date.timezone=Europe/Rome" > /etc/php/7.1/cli/conf.d/date_timezone.ini

VOLUME /root/composer

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Goto temporary directory.
WORKDIR /tmp

RUN apt-get clean -y && \
        apt-get autoremove -y && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

