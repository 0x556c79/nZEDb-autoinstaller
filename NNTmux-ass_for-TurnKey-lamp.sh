#!/bin/bash
# Script Name: NNTmus Auto Installer for TurnKey-LAMP
# Author: STX2k (2016)
# Based on the idea from: PREngineer
# Updated for use with PHP7.4 by: 0x556x79
#############################################

# Color definition variables
YELLOW='\e[33;3m'
RED='\e[91m'
BLACK='\033[0m'
CYAN='\e[96m'
GREEN='\e[92m'

# stay safe
set -euo pipefail

# Change to /temp
rm -r /tmp/nntmux || true
mkdir /tmp/nntmux
cd /tmp/nntmux

# Make sure to clear the Terminal
clear

# Display the Title Information
echo
echo "$RED"
echo -e "   ___       _____ _____   __      ______       "
echo -e "  / _ \     | ____| ____| / /     |____  / _ \  "
echo -e " | | | |_  _| |__ | |__  / /___  __   / / (_) | "
echo -e " | | | \ \/ /___ \|___ \| '_ \ \/ /  / / \__, | "
echo -e " | |_| |>  < ___) |___) | (_) >  <  / /    / /  "
echo -e "  \___//_/\_\____/|____/ \___/_/\_\/_/    /_/   "
echo -e "$CYAN"
echo -e "NNTmux Auto Installer by 0x556x79"
echo

echo -e "$RED"' You use this Script on your own risk!'"$BLACK"
echo

# Function to check if running user is root
function CHECK_ROOT {
	if [ "$(id -u)" != "0" ]; then
		echo
		echo -e "$RED" "This script must be run as root." 1>&2
		echo
		exit 1
	fi
}

#User for NNTmux
echo -e "$YELLOW"
echo -e "---> [For safety reasons, we create a separate user...]""$BLACK"
read -r -p "User Account Name (eg. nntmux):" usernamenzb
echo -e "$YELLOW"
echo -e "---> [ Creating user and add to www-data group]""$BLACK"
useradd -r -s /bin/false "$usernamenzb" || true
usermod -aG www-data "$usernamenzb" || true
echo -e "$GREEN"
echo -e "[DONE!]"

# Installing apt-utils & apt-transport-https
echo -e "$YELLOW"
echo -e "---> [Installing apt-utils & apt-transport-https...]""$BLACK"
apt-get install -y apt-utils apt-transport-https > /dev/null
echo -e "$GREEN"
echo -e "[DONE!]"

# Installing Basic Software
echo -e "$YELLOW"
echo -e "---> [Installing Basic Software...]""$BLACK"
apt-get install -y ca-certificates nano curl git htop man software-properties-common git make par2 unzip wget tmux ntp ntpdate time tcptrack bwm-ng mariadb-client-10.1 > /dev/null
echo -e "$GREEN"
echo -e "[DONE!]"

# Installing Extra Software like mediainfo
echo -e "$YELLOW"
echo -e "---> [Install ffmpeg, mediainfo, p7zip-full, unrar and lame...]""$BLACK"
apt-get install -y unrar p7zip-full mediainfo lame ffmpeg libav-tools > /dev/null
echo -e "$GREEN"
echo -e "[DONE!]"

# Add repo for PHP 7.X
echo -e "$YELLOW"
wget -q -O- https://packages.sury.org/php/apt.gpg | apt-key add - > /dev/null
echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list > /dev/null
apt-get update -y > /dev/null
echo -e "$GREEN"
echo -e "[DONE!]"

# Removing PHP 7.0
echo -e "$YELLOW"
echo -e "---> [Removing PHP 7.0 & Extensions...]""$BLACK"
apt-get autoremove -y php7.0 php7.0-* > /dev/null
echo -e "$GREEN"
echo -e "[DONE!]"

# Installing PHP 7.4
echo -e "$YELLOW"
echo -e "---> [Installing PHP 7.4 & Extensions...]""$BLACK"
apt-get install -y libpcre3-dev php-pear php7.4 php7.4-cli php7.4-dev php7.4-common php7.4-curl php7.4-json php7.4-gd php7.4-mysql php7.4-mbstring php7.4-xml php7.4-intl php7.4-fpm php7.4-bcmath php7.4-zip php-imagick > /dev/null
echo -e "$GREEN"
echo -e "[DONE!]"

