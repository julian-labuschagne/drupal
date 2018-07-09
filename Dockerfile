FROM ubuntu:16.04
MAINTAINER Julian Labuschagne "personxx@gmail.com"
ENV REFRESHED_AT 2018-05-29

RUN apt-get -y -q update && \
    apt-get -y -q upgrade && \
    apt-get install -y -q curl php-cli php-mysql php-gd php-pear php-curl git-core mariadb-client unzip wget curl

# fixuid debian / ubuntu
RUN addgroup --gid 1000 webdev && \
    adduser --uid 1000 --ingroup webdev --home /var/www --shell /bin/sh --disabled-password --gecos "" webdev && \
    adduser webdev www-data

#RUN adduser --system --home /var/www --uid 1000 webdev

RUN USER=webdev && \
    GROUP=webdev && \
    curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.4/fixuid-0.4-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN ln -s /var/www/.composer/vendor/bin/drush /usr/local/bin/drush
USER webdev:webdev
WORKDIR /var/www

RUN composer global require drush/drush:8.x

RUN git config --global credential.helper cache
RUN git config --global credential.helper 'cache --timeout=28800'

COPY bashrc /var/www/.bashrc

ENTRYPOINT  ["fixuid"]
CMD "/bin/bash"
