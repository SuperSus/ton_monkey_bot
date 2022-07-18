#!/bin/bash

APP_NAME=tonmonkey
DB_NAME=tonmonkey_database
DOMAIN=tonmonkey.click
EMAIL=sikorskyalexandr08@gmail.com

wget https://raw.githubusercontent.com/dokku/dokku/v0.27.8/bootstrap.sh;
sudo DOKKU_TAG=v0.27.8 bash bootstrap.sh

fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

cat ~/.ssh/authorized_keys | dokku ssh-keys:add admin

dokku apps:create $APP_NAME
dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
dokku postgres:create $DB_NAME
dokku postgres:link $DB_NAME $APP_NAME


dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git
dokku config:set --no-restart $APP_NAME DOKKU_LETSENCRYPT_EMAIL=${EMAIL}
dokku letsencrypt:enable $APP_NAME
dokku letsencrypt:cron-job --add

dokku config:set $APP_NAME HOST=$DOMAIN
#dokku domains:add $APP_NAME www.$DOMAIN
dokku domains:set $APP_NAME $DOMAIN


dokku config:set $APP_NAME RAILS_ENV=production
dokku config:set $APP_NAME RAILS_MASTER_KEY=16d41d3574704404fe87259cd1a4192f #config/credentials/production.key

dokku storage:ensure-directory --chown ${APP_NAME}_storage chmod -R 'a+w' /var/lib/dokku/data/storage/${APP_NAME}_storage
dokku storage:mount $APP_NAME /var/lib/dokku/data/storage/fastcoffedelivery_storage:/app/storage dokku storage:list $APP_NAME