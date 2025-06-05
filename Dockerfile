# ---- Builder Stage ----
FROM ubuntu:20.04 AS builder

# Install build dependencies: curl, php-cli, git, and necessary PHP extensions for composer
RUN apt-get -y -q update && \
    apt-get install -y --no-install-recommends -q curl php-cli php-json php-mbstring git unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/download/latest-stable/composer.phar -o /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

# Create a temporary location for global composer packages for webdev user
# We need to simulate the webdev user's environment for composer global install
ENV COMPOSER_HOME=/tmp/composer_home_webdev
RUN mkdir -p $COMPOSER_HOME/vendor/bin && \
    chown -R 1000:0 $COMPOSER_HOME
    # GID 0 (root) for group, user 1000 will be webdev

# Install Drush globally using the COMPOSER_HOME
# Note: Running composer as root here, but targeting webdev's future home structure.
RUN composer global require drush/drush:7.x

# ---- Final Stage ----
FROM ubuntu:20.04
LABEL maintainer="Julian Labuschagne <personxx@gmail.com>"
# ENV REFRESHED_AT 2015-10-20 # Intentionally commented out as per suggestion

# Install runtime dependencies
RUN apt-get -y -q update
RUN apt-get -y -q upgrade && \
    apt-get install -y --no-install-recommends -q php-cli php-mysql php-gd mariadb-client git-core && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create user and group
RUN groupadd -g 1000 webdev
RUN adduser --system --home /var/www --uid 1000 --gid 1000 webdev && adduser webdev www-data

# Copy Composer from the builder stage
COPY --from=builder /usr/local/bin/composer /usr/local/bin/composer

# Copy Drush and its dependencies from the builder stage
COPY --from=builder /tmp/composer_home_webdev/vendor /var/www/.composer/vendor

# Ensure permissions are correct for webdev for the copied .composer directory
RUN mkdir -p /var/www/.composer && chown -R webdev:webdev /var/www/.composer

# Setup Drush symlink
RUN ln -s /var/www/.composer/vendor/bin/drush /usr/local/bin/drush

USER webdev
WORKDIR /var/www

COPY bashrc /var/www/.bashrc

CMD ["/bin/bash"]
