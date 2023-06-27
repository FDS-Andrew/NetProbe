#!usr/bin/env bash

# IP and mask of local machine
ip=$(hostname -I)	# grab ip using hostname -I
mask=$(ip a | grep $ip | awk '{print $2}')	## grab network mask using ip ex: "127.xxx.xxx.xxx/xx"

# Responsive IPs and MAC Addresses
echo "Initiating ping scan..."
nmap -sn $mask --min-parallelism 10000 -T5 --host-timeout 5ms -oX ping_log.xml &> /dev/null	## ping scan the network for working ipv4 and mac, results stored in xml
echo "	Ping scan finished."

# Network IPs
xmllint --xpath '//host/address[@addrtype="ipv4"]/@addr' ping_log.xml | cut -d '"' -f 2 > ip_list.txt	## parse xml file for IP and store it in ip_list.txt

# Ports and Services
echo "Probing for open ports..."
nmap -sS -iL ip_list.txt --min-parallelism 10000 -T5 -oX port_log.xml &> /dev/null ## port scan ip_list.txt, results stored in xml
echo "	Ports and services acquired."

# OS
echo "Scanning for Operating systems..."
nmap -O -iL ip_list.txt --min-parallelism 10000 -T5 -oX os_log.xml &> /dev/null
echo "	OS scan done."

echo "Done"



