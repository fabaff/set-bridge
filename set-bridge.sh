#!/bin/bash
#
# Copyright (c) 2011-2013 Fabian Affolter <fabian@affolter-engineering.ch>
# Released under the MIT license.
# 
# This bash script setup a transparent and non-permanent bridge for
# wire-tapping.
#
BRNAME=br0    # Bridge name
IFNAME1=em1   # Primary card
IFNAME2=p3p1  # Secondary card
#IFNAME3=p3p1  # Additional card

brctl_check() {
    if [ ! -e /usr/sbin/brctl ]
        then
            echo "bridge-utils is not installed. Installation starts now ..."
            yum -y install bridge-utils
    fi
}

bridge_up() {
    # Enable IP forwarding 
    echo "1" > /proc/sys/net/ipv4/ip_forward
    # Disable filtering on the bridge
    echo "0" > /proc/sys/net/bridge/bridge-nf-call-arptables
    echo "0" > /proc/sys/net/bridge/bridge-nf-call-iptables
    echo "0" > /proc/sys/net/bridge/bridge-nf-call-ip6tables
    # Stop and disable NetworkManager
    service NetworkManager stop
    systemctl disable NetworkManager
    iptables -F
    # Start bridge configuration    
    ifconfig $IFNAME1 down
    ifconfig $IFNAME2 down
    brctl addbr $BRNAME
    brctl addif $BRNAME $IFNAME1
    brctl addif $BRNAME $IFNAME2
    brctl stp $BRNAME off
#    brctl setfd $BRNAME 0
#    ifconfig $IFNAME1 0.0.0.0 up
#    ifconfig $IFNAME1 0.0.0.0 up
    ifconfig $IFNAME1 0.0.0.0 promisc up
    ifconfig $IFNAME2 0.0.0.0 promisc up
#    ifconfig $BRNAME up 0.0.0.0 up promisc -arp
#    ifconfig $BRNAME hw ether 00:11:22:33:44:55
    ifconfig $BRNAME up 0.0.0.0 up

    # ebtables rules
    ebtables -P INPUT DROP
    ebtables -P OUTPUT DROP
    ebtables -P FORWARD DROP
    ebtables -F FORWARD
    ebtables -A FORWARD -p IPv4 -j ACCEPT
    ebtables -A FORWARD -p ARP -j ACCEPT

    echo "Done...Bridge is up."
    echo "---------------------------------------------------------------------"
    brctl show $BRNAME
#    systemctl status network.service
    exit 1
}

bridge_down() {
    ifconfig $BRNAME down
    brctl delif $BRNAME $IFNAME1
    brctl delif $BRNAME $IFNAME1
    brctl delbr $BRNAME
    ifconfig $IFNAME1 down
    ifconfig $IFNAME1 down
#    systemctl restart network.service
    systemctl enable NetworkManager
    service NetworkManager restart
    echo "Done...Bridge is down and NetworkManager is controlling your interfaces."
    exit 1
}

while :
do
cat << EOF

Non-premanent Bridge creator
-------------------------------------------------------------------------------
1. Start Bridge
2. Stop Bridge
9. Quit

EOF

echo -n "Your choice? : "
read INPUT

case $INPUT in
1) bridge_up ;;
2) bridge_down ;;
9) exit ;;
*) echo "\"$INPUT\" is not valid, try again... "; sleep 1 ;;
esac
done


# Static IP address for bridge
# ifconfig $BRNAME 192.168.1.11 netmask 255.255.255.0 up
# Default route
# ip route add default via 192.168.1.1
# or (newer distros)
# ip addr add 192.168.1.10/24 dev [INTERFACE_NAME]
# default gateway
# ip route add default via [GATEWAY_ADDRESS]
# ip link set [INTERFACE_NAME] up
