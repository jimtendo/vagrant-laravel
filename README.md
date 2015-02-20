vagrant-laravel
================

Vagrant Environment for Laravel V5 (Provisioned with bash script).

Has all the basic requirements including Composer.

(Not included is Redis)


## Installation and Usage

1. Clone this git repository into a folder
2. Place your Laravel application into a subfolder named "www"
3. Edit your "www/.env" file so that the database name is "db" and the user:pass is root:root
4. Run "vagrant up"
5. Access with http://localhost:14100 (or https://localhost:15100 for SSL)