# Configure PHP 7.4
echo -e "$YELLOW"
echo -e "---> [Do some magic with the php7.4 config...]""$BLACK"
sed -ri 's/(max_execution_time =) ([0-9]+)/\1 120/' /etc/php/7.4/cli/php.ini
sed -ri 's/(memory_limit =) ([0-9]+)/\1 -1/' /etc/php/7.4/cli/php.ini
sed -ri 's/(upload_max_filesize =) ([0-9]+)/\1 100/' /etc/php/7.4/cli/php.ini
sed -ri 's/(post_max_size =) ([0-9]+)/\1 150/' /etc/php/7.4/cli/php.ini
sed -ri 's/;(date.timezone =)/\1 Europe\/Berlin/' /etc/php/7.4/cli/php.ini
sed -ri 's/(max_execution_time =) ([0-9]+)/\1 120/' /etc/php/7.4/fpm/php.ini
sed -ri 's/(memory_limit =) ([0-9]+)/\1 1024/' /etc/php/7.4/fpm/php.ini
sed -ri 's/(upload_max_filesize =) ([0-9]+)/\1 100/' /etc/php/7.4/fpm/php.ini
sed -ri 's/(post_max_size =) ([0-9]+)/\1 150/' /etc/php/7.4/fpm/php.ini
sed -ri 's/;(date.timezone =)/\1 Europe\/Berlin/' /etc/php/7.4/fpm/php.ini
echo -e "$GREEN"
echo -e "[DONE!]"

# Install MariaDB 10.4
echo -e "$YELLOW"
echo -e "---> [Installing MariaDB 10.4...]""$BLACK"
wget https://mariadb.org/mariadb_release_signing_key.asc > /dev/null
apt-key add mariadb_release_signing_key.asc > /dev/null
rm mariadb_release_signing_key.asc > /dev/null
cat <<EOF >> /etc/apt/sources.list.d/mariadb.list
# MariaDB 10.4 repository list - created 2020-02-17 02:20 UTC
# http://downloads.mariadb.org/mariadb/repositories/
deb [arch=amd64,i386,ppc64el] http://mirror.jaleco.com/mariadb/repo/10.4/debian stretch main
deb-src http://mirror.jaleco.com/mariadb/repo/10.4/debian stretch main
EOF
apt-get update > /dev/null
apt-get upgrade -y > /dev/null
echo -e "$GREEN"
echo -e "[DONE!]"

# Configure MariaB
echo -e "$YELLOW"
echo -e "---> [Starting MariaDB...]""$BLACK"
systemctl start mysql
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql || true
echo -e "$GREEN"
echo -e "[DONE!]"
echo -e "$YELLOW"
echo -e "---> [Configure MariaB...]""$BLACK"
cat <<EOF >> /etc/mysql/mariadb.conf.d/51-nntmux.cnf
[mysqld]
innodb_file_format = BARRACUDA
innodb_large_prefix = 1
innodb_file_per_table = 1
innodb_buffer_pool_size = 256M
innodb_buffer_pool_dump_at_shutdown = 1
innodb_buffer_pool_load_at_startup  = 1
innodb_checksum_algorithm = crc32
group_concat_max_len = 8192
sql_mode = ''
EOF
systemctl restart mysql 
echo -e "$GREEN"
echo -e "[DONE!]"

