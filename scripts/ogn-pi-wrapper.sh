#!/bin/bash
# This should be run from init or similar, so it re-launches

NETWORK=$1
if [[ "$1" == "" ]]; then
   NETWORK="three"
fi

# We need to be root, sorry
if [[ "$EUID" == "0" ]]; then
   echo ""
else
   echo "Sorry, this script must be run as root"
   echo "You seem to be `whoami`"
   exit 1
fi

# Can we start?
DIAL=""
if [[ -e /dev/ttyACM0 ]]; then
   echo "USB Mobile phone detected"
   DIAL="nokia-usb-vodafone"
fi
if [[ -e /dev/ttyUSB0 ]]; then
   echo "USB Dongle detected"
   DIAL="huawei-$NETWORK"
else
   if [[ -e /dev/sr0 ]]; then
     echo "Possible USB Dongle pretending to be a CD-ROM?"
   fi
fi

# Give a helpful message if not
if [[ "$DIAL" == "" ]]; then
   echo ""
   echo "No modem devices found, sleeping for 30 seconds"
   echo ""

   sleep 30
   exit
fi

# Is PPP already running? If so, cancel it
ps ax | grep pppd | grep -vq grep
if [[ "$?" == "0" ]]; then
   echo "Existing PPPD found, killing"
   killall pppd
   sleep 5
   killall pppd
   sleep 5
   killall -9 pppd
   sleep 2
   echo "PPPD is hopefully gone, proceeding"
fi

# Ask PPP to start
pppd call $DIAL updetach
sleep 2

# Chain to the other script for now
geeknights.sh
sleep 5

# Watchdog
GOING=1
FAILS=0
CHECK=193.227.244.1
while [[ "$GOING" == "1" ]]; do
   echo ""
   ps ax | grep pppd | grep -vq grep
   if [[ "$?" == "0" ]]; then
     echo "PPPD is still running"
   else
     echo "PPPD seems to have died! Bailing"
     GOING=0
   fi

   if [[ "$GOING" == "1" ]]; then
      ping -q -c 5 $CHECK
      if [[ "$?" == "0" ]]; then
        echo "Network still responding"
        FAILS=0
      else
        echo "No response - network seems to be down! Bailing"
        # TODO Increment fails counts
        #GOING=0
      fi
   fi

   if [[ "$GOING" == "1" ]]; then
      echo ""
      echo "Will check again in 1 minute"
      sleep 60
   fi
done
