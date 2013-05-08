ogn-pi-internet
===============
Scripts and Configuration for the OGN "Internet In A Box" Raspberry Pi Setup


Logic
=====
1) Comes up on a fixed IP address - 10.5.2.220
2) When booted, launches a screen session to run the script
3) Script sleeps until the USB dongle is detected (or a USB mobile phone)
4) When found, connects to the Internet (pre-determined rules on what AP)
5) When online, changes the IP address and starts DHCP server
6) Sets up forwarding at the iptables level
7) If the connection dies, sleeps then restarts

Builds On
=========
This should work with most debian-based Raspberry Pi Distributions

We're currently using Raspbian 2013-02-29-wheezy

Packages Required
=================
vim-gtk
psmisc
ppp
xauth
strace
isc-dhcp-server
git
usb-modeswitch
usb-modeswitch-data

TODO
====
Stuff with blinking lights to work out what it's doing at any point in time
Keepalive / watchdog on the connection