# Creating MySQl User for NNTmux
echo -e "$YELLOW"
echo -e "---> [Set password for MySQL user 'nntmux'...]""$BLACK"
read -r -p "Set password:" passwordmysql
echo -e "$CYAN"
echo -e "---> [Creating MySQL user 'nntmux'...]""$BLACK"
Q0="CREATE DATABASE nntmux;"
Q1="CREATE USER 'nntmux'@'localhost' IDENTIFIED BY '$passwordmysql';"
Q2="GRANT ALL ON nntmux.* TO 'nntmux'@'localhost' IDENTIFIED BY '$passwordmysql';"
Q3="GRANT FILE ON *.* TO 'nntmux'@'localhost' IDENTIFIED BY '$passwordmysql';"
Q4="FLUSH PRIVILEGES;"
SQL="${Q0}${Q1}${Q2}${Q3}${Q4}"
mysql -uroot -e "$SQL"
echo
echo -e "-------------------------------------------------"
echo -e "# WHEN FILLING THE DATABASE INFORMATION IN NZEDB#"
echo -e "# USE '127.0.0.1' as the hostname!              #"
echo -e "#                                               #"
echo -e "# MySQL User: nntmux                            #"
echo -e "# MySQL Pass: $passwordmysql  #"
echo -e "#                                               #"
echo -e "# Safe this login details for install nzedb     #"
echo -e "-------------------------------------------------""$BLACK"
echo -e "$YELLOW"
echo -e "---> [Lets secure the MySQL installation...]""$BLACK"
mysql_secure_installation
echo -e "$GREEN"
echo -e "[DONE!]"

# Install Apache 2.4.4
echo -e "$YELLOW"
echo -e "---> [Installing Apache 2.4.4...]""$BLACK"
wget -q -O- https://packages.sury.org/apache2/apt.gpg | apt-key add - > /dev/null
echo "deb https://packages.sury.org/apache2/ stretch main" | tee /etc/apt/sources.list.d/apache2.list > /dev/null
apt-get update -y > /dev/null
apt-get upgrade -y > /dev/null
apt-get install -y libapache2-mod-php7.4 > /dev/null
echo -e "$GREEN"
echo -e "[DONE!]"

echo -e "$YELLOW"
echo -e "---> [Installing mod_md...]""$BLACK"
apt-get install -y apache2-dev apache2-ssl-dev libcurl4-gnutls-dev libjansson-dev libtool-bin  > /dev/null
wget -q https://github.com/icing/mod_md/releases/download/v2.2.6/mod_md-2.2.6.tar.gz
tar -xf mod_md-2.2.6.tar.gz
cd mod_md-2.2.6 > /dev/null
./configure --with-apxs=/usr/bin/apxs > /dev/null
make > /dev/null
make install > /dev/null
libtool --finish /usr/lib> /dev/null
echo -e "$GREEN"
echo -e "[DONE!]"

echo -e "$YELLOW"
echo -e "---> [Configure Apache 2...]""$BLACK"
touch /etc/apache2/mods-available/md.load > /dev/null
echo LoadModule md_module /usr/lib/apache2/modules/mod_md.so > /etc/apache2/mods-available/md.load
apachectl stop > /dev/null
a2dismod php7.0 > /dev/null
a2dismod php7.4 > /dev/null
a2dismod mpm_prefork > /dev/null
a2enmod md > /dev/null
a2enmod rewrite > /dev/null
a2enmod proxy_fcgi > /dev/null
a2enmod setenvif > /dev/null
a2enmod mpm_event > /dev/null
a2enconf php7.4-fpm > /dev/null
systemctl start apache2
echo -e "$GREEN"
echo -e "[DONE!]"

echo -e "$YELLOW"
echo -e "---> [Creatin NNTmux Apache 2 config...]""$BLACK"
cat <<EOF >> NNTmux.conf
MDCertificateAgreement accepted
MDomain FQDN
<VirtualHost *:80>
    ServerName FQDN
    DocumentRoot "/var/www/NNTmux/public"
    Redirect / https://FQDN
</VirtualHost>
<VirtualHost *:443>
	ServerAdmin webmaster@FQDN
        ServerName FQDN
        SSLEngine on      
        DocumentRoot "/var/www/NNTmux/public"
        Alias /covers /var/www/NNTmux/resources/covers
        LogLevel warn
        ServerSignature Off
        ErrorLog /var/log/apache2/error_nntmux.log
        CustomLog /var/log/apache2/access_nntmux.log combined
  
        <FilesMatch "\.(cgi|shtml|phtml|php)$">
                SSLOptions +StdEnvVars
        </FilesMatch>
        <Directory /usr/lib/cgi-bin>
                SSLOptions +StdEnvVars
        </Directory>
        <Directory "/var/www/NNTmux/public">
                Options FollowSymLinks
                AllowOverride All
                Require all granted
        </Directory>
        <Proxy "fcgi://localhost:9000" enablereuse=on max=10>
        </Proxy>
        <FilesMatch \.php$>
            <If "-f %{REQUEST_FILENAME}">
                SetHandler "proxy:unix:/run/php/php7.2-fpm.sock|fcgi://localhost/"
            </If>
        </FilesMatch>
