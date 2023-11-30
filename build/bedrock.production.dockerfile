# Use a PHP FPM-based image optimized for production
FROM php:8.2-fpm

# Set labels for your image
LABEL maintainer="Aaron Annecchiarico <aaron@grugs.dev>"
LABEL description="Production image for Bedrock-based WordPress site"

# Install only the necessary PHP extensions
# Install php extensions including xdebug and related packages
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && sync \
  && install-php-extensions \
    @composer \
    exif \
    gd \ 
    memcached \
    mysqli \
    pcntl \
    pdo_mysql \
    zip \
  && apt-get update \
  && apt-get install -y \
    gifsicle \
    jpegoptim \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libmemcached-dev \
    locales \
    lua-zlib-dev \
    optipng \
    pngquant \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x wp-cli.phar \
  && mv wp-cli.phar /usr/local/bin/wp

# Copy necessary application code and configurations
COPY ./build/php/8.2/fpm/development/pool.d /usr/local/etc/php/8.2/fpm/pool.d
COPY ./bedrock /srv/bedrock

# Set the working directory
WORKDIR /srv/bedrock
COPY ./build/bin/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

# Change the ownership of /var/www to www-data
RUN chown -R www-data:www-data /var/www

# Set the user
USER www-data

# Start the PHP-FPM server
CMD ["php-fpm"]
