#!/bin/bash

#Variable
hotfix1240="https://download.f-secure.com/corpro/pm_linux/current/fspm-12.40-linux-hotfix-1.zip"

#FSPMS DEB / RPM
deblinkfspmaua="https://download.f-secure.com/corpro/pm_linux/current/fspmaua_9.01.3_amd64.deb"
deblinkfspms="https://download.f-secure.com/corpro/pm_linux/current/fspms_12.40.81151_amd64.deb"
rpmlinkfspmaua="https://download.f-secure.com/corpro/pm_linux/current/fspmaua-9.01.3-1.x86_64.rpm"
rpmlinkfspms="https://download.f-secure.com/corpro/pm_linux/current/fspms-12.40.81151-1.x86_64.rpm"

vdebfspmaua=$(echo $deblinkfspmaua|cut -d"/" -f7)
vrpmfspmaua=$(echo $rpmlinkfspmaua|cut -d"/" -f7)
vrpmfspms=$(echo $rpmlinkfspms|cut -d"/" -f7)


FILE="/tmp/out.$$"
GREP="/bin/grep"
# Only root can use this script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

##auto update## 

DIR="$( cd "$( dirname "$0" )" && pwd )"
configfile=$(cat $DIR/.git/config | grep "https://github.com/djfluo/fspms")

