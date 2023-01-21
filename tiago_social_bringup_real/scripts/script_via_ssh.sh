#!/usr/bin/env bash
#
# This script passes another local script to be executed via SSH on the real robot
# Might require installation of sshpass:
#     sudo apt install sshpass
#
if [ "$#" -eq 0 ]; then
    echo "You have to provide relative path to the script that will be executed remotely..."
    exit 1
fi
if [ "$#" -ge 2 ]; then
    echo "Illegal number of parameters"
    exit 2
fi

SCRIPT="$1"
TIAGO_HOSTNAME="tiago-76c"

echo "Going to execute $SCRIPT on the remote $TIAGO_HOSTNAME..."
sleep 3

# It is not possible to ask for password during execution - must already start as root (otherwise pal/pal)
cat $SCRIPT | sshpass -p 'palroot' ssh root@$TIAGO_HOSTNAME /bin/bash
