#!/usr/bin/env bash
#
# This script allows to configure (on the development machine) connection with `rosmaster` running on the real robot
#
echo "Remember to run this script as 'source <NAME>'. Otherwise environment variables will not be exported properly."

# Spcicifc to real TIAGo robot
ROS_MASTER_URI_ADDR="http://192.168.18.66:11311"

# https://serverfault.com/a/1115892
IP=$(ip -brief address show wlp8s0 | awk '{print $3}' | awk -F/ '{print $1}')

export ROS_MASTER_URI=$ROS_MASTER_URI_ADDR
export ROS_IP="$IP"
export ROS_HOSTNAME=$ROS_IP

echo "Finished"
