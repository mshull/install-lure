#!/bin/bash

#
#  LURE INSTALLATION SCRIPT
#
#  By Michael Shull
#  mshull@g.harvard.edu
#  
#  This script assumes a new Ubuntu Linux server is attempting to
#  install the Lure PHP BaaS application.
#

# variables
CURRDIR="/var/www/lure/lure-master"
DIRCFG="\a<Directory $CURRDIR/>\aOptions Indexes FollowSymLinks\aAllowOverride All\aRequire all granted\a</Directory>\a"
VHOSTFILE="/etc/apache2/sites-available/000-default.conf"
NEEDUPDATE=1
DIV="\n--------------------------------------------------------------------------\n"

# functions
UPDATE () {
	if [ $NEEDUPDATE -eq 1 ]; then 
		apt-get update	
		NEEDUPDATE=0
	fi
}

CHANGEVHOST () {
	if [ -f $VHOSTFILE ]; then
		sed -i "s#DocumentRoot.*#DocumentRoot $CURRDIR $DIRCFG#" $VHOSTFILE
		echo -e "\nSUCCESS: Changed vhost to $CURRDIR";
	else
		echo -e "\nFAIL: vhost conf file not found";
	fi
}

# check if being run as root user
if [ "$(id -u)" != "0" ]; then
	echo "Installation script must be run as root"
	exit 1
fi

# start shell
echo "Installing Lure, please wait ..."

# check if php exists
if ! type "php" &> /dev/null; then
	PHP=0
else
	PHP=1
fi

# check if apache2 exists
if ! type "apache2ctl" &> /dev/null; then
	APACHE=0
else
	APACHE=1
fi

# message about Apache
if [ $APACHE -eq 0 ]; then
	echo -e "$DIV MISSING: Apache2 is not installed on this machine. Install now? $DIV"
	select yn in "yes" "no"; do	
		case $yn in
			yes ) 
				UPDATE; 
				NEEDUPDATE=0;
				apt-get install apache2 -y;
				echo -e "\nSUCCESS: Installed Apache2"; 
				break;;
			no ) 
				echo -e "\nFAIL: Lure requires Apache2, exiting installation."; 
				exit;;
		esac
	done
fi

# message about PHP
if [ $PHP -eq 0 ]; then
	echo -e "$DIV MISSING: PHP5 is not installed on this machine. Install now? $DIV"
	select yn in "yes" "no"; do
		case $yn in
			yes ) 
				UPDATE;
				apt-get install php5 -y; 				
				echo -e "\nSUCCESS: Installed PHP5."; 
				break;;
			no ) 
				echo -e "\nFAIL: Lure requires PHP5, exiting installation."; 
				exit;;
		esac
	done
fi

# install apache mod if needed
if [ $PHP -eq 0 ] || [ $APACHE -eq 0 ]; then
	echo -e "$DIV Installing Apache2 PHP5 Mod and Other Files $DIV"
	apt-get install libapache2-mod-php5
	apt-get install php5-common
	apt-get install php5-json
	apt-get install php5-sqlite
	a2enmod rewrite
	echo -e "\nSUCCESS: Installed PHP5 Mod and other files"
fi

# ask if auto-add vhost file
echo -e "$DIV Would you like us to point Apache to Lure automatically?\n\n Warning: This overwrites existing websites running on this server. \n Not recommended if you already run Apache websites on this machine. $DIV"
select yn in "yes" "no"; do	
	case $yn in
		yes ) 
			CHANGEVHOST;
			break;;
		no ) 
			break;;
	esac
done

# check for existing files and warn user of overwrite
if [ -f index.php ]; then
	echo -e "$DIV WARNING: PHP files exist in this directory. Overwrite? $DIV"
	select yn in "yes" "no"; do	
		case $yn in
			yes ) break;;
			no ) echo -e "\nFAIL: PHP files already in this directory."; exit;;
		esac
	done
fi

# download latest and unzip
echo -e "$DIV Downloading latest Lure code $DIV"
wget https://github.com/mshull/lure/archive/master.zip
unzip -o master.zip -d /var/www/lure
rm master.zip
echo -e "\nSUCCESS: Download and unzip successful"

# set permissions
echo -e "$DIV Setting Lure Directory Permissions $DIV"
chmod 755 $CURRDIR -R
echo -e "\nSUCCESS: Permission setting successful"

# restart apache
echo -e "$DIV Restarting Apache $DIV"
/etc/init.d/apache2 restart
echo -e "\nSUCCESS: Apache has been restarted"

# print out url message
echo -e "$DIV FINISHED: Lure Installation Successful $DIV"

# remove this shell script
#rm install-lure.sh

# print out url
echo -e " API URL:    http://localhost"
echo -e " Admin URL:  http://localhost/admin (un: jharvard, pw: crimson)"
echo -e " Source:     $CURRDIR\n"
echo -e " Notes:      For remote access change localhost to your domain or IP."
echo -e "             Admin contains API instructions and detailed documentation.\n"
