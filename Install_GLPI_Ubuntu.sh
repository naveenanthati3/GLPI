#!/bin/bash
set -e

if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit
fi

function update_system {
printf "\n\n############# Updating the OS ##################\n\n"
printf "\n\n############## Please wait ........  ###########\n\n"
apt-get update && apt-get upgrade -y
}

function install_mysql {
if [ -f /etc/mysql/conf.d/mysql.cnf ]; then
printf "\n\n###########  MySQL is Installed ##############\n\n"

else
printf "\n\n############## Installing Mysql ###############\n\n"
printf "\n\n########## Please wait ............ ###########\n\n"
    apt-get install mysql-server mysql-client -y
fi
}

function config_mysql {
# replace "-" with "_" for database username
#MAINDB=${USER_NAME//[^a-zA-Z0-9]/_}
read -p "Enter the DB Name for GLPI: " MAINDB
#MAINDB=naveen

#Create User in MySQL
read -p "Enter the user for GLPI_DB: " DBUSER

# create random password
#PASSWDDB="$(openssl rand -base64 12)"
read -sp "Enter the Password for GLPI_DB: " PASSWDDB
#PASSWDDB=1qaz

# If /root/.my.cnf exists then it won't ask for root password
if [ -f /root/.my.cnf ]; then

    mysql -e "CREATE DATABASE ${MAINDB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -e "CREATE USER ${DBUSER}@localhost IDENTIFIED BY '${PASSWDDB}';"
    mysql -e "GRANT ALL PRIVILEGES ON ${MAINDB}.* TO '${DBUSER}'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"

# If /root/.my.cnf doesn't exist then it'll ask for root password   
else
    echo "Please enter root user MySQL password!"
    echo "Note: password will be hidden when typing"
    read -sp rootpasswd
    mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${MAINDB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -uroot -p${rootpasswd} -e "CREATE USER ${DBUSER}@localhost IDENTIFIED BY '${PASSWDDB}';"
    mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${MAINDB}.* TO '${DBUSER}'@'localhost';"
    mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"
fi
}

function install_apache {
apt-get update && apt-get upgrade -y
printf "\n\n#########  Installing Apache2 & PHP ############\n\n"  
apt-get install apache2 php7.2 php7.2-mysql libapache2-mod-php7.2 -y
}

function install_php {
printf "\n\n#######  Installing Req'd PHP Modules ##########\n\n" 
apt-get install php7.2-json php7.2-gd php7.2-curl php7.2-mbstring php-cas -y
apt-get install php7.2-xml php7.2-cli php7.2-imap php7.2-ldap php7.2-xmlrpc php-apcu -y
}

update_system
install_mysql
config_mysql
install_apache
install_php

printf "\n\n###########  Configuring Apache2 ##############\n\n"
a2enmod rewrite
cat <<EOT >> /etc/apache2/apache2.conf
<Directory /var/www/html>
AllowOverride All
</Directory>
EOT

printf "\n\n#############  Configuring PHP ################\n\n"
sed  -i "s#max_execution_time = 30#max_execution_time = 300#g" /etc/php/7.2/apache2/php.ini
sed  -i "s#memory_limit = 128M#memory_limit = 256M#g" /etc/php/7.2/apache2/php.ini
sed  -i "s#post_max_size = 8M#post_max_size = 32M#g" /etc/php/7.2/apache2/php.ini
sed  -i "s#max_input_time = 60#max_input_time = 60#g" /etc/php/7.2/apache2/php.ini
sed  -i "s#; max_input_vars = 1000#max_input_vars = 4440#g" /etc/php/7.2/apache2/php.ini

printf "\n\n#############  Restart Apache2 ################\n\n"
service apache2 restart

printf "\n\n#############  Downloading GLPI ################\n\n"
cd /opt/
wget https://github.com/glpi-project/glpi/releases/download/9.4.5/glpi-9.4.5.tgz
tar -zxvf glpi-9.4.5.tgz
cp -rf glpi /var/www/html/
chown www-data.www-data /var/www/html/glpi/* -R

printf "\n\n#############  Configuring GLPI ################\n\n"
cat <<EOT > /etc/apache2/conf-available/glpi.conf
<Directory /var/www/html/glpi>
AllowOverride All
</Directory>

<Directory /var/www/html/glpi/config>
Options -Indexes
</Directory>

<Directory /var/www/html/glpi/files>
Options -Indexes
</Directory>
EOT

a2enconf glpi
service apache2 restart
