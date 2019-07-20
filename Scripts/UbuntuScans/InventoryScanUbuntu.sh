#!/bin/bash
today="$(date)"
ipAddress=$(hostname -I)													#confirm internal IP Address
read -p "Agent Name: " agent		  										#Ask for agent name


echo "--------------------------------------------------------"
echo "-                  System Inventory                    -"   		  	#print title
echo "--------------------------------------------------------"
echo
echo
echo "Date Created: $today"
echo "Created By: $agent"
echo
echo
echo "--------------------------------------------------------"
echo "-            Operating System Information              -"
echo "--------------------------------------------------------"
echo
operatingSystem=$(lsb_release -dc)
echo "$operatingSystem"
echo
echo
services=$(systemctl list-units --type=service --state=running)
echo "Running Services"
echo "----------------"
echo "$services"
echo
echo
echo "Installed Services"
echo "-----------------"
echo
systemctl list-unit-files --type=service
echo
echo
echo "Installed Software Packages"
echo "---------------------------"
echo
dpkg -l|sed 1,3d
echo
echo
echo "Running Processes"
echo "-----------------"
echo
pstree -pnh
echo
echo
users=$(getent passwd)
systemUsers=$(getent passwd | grep -vwFf /etc/shells |awk -F: '{printf("%s:%s\n",$1,$3)}')
standardUsers=$(getent passwd | grep -wFf /etc/shells |awk -F: '{printf("%s:%s\n",$1,$3)}')
echo
echo "--------------------------------------------------------"
echo "-                    User Information                  -"
echo "--------------------------------------------------------"
echo
echo
echo "     System Users      "
echo "-----------------------"
echo
echo "System User Accounts List (Username:UID)"
echo "----------------------------------------"
echo
echo "$systemUsers"
echo
shellsCount=$(getent passwd | grep -vwFf /etc/shells|wc -l)

echo "Total System User Accounts: $shellsCount"
echo
echo "    Standard Users    "
echo "----------------------"
echo
echo "Standard User Account List (Username:UID)"
echo "-----------------------------------------"
echo
echo "$standardUsers"
echo
totalStandard=$(echo "$standardUsers" | wc -l)
echo "Total Standard User Accounts: $totalStandard"
echo
totalUsers=$(echo "$users" | wc -l)
echo "Total Users: $totalUsers"
echo
echo
echo "Group Memberships by User"
echo "-------------------------"
echo
cat /etc/passwd | awk -F':' '{ print $1}' | xargs -n1 groups
echo
echo "Logged In Users"
echo "---------------"
echo
w
echo
echo "Last Login of Each User"
echo "-----------------------"
echo
lastlog

echo
echo
echo "--------------------------------------------------------"
echo "-               Networking  Information                -"
echo "--------------------------------------------------------"
echo


ipAddress(){

  adapterName=$(sudo /sbin/ip route get 8.8.8.8 | awk '{ print $5; exit }')
  longIPAddress=$(sudo /sbin/ip route get 8.8.8.8 | awk '{ print $7 }') 	#find internal IPAddress
  _ipAddress=$(echo "$longIPAddress" | awk '{$1=$1};1')                 	#remove trailing space from longIPAddress
  ipAddress=$(hostname -I)													#confirm internal IP Address
  extipAddress=$(curl -s ifconfig.me/ip)									#pull external IP Address from website
  dfGateway=$(sudo /sbin/ip route get 8.8.8.8 | awk '{ print $3; exit }')	#find the default gateway
  macAddress=$(ip link show "$adapterName"|sed 1d |awk '{print $2}')

  echo "Adapter Name: $adapterName"
  echo "Default Gateway: $dfGateway"
  echo "IP Address: $_ipAddress"
  echo "Internal IP Address: $longIPAddress"
  echo "External IP Address: $extipAddress"
  echo "MAC Address: $macAddress"
}

ipAddress
echo
nmap --iflist |sed 1,2d
echo
echo "Routing Table"
echo "-------------"
echo
ip route show all				  							#Get the routing table
echo
echo "Interface Statistics"
echo "--------------------"
echo
ip -s link               		  							#Get interface statistics
echo
echo
echo "Ports & Services"
echo "----------------"
echo
ports=$(nmap -p 1-65535 -sV "$ipAddress"|sed 1,3d)
echo "$ports"
echo
echo "Listening Ports"
echo "---------------"
echo
ss -taulpe													#Get tcp,udp,listening,process id's,numeric ports
echo
echo
echo "Open Network Sockets"
echo "--------------------"
lsof -i					  									#List open socket files
echo
echo "Network Stat's by Protocol"
echo "--------------------------"
echo
ss -s				  										#Get network statistics by protocol
echo
echo


echo
echo "Firewall Rules"
echo "--------------"
echo
iptables -L													#List all firewall rules
echo
echo
echo "'/etc/hosts' File Contents"
echo "--------------------------"
echo 
cat /etc/hosts												#Read the /etc/hosts file
