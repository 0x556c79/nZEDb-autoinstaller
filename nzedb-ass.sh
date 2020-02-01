#!/bin/bash
# Script Name: nZEDb Auto Installer
# Author: STX2k (2016)
# Based on the idea from: PREngineer
# Updated for use with PHP7 by: 0x556x79
#############################################

# Color definition variables
YELLOW='\e[33;3m'
RED='\e[91m'
BLACK='\033[0m'
CYAN='\e[96m'
GREEN='\e[92m'

# stay safe
set -euo pipefail

# Make sure to clear the Terminal
clear

# Display the Title Information
echo
echo "$RED"
echo "  ________________________  ___________  __     "
echo " /   _____/\__    ___/\   \/  /\_____  \|  | __ "
echo " \_____  \   |    |    \     /  /  ____/|  |/ / "
echo " /        \  |    |    /     \ /       \|    <  "
echo "/_______  /  |____|   /___/\  \\_______ \__|_ \ "
echo "        \/                  \_/        \/    \/ "
echo "$CYAN"
echo "nZEDb Auto Installer by STX2k updated by 0x556x79"
echo

echo "$RED"' You use this Script on your own risk!'"$BLACK"
echo

# Function to check if running user is root
function CHECK_ROOT {
	if [ "$(id -u)" != "0" ]; then
		echo
		echo "$RED" "This script must be run as root." 1>&2
		echo
		exit 1
	fi
}

#User for nZEDb
echo "$YELLOW"
echo "---> [For safety reasons, we create a separate user...]""$BLACK"
read -r -p "User Account Name (eg. nzedb):" usernamenzb
sudo useradd -r -s /bin/false "$usernamenzb"
sudo usermod -aG www-data "$usernamenzb"
echo "$GREEN"
echo "[DONE!]"

# Updating System
echo "$YELLOW"
echo "---> [Updating System...]""$BLACK"
sudo apt-get update > /dev/null
sudo apt-get -y upgrade > /dev/null
sudo apt-get -y dist-upgrade > /dev/null
echo "$GREEN"
echo "[DONE!]"

# Installing Basic Software
echo "$YELLOW"
echo "---> [Installing Basic Software...]""$BLACK"
sudo apt-get install -y nano curl git htop man software-properties-common par2 unzip wget tmux ntp ntpdate time tcptrack bwm-ng mytop > /dev/null
sudo python3 -m easy_install pip > /dev/null
echo "$GREEN"
echo "[DONE!]"

# Installing Extra Software like mediainfo
echo "$YELLOW"
echo "---> [Install ffmpeg, mediainfo, p7zip-full, unrar and lame...]""$BLACK"
sudo apt-get install -y unrar p7zip-full mediainfo lame ffmpeg libav-tools > /dev/null
echo "$GREEN"
echo "[DONE!]"

# Installing Python 3 and some modules
echo "$YELLOW"
echo "---> [Installing Python 3 and Modules...]""$BLACK"
sudo apt-get install -y python-setuptools python-dev software-properties-common python3-setuptools python3-pip python-pip && \
python -m easy_install pip  && \
easy_install cymysql && \
easy_install pynntp && \
easy_install socketpool && \
pip list && \
python3 -m easy_install pip && \
pip3 install cymysql && \
pip3 install pynntp && \
pip3 install socketpool && \
pip3 list > /dev/null
echo "$GREEN"
echo "[DONE!]"

#Add PHP 7 ppa:ondrej/php
echo "$YELLOW"
echo "---> [Add PHP 7 Repo...]"
echo "You must press -> Enter <- to confirm""$BLACK"
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-add-repository -y multiverse
sudo apt-get update -y
echo "$GREEN"
echo "[DONE!]"

# Installing PHP 7.2
echo "$YELLOW"
echo "---> [Installing PHP & Extensions...]""$BLACK"
sudo apt-get install -y libpcre3-dev php7.2-fpm php7.2-dev php-pear php7.2-gd php7.2-mysql php7.2-curl php7.2-common  php7.2-json php7.2-cli > /dev/null
echo "$GREEN"
echo "[DONE!]"

