#!/bin/sh

# Be a router!
echo 1 > /proc/sys/net/ipv4/ip_forward 

# Nat outbound ppp stuff
/sbin/iptables -F
/sbin/iptables -t nat -F
/sbin/iptables -t mangle -F #ignore if you get an error here
/sbin/iptables -X #deletes every non-builtin chain in the table

/sbin/iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A INPUT -m state --state NEW -i eth0 -j ACCEPT
/sbin/iptables -A INPUT -p udp -m udp --dport 123 -j ACCEPT
/sbin/iptables -P INPUT DROP

/sbin/iptables -A FORWARD -i tun0 -o eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A FORWARD -i eth0 -o tun0 -j ACCEPT

/sbin/iptables -A FORWARD -i eth0 -o lo -j ACCEPT
/sbin/iptables -A FORWARD -i lo -o eth0 -j ACCEPT

/sbin/iptables -A FORWARD -i eth0 -o eth2 -j ACCEPT
/sbin/iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT

/sbin/iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE

/sbin/iptables -A FORWARD -i tun0 -o tun0 -j REJECT
