#!/bin/bash

# Stop NetworkManager
stop network-manager
killall NetworkManager

# Ethernet up
ifconfig eth0 up
dhclient eth0

# Fix wireless
ifconfig eth1 down
iwconfig eth1 mode ad-hoc
iwconfig eth1 channel 2
iwconfig eth1 essid NickAdHoc

# Configure ethernet
echo "Going for ethernet + opendns"
ifconfig eth1 up
ifconfig eth1 10.1.4.1 netmask 255.255.255.0

# Ensure the settings are right for the wireless
iwconfig eth1 essid NickAdHoc

# Do 2nd ethernet too if required
ifconfig eth2 > /dev/null
if [ "$?" -eq "0" ]; then
   echo "Enabling 2nd ethernet port too"
   ifconfig eth2 up
   ifconfig eth2 10.1.3.1 netmask 255.255.255.0
fi

# Be a router, and do nat
forward-eth1-eth0.sh 

# dhcpd
/etc/init.d/dhcp3-server stop
/etc/init.d/dhcp3-server start
