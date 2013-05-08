#!/bin/bash

# Which network?
TMOBILE=0
THREE=1

if [[ "$1" == "tmobile" ]]; then
	TMOBILE=1
	THREE=0
fi

# What's the ethernet IP address?
DEFAULT_IP=`grep -A 5 "eth0 " /etc/network/interfaces | grep address | awk -F' ' '{print $2}'`
echo "Default Ethernet IP address is $DEFAULT_IP"

# Stop NetworkManager
stop network-manager 
killall NetworkManager

# Check for pppd
ps auxw | grep pppd | grep -vq grep
FOUND=$?
if [[ "$FOUND" == "1" ]]; then
	echo "pppd not found!"
	echo "Please run:"
	if [[ "$TMOBILE" == "1" ]]; then
		echo "    pppd call huawei-tmobile"
	fi
	if [[ "$THREE" == "1" ]]; then
		echo "    pppd call huawei-three"
	fi
	echo "and retry"
	exit 1
fi

# Configure ethernet
if [[ "$TMOBILE" == "1" ]]; then
	echo "Going for tmobile + opendns"
	ifconfig eth0 10.1.3.1 netmask 255.255.255.0
fi
if [[ "$THREE" == "1" ]]; then
	echo "Going for three (3) + opendns"
	ifconfig eth0 10.1.2.1 netmask 255.255.255.0
fi
ifconfig eth0:0 $DEFAULT_IP netmask 255.255.255.0

# Be a router, and do nat
forward-eth0-ppp0.sh 

# dhcpd
/etc/init.d/isc-dhcp-server start
