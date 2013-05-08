#!/bin/sh

# Be a router!
echo 1 > /proc/sys/net/ipv4/ip_forward 

# Nat outbound ppp stuff
/sbin/iptables -F
/sbin/iptables -t nat -F
/sbin/iptables -t mangle -F #ignore if you get an error here
/sbin/iptables -X #deletes every non-builtin chain in the table

/sbin/iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A INPUT -m state --state NEW -i ! ppp0 -j ACCEPT
# only if both of the above rules succeed, use
/sbin/iptables -P INPUT DROP

/sbin/iptables -A FORWARD -i ppp0 -o eth1 -m state --state ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A FORWARD -i eth1 -o ppp0 -j ACCEPT

/sbin/iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE

/sbin/iptables -A FORWARD -i ppp0 -o ppp0 -j REJECT
