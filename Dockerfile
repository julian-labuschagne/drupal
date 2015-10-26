FROM ubuntu:14.04
MAINTAINER Julian Labuschagne "personxx@gmail.com"
ENV REFRESHED_AT 2015-10-20

RUN apt-get -y -q update && apt-get -y -q upgrade && apt-get install -y -q curl php5-cli git-core mariadb-client

# grab gosu for easy step-down from root
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture)" \
 && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture).asc" \
 && gpg --verify /usr/local/bin/gosu.asc \
 && rm /usr/local/bin/gosu.asc \
 && chmod +x /usr/local/bin/gosu

RUN adduser --system --group --home /var/www/webdev webdev && adduser webdev www-data
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN curl -LSs http://drupalconsole.com/installer | php
RUN mv console.phar /usr/local/bin/drupal

USER webdev
RUN composer global require drush/drush:dev-master
COPY bashrc /var/www/webdev/.bashrc

WORKDIR /var/www/webdev

CMD [ "/bin/bash" ]
