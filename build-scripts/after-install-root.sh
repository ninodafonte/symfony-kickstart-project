#!/usr/bin/env bash
#######################################################################
# Application preparation
#######################################################################
(
    chown -R www-data: /var/www/symfony-project-kickstart
    cd /var/www/symfony-project-kickstart ;
    chmod +x composer.phar

    # Copy in the production local configuration
    # Here you could generate your .env file for instance. I usually put them in S3 and copy them to the project folder.
    mv /var/www/symfony-project-kickstart/.env.dist /var/www/symfony-project-kickstart/.env
    /var/www/symfony-project-kickstart/composer.phar dump-env prod

    # Execute a composer installation
    sudo -H -u www-data bash -c 'COMPOSER_HOME=/var/cache/composer ./composer.phar install --quiet --no-ansi --no-dev --no-interaction --no-progress' ;

    # Update assets from symfony:
    chmod +x bin/console
    bin/console doctrine:migrations:migrate --no-interaction  --all-or-nothing

    chown -R www-data: /var/www/symfony-project-kickstart
)