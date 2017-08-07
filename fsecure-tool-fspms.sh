#!/bin/bash

#Variable
deblinkfspmaua="https://download.f-secure.com/corpro/pm_linux/current/fspmaua_9.01.3_amd64.deb"
deblinkfspms="https://download.f-secure.com/corpro/pm_linux/current/fspms_12.40.81151_amd64.deb"


OPTION=$(whiptail --title "Menu Box" --menu "Gestion de la solution F-Secure Policy Manager sur Linux" 15 60 4 \
"1" "Install/Reinstall/Update" \
"2" "Port Utilise" \
"3" "Tester la communication vers les serveurs F-Secure" \
"4" "Maintenance de la base" \
"5" "Backup" \
"6" "Reset admin password" 3>&1 1>&2 2>&3)
clear
exitstatus=$?
if [ $exitstatus = 0 ]; then

     if [ $OPTION = "1" ]; then
        distri=$(lsb_release -is)

        if [ $distri = "CentOS" ]
        then
        echo "CentOS";
        # Do this
        elif [ $distri = "Ubuntu" ]
        then
        echo "Ubuntu";
        # Do that
        elif [ $distri = "Debian" ] ||[ $distri = "Ubuntu" ]
        then
        echo "Debian ou Ubuntu";

           apt-get update
           dpkg --add-architecture i386
           apt-get update
           apt-get install libstdc++5 libstdc++5:i386 libstdc++6 libstdc++6:i386
        cd /tmp/
            wget -t 5 $deblinkfspmaua
            wget -t 5 $deblinkfspms


        else
        echo "Unsupported Operating System";
        fi
    fi
    if [ $OPTION = "2" ]; then
        echo "======================================="
        echo "====== PORTS F-SECURE FSPMS ==========="
        echo "======================================="
        echo ""

        cat "/etc/opt/f-secure/fspms/fspms.conf" | while  read ligne ; do

        NomProtocole=$(echo $ligne|cut -d"=" -f1)

        if [ $NomProtocole = hostModuleHttpsPort ]; then
        hosthttps=$(echo $ligne|cut -d"=" -f2)
        echo "Port de communication https : "$hosthttps
        fi
        if [ $NomProtocole = hostModulePort ]; then
        hostport=$(echo $ligne|cut -d"=" -f2)
        echo "Port de communication http : "$hostport
        fi
        if [ $NomProtocole = adminModulePort ]; then
        hostadmin=$(echo $ligne|cut -d"=" -f2)
        echo "Port de communication d'administration : "$hostadmin
        fi
        if [ $NomProtocole = adminExtensionLocalhostRestricted ]; then
        hostrestrict=$(echo $ligne|cut -d"=" -f2)
         echo "Restreindre l'accès de la console en local uniquement : "$hostrestrict
        fi
        if [ $NomProtocole = webReportingPort ]; then
        hostweb=$(echo $ligne|cut -d"=" -f2)
        echo "Port Web Reporting : "$hostweb
        fi
        done
        echo ""
    fi
else
    echo "Cancel"
fi