if [ ${#configfile} -gt "1" ]
then

   autoupdate=$(git diff)
   pid=${$}

   ##check update on github##
   gitpull=$(git pull)
   if [ "$gitpull" != "Already up-to-date." ]
     then
      whiptail --title "Example Dialog" --msgbox "Une mise à jour à été appliqué, le script va s'arrêter" 8 78
      kill $pid
     fi

   #check if the script has different (local edit)
   if [ -z "$autoupdate" ]
     then
      echo "Up to date"
     else
      whiptail --title "Update" --msgbox "Une mise à jour est disponible, Cliquez sur OK pour continuer" 8 78
      git reset --hard origin/master
      whiptail --title "Update" --msgbox "Mise à jour terminé, le script va s'arrêter" 8 78
      kill $pid
   fi
else
    whiptail --title "Update" --msgbox "Attention ce script n'a pas d'update automatique sans github, si vous avez réalisé un clone vous ne devez pas déplacer le script" 8 78
fi

while [ "$menu" != 1 ]; do

OPTION=$(whiptail --title "Menu Box" --menu "Gestion de la solution F-Secure Policy Manager sur Linux" 15 70 9 \
"1" "Install/Reinstall/Update" \
"2" "Port Utilise" \
"3" "Installation HotFix" \
"4" "Tester la communication vers les serveurs F-Secure" \
"5" "Maintenance de la base" \
"6" "Backup" \
"7" "Reset admin password" \
"8" "Forcer les mises à jours Policy Manager" \
"9" "!!Quitter le script!!" 3>&1 1>&2 2>&3)
clear
#exitstatus=$?
#if [ $exitstatus = 0 ]; then

     if [ "$OPTION" = "1" ]; then
       # distri=$(lsb_release -is)
	
	filename="/etc/os-release"
        while read -r ligne
        do
        catname=$(echo $ligne|cut -d"=" -f1)
        if [ "$catname" = "ID" ]; then
	distri=$(echo $ligne|cut -d"=" -f2)
	fi
	done < "$filename"
	

        if [ "$distri" = "centos" ] || [ "$distri" = '"centos"' ]
        then
        echo "centoS";
		yum update
		yum install libstd++.i686 -y
		yum install wget -y
		yum install net-tools -y
		cd /tmp/
           	rm -f /tmp/fspm*
           	wget -t 5 $rpmlinkfspmaua
           	wget -t 5 $rpmlinkfspms
              	#check bdd
           	if [ -e /var/opt/f-secure/fspms/data/h2db/fspms.h2.db ]; then
		reup=1
           	/etc/init.d/fspms stop
		NOW=$(date +"%m-%d-%Y-%T")
	   	cp /var/opt/f-secure/fspms/data/h2db/fspms.h2.db /var/opt/f-secure/fspms/data/backup/fspms.$NOW.h2.db
           	/etc/init.d/fspms start
		else
		reup=0
           	fi
           	#install
           	rpm -i /tmp/$vrpmfspmaua
           	rpm -i /tmp/$vrpmfspms
           	#suppression des paquets
           	rm -f /tmp/fspm*  
		if [ "$reup" = 1 ]; then
		/etc/init.d/fspms stop
		/opt/f-secure/fspms/bin/fspms-db-maintenance-tool
		fi
		/etc/init.d/fspms start
		/opt/f-secure/fspms/bin/fspms-config
		
        elif [ "$distri" = "Fedora" ]
        then
        echo "Fedora";
        # Do that
        elif [ "$distri" = "debian" ] || [ "$distri" = "ubuntu" ]
        then
        echo "Debian ou Ubuntu";

           apt-get update
           dpkg --add-architecture i386
           apt-get update
           apt-get install libstdc++5 libstdc++5:i386 libstdc++6 libstdc++6:i386
           cd /tmp/
	   rm -f /tmp/fspm*
           wget -t 5 $deblinkfspmaua
           wget -t 5 $deblinkfspms
           #check service fspms
           #check bdd
           if [ -e /var/opt/f-secure/fspms/data/h2db/fspms.h2.db ]; then
	   reup=1
           /etc/init.d/fspms stop
	   NOW=$(date +"%m-%d-%Y-%T")
	   cp /var/opt/f-secure/fspms/data/h2db/fspms.h2.db /var/opt/f-secure/fspms/data/backup/fspms.$NOW.h2.db
           /etc/init.d/fspms start
	   else
	   reup=0
           fi
           #install
           dpkg -i /tmp/fspmaua_*
           dpkg -i /tmp/fspms_*
           #suppression des paquets
           rm /tmp/fspm*  
	   if [ "$reup" = 1 ]; then
	   /etc/init.d/fspms stop
	   /opt/f-secure/fspms/bin/fspms-db-maintenance-tool
	   fi
	   /etc/init.d/fspms start
	   /opt/f-secure/fspms/bin/fspms-config
        else
        echo "Unsupported Operating System";
        fi
    fi
    if [ "$OPTION" = "2" ]; then
        echo "======================================="
        echo "====== PORTS F-SECURE FSPMS ==========="
        echo "======================================="
        echo ""

        filename="/etc/opt/f-secure/fspms/fspms.conf"
        while read -r ligne
        do
        NomProtocole=$(echo $ligne|cut -d"=" -f1)

        if [ $NomProtocole = hostModuleHttpsPort ]; then
		hosthttpscp=$ligne
        hosthttps=$NomProtocole
        hosthttps2=$(echo $ligne|cut -d'"' -f2)
        fi

        if [ $NomProtocole = hostModulePort ]; then
        hostportcp=$ligne
        hostport=$NomProtocole
        hostport2=$(echo $ligne|cut -d'"' -f2)
        fi

        if [ $NomProtocole = adminModulePort ]; then
        hostadmin=$(echo $ligne|cut -d"=" -f2)
        echo "Port de communication d'administration : "$hostadmin
        hostadmin=$(echo $ligne|cut -d'"' -f2)
        fi

        if [ $NomProtocole = adminExtensionLocalhostRestricted ]; then
        hostrestrict=$(echo $ligne|cut -d"=" -f2)
        echo "Restreindre l'accès de la console en local uniquement : "$hostrestrict
        hostrestrict=$(echo $ligne|cut -d'"' -f2)
        fi
        if [ $NomProtocole = webReportingPort ]; then
        hostweb=$(echo $ligne|cut -d"=" -f2)
        echo "Port Web Reporting : "$hostweb
        hostweb=$(echo $ligne|cut -d'"' -f2)
	fi
        done < "$filename"
        echo ""
                        modifpara=$(whiptail --title "Check port" --menu "Choisissez le paramètre à modifier" 15 80 5 \
                        "1" "Port de communication http : "$hostport2 \
                        "2" "Port de communication https : "$hosthttps2 \
                        "3" "Port de communication d'administration : "$hostadmin \
                        "4" "Restreindre l'accès de la console en local uniquement : "$hostrestrict \
                        "5" "Port Web Reporting : "$hostweb 3>&1 1>&2 2>&3)
                        exitpara=$?
                        if [ $exitpara = 0 ]; then
                           if [ "$modifpara" = "1" ]; then
                                Rehostport=$(whiptail --title "Change config" --inputbox "Quel est le nouveau port que vous souhaitez appliquer ?" 10 60 $hostport2 3>&1 1>&2 2>&3)
                                exits=$?
                                if [ $exits = 0 ]; then
                                        remplace=$hostport"="'"'$Rehostport'"'
                 			sed -i 's/'$hostportcp'/'$remplace'/g' $filename
					/etc/init.d/fspms stop
					/etc/init.d/fspms start
                                else
                                echo "Cancel"
                                fi
			   fi
			   if [ "$modifpara" = "2" ]; then
                                Rehosthttps=$(whiptail --title "Change config" --inputbox "Quel est le nouveau port que vous souhaitez appliquer pour le protocol HTTPS ?" 10 60 $hosthttps2 3>&1 1>&2 2>&3)
                                exits=$?
                                if [ $exits = 0 ]; then
                                        remplace=$hosthttps"="'"'$Rehosthttps'"'
                                        sed -i 's/'$hosthttpscp'/'$remplace'/g' $filename
					/etc/init.d/fspms stop
					/etc/init.d/fspms start
                                else
                                echo "Cancel"
                                fi
                          fi
                        else
                          echo "vous avez annulé"
                        fi

    fi
    if [ "$OPTION" = "4" ]; then
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
    
 if [ "$OPTION" = "3" ]; then
        echo "======================================="
        echo "============ HOTFIX INSTALL ==========="
        echo "======================================="
        echo ""

   if [ -e "/opt/f-secure/fspms/version.txt" ]
   then
      version=$(cat /opt/f-secure/fspms/version.txt)

	if [ "$version" = "12.40.81151" ]
   	then
		echo "installation hotfixe"
	   	#Install unzip
	   	apt-get install unzip -y
   		#download hotfix for 12.40.81151
   		cd /tmp
   		wget $hotfix1240
   		#unzip on /tmp
   		unzip fspm*.zip
	   	#stop service
	   	/etc/init.d/fspms stop
	   	#copy hotfix
	   	cp -f /tmp/fspm*/fspms-webapp-1-SNAPSHOT.jar /opt/f-secure/fspms/lib/
	    	#delete zip and unzip folder
	   	rm -f /tmp/fspm*.zip
	   	rm -rf /tmp/fspm*
		#add new version information
		echo "12.40.81153" > /opt/f-secure/fspms/version.txt
	   	#start service
	   	/etc/init.d/fspms start
       else
           whiptail --title "Hotfix" --msgbox "Hotfix not available for this version of Policy Manager Server" 8 78
       fi
      else
      whiptail --title "Hotfix" --msgbox "Please install Policy Manager server first" 8 78
      fi
  fi
  if [ "$OPTION" = "9" ]; then
	menu=1
  fi
#else
#    echo "Cancel"
#fi
done