# Configure PHP 7.2
echo "$YELLOW"
echo "---> [Do some magic with the php7.2 config...]""$BLACK"
sed -ri 's/(max_execution_time =) ([0-9]+)/\1 120/' /etc/php/7.2/cli/php.ini
sed -ri 's/(memory_limit =) ([0-9]+)/\1 -1/' /etc/php/7.2/cli/php.ini
sed -ri 's/(upload_max_filesize =) ([0-9]+)/\1 100/' /etc/php/7.2/cli/php.ini
sed -ri 's/(post_max_size =) ([0-9]+)/\1 150/' /etc/php/7.2/cli/php.ini
sed -ri 's/;(date.timezone =)/\1 Europe\/Berlin/' /etc/php/7.2/cli/php.ini
sed -ri 's/(max_execution_time =) ([0-9]+)/\1 120/' /etc/php/7.2/fpm/php.ini
sed -ri 's/(memory_limit =) ([0-9]+)/\1 1024/' /etc/php/7.2/fpm/php.ini
sed -ri 's/(upload_max_filesize =) ([0-9]+)/\1 100/' /etc/php/7.2/fpm/php.ini
sed -ri 's/(post_max_size =) ([0-9]+)/\1 150/' /etc/php/7.2/fpm/php.ini
sed -ri 's/;(date.timezone =)/\1 Europe\/Berlin/' /etc/php/7.2/fpm/php.ini
echo "$GREEN"
echo "[DONE!]"

# Install yEnc decoder extension for PHP 7
echo "$YELLOW"
echo "---> [Install yEnc decoder extension for PHP7...]""$BLACK"
conf=$(php -i | grep -o "Scan this dir for additional .ini files => \S*" | cut -d\  -f9)
major=$(php -r "echo PHP_VERSION;" | cut -d. -f1)
minor=$(php -r "echo PHP_VERSION;" | cut -d. -f2)
phpver="$major.$minor"

fpm -s dir -t deb \
    -n php"$phpver"-yenc -v 1.3.0 \
    --depends "php${phpver}" \
    --description "php-yenc extension build for PHP ${phpver}" \
    --url 'https://github.com/niel/php-yenc' \
    --after-install=post-install.sh \
     /etc/php/"$phpver"/mods-available/yenc.ini \
     "$conf"/20-yenc.ini \
     "$(php-config  --extension-dir)"/yenc.so
echo "$GREEN"
echo "[DONE!]"

# Installing Composer for nZEDb
echo "$YELLOW"
echo "---> [Install Composer...]""$BLACK"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" > /dev/null
php -r "if (hash_file('SHA384', 'composer-setup.php') === 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" > /dev/null
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer > /dev/null
php -r "unlink('composer-setup.php');" > /dev/null
composer -V
echo "$GREEN"
echo "[DONE!]"

# Installing MariaDB 
echo "$YELLOW"
echo "---> [Installing MySQL...]""$BLACK"
sudo apt-get install -y software-properties-common > /dev/null
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirror.wtnet.de/mariadb/repo/10.4/ubuntu bionic main'
sudo apt update -y
sudo apt install -y mariadb-server mariadb-client > /dev/null
sudo systemctl start mysql
sudo rm /etc/systemd/system/mysql.service || true
echo "$GREEN"
echo "[OK!]"
sudo rm /etc/systemd/system/mysqld.service || true
echo "$GREEN"
echo "[OK!]"
sudo systemctl enable mysql
echo "$GREEN"
echo "[DONE!]"

# Configure MariaB
echo "$YELLOW"
echo "---> [Configure MariaB...]""$BLACK"
cat <<EOF >> /etc/mysql/my.cnf
### configurations by nZEDb ####
innodb_file_per_table = ON
max_allowed_packet = 16M
group_concat_max_len = 8192
sql_mode = ''
innodb_buffer_pool_dump_at_shutdown = ON
innodb_buffer_pool_load_at_startup  = ON
innodb_checksum_algorithm           = crc32
EOF
sudo systemctl restart mysql
echo "$GREEN"
echo "[DONE!]"

