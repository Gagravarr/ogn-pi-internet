#!/bin/bash
# This should be run from init or similar, so it re-launches

NETWORK=$1
if [[ "$1" == "" ]]; then
   NETWORK="three"
fi

# Can we start?
DIAL=""
if [[ -f /dev/ttyACM0 ]]; then
   echo "USB Mobile phone detected"
   DIAL="nokia-usb-vodafone"
fi
if [[ -f /dev/ttyUSB0 ]]; then
   echo "USB Dongle detected"
   DIAL="huawei-$NETWORK"
else
   if [[ -f /dev/sr0 ]]; then
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

# Ask PPP to start
pppd call $DIAL updetach

# Chain to the other script for now
geeknights.sh

# Watchdog
GOING=1
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
      else
        echo "No response - network seems to be down! Bailing"
        GOING=0
      fi
   fi

   if [[ "$GOING" == "1" ]]; then
      echo ""
      echo "Will check again in 1 minute"
      sleep 60
   fi
done
