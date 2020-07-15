#!/usr/bin/env bash

# Create a COMPOSER_HOME directory for the application
if [[ ! -d "/var/cache/composer" ]];then
    mkdir -p /var/cache/composer
    chown www-data.www-data /var/cache/composer
fi

# Make sure folder is created
echo "Checking if folder exists"
if [[ -d /var/www/symfony-project-kickstart ]]; then
  echo "Bye folder"
  sudo rm -R /var/www/symfony-project-kickstart
  echo "Creating folder"
  mkdir /var/www/symfony-project-kickstart
  echo "Changing permissions to apache"
  chown -R www-data: /var/www/symfony-project-kickstart
fi