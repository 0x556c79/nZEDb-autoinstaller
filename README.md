# nZEDb Auto Installer
nZEDb ASS is an Auto Setup Script for the nZEDb Usenet Indexer. All nZEDb dependencies will install through the Setup Script.
Drinking a cup of coffee and wait until ZEDb installed!

The idea and the source comes from [@PREngineer](https://github.com/PREngineer) | I have adapted the script and packed into a single file! This is my first bash script, I have created it to improve my knowledge on Linux.

* Testet with Ubuntu 18.04.2

## nZEDb-ass.sh

* Update System & Upgrade Apps
* Create a User for nZEDb
* Install Basic Software (curl, nano, htop, etc)
* Install Python 3 & PIP
* Install ffmpeg, mediainfo, p7zip-full, unrar and lame
* Install yEnc from Source
* Install Composer
* Install PHP 7.2 & Extensions
  * Set the right Config for nZEDb to the php.ini
  * Install yEnc decoder extension for PHP5
* Install MariaDB 10
  * Create the 'nzedb' user in MySQL and grant it permission
  * Secure Mysql installation
* Install Apache2
  * Configuring Apache2 Virtual Server Entries
* Install Media Processors
* Fix Permissions of the /var/www/nzedb folders & /var/lib/php5/sessions
* Install MemCached & APC
* Import Initial PreDB Dump into Database
* Import additional Daily Dumps into the Database
* Install TMUX to automate binaries search & release creation
* Set up TMUX to run on startup
* Reboot


* Install PPA for ZNC
* Set up ZNC to auto-start

## IMPORTANT!

###Remove AppArmo!
```
sudo /etc/init.d/apparmor stop
sudo /etc/init.d/apparmor teardown
sudo update-rc.d -f apparmor remove
sudo reboot now
```

! Follow the installer Instructions !