</VirtualHost>
EOF
mv NNTmux.conf /etc/apache2/sites-available/
echo -e "$GREEN"
echo -e "[DONE!]"

echo -e "$CYAN"
read -r -p "Set Servername (eg. yourindex.com):" servername
sed -i "s/\bFQDN\b/$servername/g" /etc/apache2/sites-available/NNTmux.conf
echo -e "$CYAN"
echo -e "---> [Create SSL-Certificate and Key file...]""$BLACK"
touch /etc/ssl/certs/"$servername".pem > /dev/null
touch /etc/ssl/private/"$servername".key > /dev/null
echo -e "$CYAN"
echo -e "---> [Disable Apache 2 default site...]""$BLACK"
a2dissite 000-default > /dev/null
echo -e "$CYAN"
echo -e "---> [Enable NNTmux site config...]""$BLACK"
a2ensite NNTmux.conf > /dev/null
echo -e "$CYAN"
echo -e "---> [Enable ModRewite...]""$BLACK"
a2enmod rewrite > /dev/null
echo -e "$CYAN"
echo -e "---> [Restart Apache 2...]""$BLACK"
systemctl restart apache2 > /dev/null
usermod -a -G www-data "$USER"
echo -e "$GREEN"
echo -e "[DONE!]"

# Install memcached
echo -e "$YELLOW"
echo -e "---> [Installing memcached...]""$BLACK"
apt-get install -y php-memcache php-memcached memcached > /dev/null
echo -e "$GREEN"
echo -e "[DONE!]"

# Installing Composer for NNTmux
echo -e "$YELLOW"
echo -e "---> [Install Composer...]""$BLACK"
#php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#php -r "if (hash_file('sha384', 'composer-setup.php') === 'c5b9b6d368201a9db6f74e2611495f369991b72d9c8cbd3ffbc63edff210eb73d46ffbfce88669ad33695ef77dc76976') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
#php composer-setup.php
#php -r "unlink('composer-setup.php');"
#composer -V
EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
fi

php composer-setup.php --quiet
RESULT=$?
rm composer-setup.php
echo -e "$RESULT"
mv composer.phar /usr/local/bin/composer
composer -V
echo -e "$GREEN"
echo -e "[DONE!]"

# Install & Setting up NNTmux
echo -e "$YELLOW"
echo -e "---> [NNTmux install...]""$BLACK"
newgrp www-data > /dev/null
cd /var/www/ > /dev/null
git clone https://github.com/NNTmux/newznab-tmux.git NNTmux
cd /var/www/NNTmux > /dev/null
git fetch --all --tags --prune > /dev/null
echo -e "$GREEN"
echo -e "[DONE!]"
echo -e "$YELLOW"
echo -e "---> [Setting up NNTmux...]""$BLACK"
cp .env.example .env > /dev/null
read -r -p "NNTP User:" nntpuser
read -r -p "NNTP Password:" nntppass
read -r -p "NNTP Server:" nntpserver
read -r -p "Admin User:" adminuser
read -r -p "Admin Password:" adminpw
read -r -p "Admin E-Mail:" adminmail
echo -e "$YELLOW"
echo -e "Edit /var/www/NNTmux/.env and add the following Parameters or replace them""$BLACK"
echo -e "$RED"
echo -e DB_USER=nntmux
echo -e DB_PASSWORD="$passwordmysql"
echo -e NNTP_USERNAME="$nntpuser"
echo -e NNTP_PASSWORD="$nntppass"
echo -e NNTP_SERVER="$nntpserver"
echo -e NNTP_PORT=586
echo -e NNTP_SSLENABLED=true
echo -e ADMIN_USER="$adminuser"
echo -e ADMIN_PASS="$adminpw"
echo -e ADMIN_EMAIL="$adminmail"
echo -e APP_ENV=production
echo -e APP_DEBUG=false
echo -e APP_TZ=Europe/Berlin
echo -e APP_URL="$FQDN
echo -e SESSION_DOMAIN="$FQDN"
echo -e ELASTICSEARCH_ENABLED=true"$BLACK"
read -r -p "Press [Enter] to continue..."
composer global require hirak/prestissimo
composer install
echo -e "$GREEN"
echo -e "[DONE!]"

