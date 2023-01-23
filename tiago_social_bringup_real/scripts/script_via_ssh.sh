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
if [ "$#" -ge 4 ]; then
    echo "Illegal number of parameters"
    exit 2
fi

SCRIPT="$1"
TIAGO_HOSTNAME="tiago-76c"
REMOTE_USER=$2
REMOTE_PASSWORD=$3

echo "Going to execute '$SCRIPT' on the remote '$TIAGO_HOSTNAME' as '$REMOTE_USER'..."
sleep 3

# It is not possible to ask for password during execution - must already start as root (otherwise pal/pal)
cat $SCRIPT | sshpass -p "$REMOTE_PASSWORD" ssh $REMOTE_USER@$TIAGO_HOSTNAME /bin/bash
