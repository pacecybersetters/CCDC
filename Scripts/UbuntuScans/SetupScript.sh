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
# This script should be used on any Ubuntu Linux system. It will update,
# upgrade, and install the necessary components that we have outlined as
# a team.
# ---------------------------------------------------------------------
# The goal of this install script is to efficiently install relavant
# system tools quickly for effective system monitoring during the Collegiate Cyber
# Defense Competition. This tool-set represents a larger overall strategy
# and should be tailored to your specific team.

#                           VARIABLES
# ---------------------------------------------------------------------

read -p "\e[93m What is the IP Address of the Splunk Indexer? \e[0m" indexerip

#                           INITIAL UPDATE
# ---------------------------------------------------------------------

sudo apt-get update
sudo apt-get -y upgrade

#                           APT PACKAGES INSTALL
# ---------------------------------------------------------------------

sudo apt-get install -y lsof nmap clamav debsums fail2ban 


#                           LYNIS INSTALL
# ---------------------------------------------------------------------


# Uncomment and run the following commands to install lynis system audit
# sudo apt install apt-listchanges
# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C80E383C3DE9F082E01391A0366C67DE91CA5D5F
# sudo apt install -y apt-transport-https
# echo 'Acquire::Languages "none";' | sudo tee /etc/apt/apt.conf.d/99disable-translations
# echo "deb https://packages.cisofy.com/community/lynis/deb/ stable main" | sudo tee /etc/apt/sources.list.d/cisofy-lynis.list
# sudo apt update
# sudo apt install lynis


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

