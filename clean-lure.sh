#!/bin/bash

#
#  LURE UNINSTALL SCRIPT
#
#  By Michael Shull
#  mshull@g.harvard.edu
#  
#  This script cleans out the server of Lure and all of its 
#  dependencies. ONLY FOR TESTING AND QA PURPOSES.
#

# variables
DIV="\n--------------------------------------------------------------------------\n"

# check if being run as root user
if [ "$(id -u)" != "0" ]; then
	echo "Installation script must be run as root"
	exit 1
fi

# warning message
echo -e "$DIV WARNING: This will remove PHP5, Apache2 and the lure-master directory. Continue? $DIV"
select yn in "yes" "no"; do	
	case $yn in
		yes ) 
			apachectl stop;
			apt-get purge libapache2-mod-php5 -y;
			apt-get purge php5-common -y;
			apt-get purge php5-json -y;
			apt-get purge php5 -y;
			apt-get purge apache2 -y;
			apt-get purge -y;
			apt-get autoremove -y;
			rm -rf /var/www/lure;
			echo -e "\nSUCCESS: Lure and it's dependencies are gone"; 
			break;;
		no ) 
			echo -e "\nFAIL: Bailed out of Lure removal"; 
			exit;;
	esac
done
