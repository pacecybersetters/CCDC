#!/bin/bash


sudo yum clean all
sudo yum -y update

yum -y install clamav-server clamav-data clamav-update clamav-filesystem clamav clamav-scanner-systemd clamav-devel clamav-lib clamav-server-systemd lsof redhat-lsb-core nmap wget whowatch yum-utils epel-release

yumdownloader lynis

cd /tmp
wget http://downloads.sourceforge.net/project/rkhunter/rkhunter/1.4.6/rkhunter-1.4.6.tar.gz
tar -xvf rkhunter-1.4.6.tar.gz 
cd rkhunter-1.4.6
sudo ./installer.sh --layout default --install
/usr/local/bin/rkhunter --update
/usr/local/bin/rkhunter --propupd

sudo rkhunter --check


