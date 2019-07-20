#!/bin/bash

sudo apt-get update
sudo apt-get -y upgrade

sudo apt-get install -y lsof nmap whowatch clamav debsums fail2ban 

sudo apt install apt-listchanges

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C80E383C3DE9F082E01391A0366C67DE91CA5D5F

sudo apt install -y apt-transport-https
echo 'Acquire::Languages "none";' | sudo tee /etc/apt/apt.conf.d/99disable-translations
echo "deb https://packages.cisofy.com/community/lynis/deb/ stable main" | sudo tee /etc/apt/sources.list.d/cisofy-lynis.list

sudo apt update
sudo apt install lynis

cd /tmp
wget http://downloads.sourceforge.net/project/rkhunter/rkhunter/1.4.6/rkhunter-1.4.6.tar.gz
tar -xvf rkhunter-1.4.6.tar.gz 
cd rkhunter-1.4.6
sudo ./installer.sh --layout default --install
/usr/local/bin/rkhunter --update
/usr/local/bin/rkhunter --propupd

rkhunter --check


