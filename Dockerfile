FROM ubuntu:14.04
MAINTAINER Julian Labuschagne "personxx@gmail.com"
ENV REFRESHED_AT 2016-10-17

RUN apt-get -y -q update && apt-get -y -q upgrade && apt-get install -y -q curl php5-cli php5-mysql php5-gd php-pear php5-curl git-core mariadb-client unzip wget curl

RUN groupadd -g 1000 webdev
RUN adduser --system --home /var/www --uid 1000 webdev && adduser webdev www-data
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN ln -s /var/www/.composer/vendor/bin/drush /usr/local/bin/drush
USER webdev
WORKDIR /var/www

RUN composer global require drush/drush:7.x

RUN git config --global credential.helper cache
RUN git config --global credential.helper 'cache --timeout=28800'

COPY bashrc /var/www/.bashrc

CMD "/bin/bash"
