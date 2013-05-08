#!/bin/bash

# Which network?
TMOBILE=0
THREE=1

if [[ "$1" == "tmobile" ]]; then
	TMOBILE=1
	THREE=0
fi

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

# Be a router, and do nat
forward-eth0-ppp0.sh 

# dhcpd
/etc/init.d/dhcp3-server start
