#!/bin/bash
while :
do
clear
        echo " Which plugin do you want Configure "
        echo "1)Fusion Inventory "
        echo "2)Bar Code Scanner "
        echo "3)GLPI Dashboard "
        echo "4)Exit "
        read -p "Select option [1-4] : " option
        case $option in
        1)
        echo "###### Downloading Fusion Inventory ######"
        cd /opt/
        sudo wget https://github.com/fusioninventory/fusioninventory-for-glpi/releases/download/glpi9.4%2B2.4/fusioninventory-9.4+2.4.tar.bz2
        sudo bzip2 -d fusioninventory-9.4+2.4.tar.bz2
        sudo tar xf fusioninventory-9.4+2.4.tar
        sudo mv fusioninventory/ /var/www/html/glpi/plugins/
        ;;
        2)
        echo "###### Downloading Barcode Generator ######"
        cd /opt/
        sudo wget https://github.com/pluginsGLPI/barcode/releases/download/2.4.0/glpi-barcode-2.4.0.tar.bz2
        sudo bzip2 -d glpi-barcode-2.4.0.tar.bz2
        sudo tar xf glpi-barcode-2.4.0.tar
        sudo mv barcode/ /var/www/html/glpi/plugins/
        ;;
        3)
        echo "###### Downloading GLPI Dashboard ######"
        cd /opt/
        sudo wget https://forge.glpi-project.org/attachments/download/2294/GLPI-dashboard_plugin-0.9.8.zip
        sudo unzip GLPI-dashboard_plugin-0.9.8.zip
        sudo mv dashboard/ /var/www/html/glpi/plugins/
        ;;
        4)
        echo "#### Exiting from Setup ####"
        break
        ;;
       esac
      done
fi