# Fixing Permissions
echo -e "$YELLOW"
echo -e "---> [Fixing Permissions...]""$BLACK"
chown -R nntmux:www-data /var/www/NNTmux/bootstrap/cache/
chown -R nntmux:www-data /var/www/NNTmux/storage/logs/
chown -R nntmux:www-data /var/www/NNTmux/resources/tmp/
chown -R nntmux:www-data /var/www/NNTmux/public/
chmod -R 755 /var/www/NNTmux/vendor/
chmod -R 777 /var/www/NNTmux/storage/
chmod -R 777 /var/www/NNTmux/resources/
chmod -R 777 /var/www/NNTmux/public/
php artisan nntmux:install
echo -e "$GREEN"
echo -e "[DONE!]"

# Install Elasticsearch
echo -e "$YELLOW"
echo -e "---> [Elasticsearch install...]""$BLACK"
cd /var/www/NNTmux/misc/elasticsearch/
php create_es_tables.php
php populate_es_indexes.php releases
php populate_es_indexes.php predb

# Complete the Web Setup!

echo -e "$RED""STOP! WARING! STOP! WARNING! STOP! WARNING!""$BLACK"
echo -e "$RED""STOP! WARING! STOP! WARNING! STOP! WARNING!""$BLACK"

echo -e "$YELLOW"
echo -e "-------------------------------------------------"
echo -e "# You must complete the install of nzedb first  #"
echo -e "# Go to http://$servername/install              #"
echo -e "#                                               #"
echo -e "# YOU SHOULD PROBABLY ALSO ISSUE A NEW          #"
echo -e "# CERTIFICATE FROM LET'S ENCRYPT OR SOMWHERE    #"
echo -e "# ELSE TO AVOID SSL WARNINGS IN THE BRWOSER     #"
echo -e "#                                               #"
echo -e "# After the nzedb Setup is finish you can       #"
echo -e "# continue the Setup Script! OK?                #"
echo -e "-------------------------------------------------""$BLACK"

echo -e "$RED""STOP! WARING! STOP! WARNING! STOP! WARNING!""$BLACK"
echo -e "$RED""STOP! WARING! STOP! WARNING! STOP! WARNING!""$BLACK"

read -r -p "Press [Enter] to continue..."

# Import Daily Dumps
echo -e "$YELLOW"
echo -e "---> [Importing Daily Dumps...]""$BLACK"
chmod 777 /var/www/NNTmux/resources
chown -R "$usernamenzb":www-data /var/www/NNTmux/cli
echo
echo -e "$RED""PLEASE BE PATIENT!  THIS   + M A Y +   TAKE A LONG TIME!""$BLACK"
echo
php /var/www/NNTmux/cli/data/predb_import_daily_batch.php 0 local true
echo -e "$GREEN"
echo -e "[DONE!]"

# Fixing Install TMUX
echo -e "$YELLOW"
echo -e "---> [Installing TMUX...]""$BLACK"
apt-get install libevent-dev git autotools-dev automake pkg-config ncurses-dev -y > /dev/null
apt-get remove tmux -y > /dev/null
git clone https://github.com/tmux/tmux.git --branch 2.0 --single-branch
cd tmux
./autogen.sh
./configure
make -j4
make install
make clean
echo -e "$GREEN"
echo -e "[DONE!]"

echo -e "$GREEN"
echo -e "---> WE ARE [DONE!]""$BLACK"
echo -e "To manually index run the files located in $BLUE misc/update_scripts""$BLACK"
echo -e "update_binaries = to GET article headers"
echo -e "update_releases = to CREATE releases"
echo -e ""
echo -e "To automate the process use the script located in $BLUE misc/update_scripts/nix_scripts""$BLACK"

read -r -p "Press [Enter] to continue..."

echo -e "$YELLOW"
echo -e "---> [Rebooting...]""$BLACK"
reboot now
echo -e "$GREEN"
echo -e "[DONE!]""$BLACK"
