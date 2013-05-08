#!/bin/bash

# Stop NetworkManager
stop network-manager
killall NetworkManager

# Fix wireless
ifconfig eth1 down
iwconfig eth1 mode ad-hoc
iwconfig eth1 essid NickAdHoc

# Check for pppd
ps auxw | grep pppd | grep -vq grep
FOUND=$?
if [[ "$FOUND" == "1" ]]; then
	echo "pppd not found!"
	echo "Please run:"
	echo "    pppd call huawei-tmobile"
	echo "and retry"
	exit 1
fi

# Configure ethernet
echo "Going for vodafone + opendns"
ifconfig eth1 up
ifconfig eth1 10.1.1.1 netmask 255.255.255.0

# Be a router, and do nat
forward-eth1-ppp0.sh 

# dhcpd
/etc/init.d/dhcp3-server start
