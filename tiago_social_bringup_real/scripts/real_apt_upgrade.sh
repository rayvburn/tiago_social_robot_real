#!/usr/bin/env bash
# 
# Keep in mind that apt upgrade breaks ROS operation on the robot most of the time
# 

echo "executing script on '$HOSTNAME' host, user is '$(whoami)'"

# update installed packages
sudo -H apt-get install -y software-properties-common
sudo add-apt-repository --yes ppa:ubuntu-toolchain-r/test
sudo apt update
sudo -H apt-get -y upgrade

sleep 1
echo
echo "Finishing script on '$HOSTNAME' host"
