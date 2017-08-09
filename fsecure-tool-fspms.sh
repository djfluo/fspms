#!/bin/bash


##auto update 
autoupdate=$(git diff)
pid=${$}

if [ -z "$autoupdate" ]
then
echo "Up to date"
else
whiptail --title "Update" --msgbox "Une mise à jour est disponible, Cliquez sur OK pour continuer" 8 78
git reset --hard origin/master

whiptail --title "Update" --msgbox "Mise à jour terminé, le script va s'arrêter" 8 78
kill $pid
fi


#Variable
deblinkfspmaua="https://download.f-secure.com/corpro/pm_linux/current/fspmaua_9.01.3_amd64.deb"
deblinkfspms="https://download.f-secure.com/corpro/pm_linux/current/fspms_12.40.81151_amd64.deb"


OPTION=$(whiptail --title "Menu Box" --menu "Gestion de la solution F-Secure Policy Manager sur Linux" 15 60 4 \
"1" "Install/Reinstall/Update" \
"2" "Port Utilise" \
"3" "Installation HotFix" \
"4" "Tester la communication vers les serveurs F-Secure" \
"5" "Maintenance de la base" \
"6" "Backup" \
"7" "Reset admin password" \
"8" "Update Fsecure Tools" 3>&1 1>&2 2>&3)
clear
exitstatus=$?
if [ $exitstatus = 0 ]; then

     if [ $OPTION = "1" ]; then
        distri=$(lsb_release -is)

        if [ $distri = "CentOS" ]
        then
        echo "CentOS";
        # Do this
        elif [ $distri = "Fedora" ]
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
           #check service fspms
           #check bdd
           if [ -e /var/opt/f-secure/fspms/data/h2db/fspms.h2.db ]; then
           service fspms stop
           cp /var/opt/f-secure/fspms/data/h2db/fspms.h2.db /var/opt/f-secure/fspms/data/backup/
           service fspms start
           fi
           #install
           dpkg -i /tmp/fspmaua_*
           dpkg -i /tmp/fspms_*
           #suppression des paquets
           rm /tmp/fspm*  
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
    if [ $OPTION = "4" ]; then
        echo "======================================="
        echo "========== CHECK SERVERS =============="
        echo "======================================="
        echo ""
    echo 'Merci de patientez'

     xmlshavlik=$(host -W1 xml.shavlik.com)
     xmlshavlikf=$(echo $xmlshavlik |grep "NXDOMAIN\|timed out")

     avanti=$(host -W1 xml.avanti.com)
     avantif=$(echo $avanti | grep "NXDOMAIN\|timed out")

     orsp=$(host -W1 orsp.f-secure.com)
     orspf=$(echo $orsp | grep "NXDOMAIN\|timed out")

     fsecure=$(host -W1 f-secure.com)
     fsecuref=$(echo $fsecure | grep "NXDOMAIN\|timed out")


     if [ ${#orspf} -gt 1 ]
     then
     echo  "Check orsp.f-secure.com = ERROR"
     else
     echo  "Check orsp.f-secure.com = OK"
     fi


     if [ ${#xmlshavlikf} -gt 1 ] || [ ${#avantif} -gt 1 ]
     then
     echo  "Check xml.shavlik.com and avanti = ERROR"
     else
     echo  "Check xml.shavlik.com and avanti = OK"
     fi

     if [ ${#fsecuref} -gt 1 ]
     then
     echo  "Check f-secure.com = ERROR"
     else
     echo  "Check f-secure.com = OK"
     fi
    fi
else
    echo "Cancel"
fi

