# Login as super-user
sudo -s

# Create swap (composer takes up a lot of memory)
fallocate -l 1G /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile   none    swap    sw    0   0' >> /etc/fstab

# Update repos
apt-get update

# Install Git and PHP5
apt-get install -y git-core subversion curl php5-cli php5-curl php5-mcrypt php5-gd

# Setup MySQL
debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
apt-get install -y php5-mysql mysql-server

# Open MySQL ports to outside (Comment out the following to disable)
sed -i -e 's/bind-address/#bind-address/g' /etc/mysql/my.cnf
mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root';"
service mysql restart

# Install Apache2
apt-get install -y apache2 libapache2-mod-php5

# Enable MCrypt
ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/cli/conf.d/20-mcrypt.ini
ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/apache2/conf.d/20-mcrypt.ini

# Enable Rewrite and SSL
a2enmod rewrite ssl

# Configure our site's Apache Config
cat <<EOF > /etc/apache2/sites-available/000-default.conf

<VirtualHost *:80>
    DocumentRoot /var/www/public
    <Directory /var/www/public>
        Options All
        AllowOverride All
    </Directory>
</VirtualHost>

<IfModule mod_ssl.c>
<VirtualHost *:443>
    DocumentRoot /var/www/public
    <Directory /var/www/public>
        Options All
        AllowOverride All
    </Directory>
    SSLEngine on
    SSLCertificateFile    /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
</VirtualHost>
</IfModule>

EOF

# Configure our other shit
rm -rf '/var/www/html'
mysql -u root -proot -e 'CREATE DATABASE db;'

# Restart Apache
service apache2 restart

# Install composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Install composer dependencies and seed application
cd /var/www && composer install
php artisan migrate --seed