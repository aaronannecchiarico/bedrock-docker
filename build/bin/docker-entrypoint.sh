#!/bin/sh
# docker-entrypoint.sh

# Perform the installation
set -e
cd /srv/bedrock
composer install

# Check if WordPress is already installed (and possibly perform other checks)
if ! wp core is-installed --allow-root; then
    # Perform the installation
    wp core install --url="${WP_HOME}" \
        --title="${WP_SITE_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --allow-root
fi

# Perform the rest of the commands
wp package install aaemnnosttv/wp-cli-login-command --allow-root \
    || echo 'wp-cli-login-command is already installed'
wp login install --activate --yes --skip-plugins --skip-themes --allow-root
wp login as 1 --allow-root

# Continue with the main container command
exec "$@"