#!usr/bin/env bash


#read mask
ip=$(hostname -I)	# grab ip using hostname -I
mask=$(ip a | grep $ip | awk '{print $2}')	# grab network mask using ip
touch ping_log.gnmap
nmap -sn $mask --min-parallelism 10000 -T5 --host-timeout 1ms -oG ping_log.gnmap &> /dev/null	# get ips that are responsive
touch ip_list
cat ping_log.gnmap | grep "Host:" | cut -d '(' -f 1 | cut -d ' ' -f 2 > ip_list	# parse the log into an ip list
echo "Acquired active IPs."

## scan the ports of ip list
echo "Probing for open ports."
file="ip_list"
rm port_log.gnmap 2> /dev/null
touch port_log.gnmap
while read -r line; do
	nmap -sS $line -T5 -oG port_log.gnmap -vv --append-output &> /dev/null &	# probe ports in parallel
done < $file
wait
touch port_list
cat port_log.gnmap | grep "Ports:" > port_list	# parse port log into a list
## further parsing of the port log
echo "done"