# Creating MySQl User for nZEDb
echo "$YELLOW"
echo "---> [Set password for MySQL user 'nzedb'...]""$BLACK"
read -r -p "Set password:" passwordmysql
echo "$CYAN"
echo "---> [Creating MySQL user 'nzedb'...]""$BLACK"
echo "$RED" "Please login with your MySQL Root password!"
MYSQL='which mysql'
Q0="CREATE USER 'nzedb'@'%' IDENTIFIED BY '$passwordmysql';"
Q1="GRANT ALL ON *.* TO 'nzedb'@'%' IDENTIFIED BY '$passwordmysql';"
Q2="GRANT FILE ON *.* TO 'nzedb'@'%' IDENTIFIED BY '$passwordmysql';"
Q3="FLUSH PRIVILEGES;"
SQL="${Q0}${Q1}${Q2}${Q3}"
$MYSQL -uroot -p -e "$SQL"
echo
echo "-------------------------------------------------"
echo "# WHEN FILLING THE DATABASE INFORMATION IN NZEDB#"
echo "# USE '0.0.0.0' as the hostname!                #"
echo "#                                               #"
echo "# MySQL User: nzedb                             #"
echo "# MySQL Pass: $passwordmysql                    #"
echo "#                                               #"
echo "# Safe this login details for install nzedb     #"
echo "-------------------------------------------------""$BLACK"
echo "$YELLOW"
echo "---> [Lets secure the MySQL installation...]""$BLACK"
mysql_secure_installation
echo "$GREEN"
echo "[DONE!]"

# Install Apache 2.4
echo "$YELLOW"
echo "---> [Installing Apache 2...]""$BLACK"
sudo apt-get install -y apache2 libapache2-mod-php7.2 > /dev/null
cat <<EOF > nZEDb.conf
<VirtualHost *:80>
    ServerName FQDN
    Redirect / https://FQDN.de
</VirtualHost>

<IfModule mod_ssl.c>
    <VirtualHost *:443>
        ServerAdmin webmaster@localhost
        ServerName localhost
        #ServerAlias somedomain # Optional
        DocumentRoot "/var/www/nZEDb/www"
        Alias /covers /var/www/nZEDb/resources/covers
        LogLevel warn
        ServerSignature Off
        ErrorLog /var/log/apache2/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        SSLEngine on
        SSLVerifyClient require
        SSLVerifyDepth 1
        SSLCertificateFile		/etc/ssl/certs/FQDN.pem
        SSLCertificateKeyFile		/etc/ssl/private/FQDN.key
        #SSLCertificateChainFile	/etc/apache2/ssl.crt/server-ca.crt
        #SSLCACertificatePath		/etc/ssl/certs/ # For Cloudflare
	#SSLCACertificateFile		/etc/ssl/certs/origin-pull-ca.pem # For Cloudflare

        <FilesMatch "\.(cgi|shtml|phtml|php)$">
                SSLOptions +StdEnvVars
        </FilesMatch>
        <Directory /usr/lib/cgi-bin>
                SSLOptions +StdEnvVars
        </Directory>

        <Directory "/var/www/nZEDb/www">
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
</IfModule>
EOF
sudo mv nZEDb.conf /etc/apache2/sites-available/
echo "$CYAN"
read -r -p "Set Servername (eg. yourindex.com):" servername
sed -i "s/\bFQDN\b/$servername/g" /etc/apache2/sites-available/nZEDb.conf
echo "$CYAN"
echo "---> [Create SSL-Certificate and Key file...]""$BLACK"
sudo touch /etc/ssl/certs/"$servername".pem
sudo touch /etc/ssl/private/"$servername".key
echo "$CYAN"
echo "---> [Disable Apache 2 default site...]""$BLACK"
sudo a2dissite 000-default
echo "$CYAN"
echo "---> [Enable nZEDb site config...]""$BLACK"
sudo a2ensite nZEDb.conf
echo "$CYAN"
echo "---> [Enable ModRewite...]""$BLACK"
sudo a2enmod rewrite
echo "$CYAN"
echo "---> [Restart Apache 2...]""$BLACK"
sudo service apache2 restart
echo "$GREEN"
echo "[DONE!]"

# Install memcached
echo "$YELLOW"
echo "---> [Installing memcached...]""$BLACK"
sudo apt-get install -y memcached php-memcached > /dev/null
echo "$GREEN"
echo "[DONE!]"

# Install nZEDb
echo "$YELLOW"
echo "---> [nZEDb install...]""$BLACK"
cd /var/www
composer create-project --no-dev --keep-vcs --prefer-source nzedb/nzedb nzedb
echo "$GREEN"
echo "[DONE!]"

