#!/bin/bash
# Bash Install script for Pace CCDC Team Linux Environment
# Version 1.0.8
# Written by Daniel Barr
# 
# ---------------------------------------------------------------------
# Free to use by all teams. Please realize you are using this script
# at your own risk. The author holds no liability and will not be held
# responsible for any damages done to systems or system configurations.
# ---------------------------------------------------------------------
# This script should be used on any CentOS Linux system. It will update,
# upgrade, and install the necessary components that we have outlined as
# a team.
# ---------------------------------------------------------------------
# The goal of this install script is to efficiently install relavant
# system tools quickly for effective system monitoring during the Collegiate Cyber
# Defense Competition. This tool-set represents a larger overall strategy
# and should be tailored to your specific team.

#                            VARIABLES
# ---------------------------------------------------------------------

read -p "\e[93m What is the IP Address of the Splunk Indexer? \e[0m" indexerip

#                         INITIAL UPDATE
# ---------------------------------------------------------------------

sudo yum clean all
sudo yum -y update

#                       YUM PACKAGES INSTALL
# ---------------------------------------------------------------------

sudo yum -y install git wget redhat-lsb-core nmap yum-utils lsof epel-release

#                         CONFIG DOWNLOADS
# ---------------------------------------------------------------------

cd ~/Documents
git clone https://github.com/dbarr914/CCDC.git

#                           SPLUNK FORWARDER INSTALL
# ---------------------------------------------------------------------

download_splunk(){
 cd /tmp
 echo
 echo "\e[93m[*] Downloading Splunk Universal Forwarder.....\e[0m"
 wget -O splunkforwarder-8.tgz 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.1&product=universalforwarder&filename=splunkforwarder-8.0.1-6db836e2fb9e-Linux-x86_64.tgz&wget=true'
 echo
 echo "\e[93m[*] Splunk UFW Downloaded.\e[0m"
 echo
 }

install_splunk(){
 echo "\e[93m[*] Installing Splunk Universal Forwarder.....\e[0m"
 tar -xzvf /tmp/splunk-8.tgz -C /opt
 echo
 echo "\e[93m[*] Splunk UFW Installed.\e[0m"
 rm -f /tmp/splunk-8.tgz
}

download_splunk
install_splunk


cd /opt/splunkforwarder/bin
sudo ./splunk start --accept-license
sudo ./splunk enable boot-start
sudo ./splunk add forward-server "$indexerip":9997
sudo ./splunk restart

#                          OSQUERY INSTALL
# ---------------------------------------------------------------------

download_osquery(){
 cd /tmp
 echo
 echo "\e[93m[*] Downloading Osquery Agent.....\e[0m"
 wget https://pkg.osquery.io/rpm/osquery-4.1.1-1.linux.x86_64.rpm
 echo
 echo "\e[93m[*] Osquery Agent Downloaded.\e[0m"
 echo
 }

install_osquery(){
 echo "\e[93m[*] Installing Osquery User Agent.....\e[0m"
 sudo rpm -i osquery-4.1.1-1.linux.x86_64.rpm
 echo
 echo "\e[93m[*] Osquery Agent Installed.\e[0m"
 rm -f /tmp/osquery-4.1.1-1.linux.x86_64.rpm
}

download_osquery
install_osquery

cp ~/Documents/CCDC-master/osquery/1.Linux/osquery.conf /etc/osquery/osquery.conf
cp ~/Documents/CCDC-master/osquery/1.Linux/osquery.flags /etc/osquery/osquery.flags
cp -rf ~/Documents/CCDC-master/osquery/1.Linux/packs/ /etc/osquery/packs/
cp -rf ~/Documents/CCDC-master/osquery/1.Linux/packs/ /usr/share/osquery/packs/

osqueryctl config-check
osqueryctl start


#                         CONFIGURING INPUTS.CONF
# ---------------------------------------------------------------------

edit_inputs(){
 
 echo "[*] Editing Splunk's input file....
 cd /opt/splunkforwarder/etc/system/local 
 echo -e "[monitor:///var/log/osquery/osqueryd.results.log]\nindex = osquery\nsourcetype = osquery_results\n\n" >> inputs.conf
 echo -e "[monitor:///var/log/osquery/osqueryd.*ERROR*]\nindex = osquery\nsourcetype = osquery_error\n\n" >> inputs.conf
 echo -e "[monitor:///var/log/osquery/osqueryd.*WARNING*]\nindex = osquery\nsourcetype = osquery_warning\n\n" >> inputs.conf
 echo -e "[monitor:///var/log/osquery/osqueryd.snapshot.log\nindex = osquery\nsourcetype = osquery_results\n\n" >> inputs.conf
 echo "[*] Complete."
 echo "[*] Adding directories to monitor..." 
 
 cd /opt/splunk/bin/
 
 echo "[*] Complete."
 echo
 echo "[*] Restarting Splunk..."
 
 sudo ./splunk restart
 
 echo "[*] Complete."
 echo
}

edit_inputs
