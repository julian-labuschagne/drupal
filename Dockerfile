FROM ubuntu:14.04
MAINTAINER Julian Labuschagne "personxx@gmail.com"
ENV REFRESHED_AT 2015-10-20

RUN apt-get -y -q update && apt-get -y -q upgrade && apt-get install -y -q curl php5-cli php5-mysql git-core 

RUN adduser --system --group --home /var/www/webdev webdev && adduser webdev www-data
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

USER webdev
RUN composer global require drush/drush:dev-master
COPY bashrc /var/www/webdev/.bashrc

WORKDIR /var/www/webdev

CMD [ "/bin/bash" ]
