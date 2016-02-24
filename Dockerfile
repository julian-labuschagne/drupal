FROM ubuntu:14.04
MAINTAINER Julian Labuschagne "personxx@gmail.com"
ENV REFRESHED_AT 2015-10-20

RUN apt-get -y -q update && apt-get -y -q upgrade && apt-get install -y -q curl php5-cli php5-mysql php5-gd git-core mariadb-client

RUN groupadd -g 1000 webdev
RUN adduser --system --home /var/www --uid 1000 webdev && adduser webdev www-data
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN ln -s /var/www/.composer/vendor/bin/drush /usr/local/bin/drush
USER webdev
WORKDIR /var/www

RUN composer global require drush/drush:7.x
COPY bashrc /var/www/.bashrc

CMD "/bin/bash"
