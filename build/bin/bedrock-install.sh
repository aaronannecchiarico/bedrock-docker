#!/bin/bash

set -e

cd /srv/bedrock

composer install

wp core install --url=$WP_HOME \
  --title=$WP_SITE_TITLE \
  --admin_user=$WP_ADMIN_USER \
  --admin_email=$WP_ADMIN_EMAIL \
  --admin_password=$WP_ADMIN_PASSWORD \

wp package install aaemnnosttv/wp-cli-login-command \
  || echo 'wp-cli-login-command is already installed'

wp login install --activate --yes --skip-plugins --skip-themes

wp login as 1

/usr/bin/supervisord -c /etc/supervisord.conf > /dev/null