# Fixing Permissions
echo "$YELLOW"
echo "---> [nZEDb install...]""$BLACK"
sudo chmod -R 755 /var/www/nZEDb/app/libraries
sudo chmod -R 755 /var/www/nZEDb/libraries
sudo chmod -R 777 /var/www/nZEDb/resources
sudo chmod -R 777 /var/www/nZEDb/www
sudo chgrp www-data nzedb
sudo chmod -R 777 /var/www/nzedb
sudo chgrp www-data /var/www/nzedb/resources/smarty/templates_c
sudo chgrp -R www-data /var/www/nzedb/resources/covers
sudo chgrp www-data /var/www/nzedb/www
sudo chgrp www-data /var/www/nzedb/www/install
sudo chgrp -R www-data /var/www/nzedb/resources/nzb
sudo chown -R www-data:www-data /var/lib/php/sessions/
echo "$GREEN"
echo "[DONE!]"

# Complete the Web Setup!

echo "$RED""STOP! WARING! STOP! WARNING! STOP! WARNING!""$BLACK"
echo "$RED""STOP! WARING! STOP! WARNING! STOP! WARNING!""$BLACK"

echo "$YELLOW"
echo "-------------------------------------------------"
echo "# You must complete the install of nzedb first  #"
echo "# Go to http://$servername/install              #"
echo "#                                               #"
echo "# YOU SHOULD PROBABLY ALSO ISSUE A NEW          #"
echo "# CERTIFICATE FROM LET'S ENCRYPT OR SOMWHERE    #"
echo "# ELSE TO AVOID SSL WARNINGS IN THE BRWOSER     #"
echo "#                                               #"
echo "# After the nzedb Setup is finish you can       #"
echo "# continue the Setup Script! OK?                #"
echo "-------------------------------------------------""$BLACK"

echo "$RED""STOP! WARING! STOP! WARNING! STOP! WARNING!""$BLACK"
echo "$RED""STOP! WARING! STOP! WARNING! STOP! WARNING!""$BLACK"
echo "$RED"" YOU SHOULD PROBABLY ISSUE A NEW CERTIFICATE FROM LET'S ENCRYPT OR SOMWHERE ELSE TO AVOID SSL WARNINGS IN THE BRWOSER""$BLACK"

read -r -p "Press [Enter] to continue..."

# Import Daily Dumps
echo "$YELLOW"
echo "---> [Importing Daily Dumps...]""$BLACK"
sudo chmod 777 /var/www/nzedb/resources
sudo chown -R "$usernamenzb":www-data /var/www/nzedb/cli
echo
echo "$RED""PLEASE BE PATIENT!  THIS   + M A Y +   TAKE A LONG TIME!""$BLACK"
echo
sudo php /var/www/nzedb/cli/data/predb_import_daily_batch.php 0 local true
echo "$GREEN"
echo "[DONE!]"

# Fixing Install TMUX
echo "$YELLOW"
echo "---> [Installing TMUX...]""$BLACK"
sudo apt install libevent-dev git autotools-dev automake pkg-config ncurses-dev python -y > /dev/null
sudo apt remove tmux -y > /dev/null
git clone https://github.com/tmux/tmux.git --branch 2.0 --single-branch
cd tmux
./autogen.sh
./configure
make -j4
sudo make install
make clean
echo "$GREEN"
echo "[DONE!]"

echo "$YELLOW"
echo "---> [Configuring TMUX To Run On Startup...]""$BLACK"
(crontab -l 2>/dev/null; echo "@reboot /bin/sleep 10; /usr/bin/php /var/www/nzedb/misc/update/nix/tmux/start.php") | crontab -
echo "$GREEN"
echo "[DONE!]"

echo "$GREEN"
echo "---> WE ARE [DONE!]""$BLACK"
echo "To manually index run the files located in $BLUE misc/update_scripts""$BLACK"
echo "update_binaries = to GET article headers"
echo "update_releases = to CREATE releases"
echo ""
echo "To automate the process use the script located in $BLUE misc/update_scripts/nix_scripts""$BLACK"

read -r -p "Press [Enter] to continue..."

echo "$YELLOW"
echo "---> [Rebooting...]""$BLACK"
sudo reboot now
echo "$GREEN"
echo "[DONE!]""$BLACK"
