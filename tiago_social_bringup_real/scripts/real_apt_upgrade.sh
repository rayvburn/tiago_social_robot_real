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

# tools
sudo -H apt-get install -y git
sudo -H apt-get install -y python-pip
# NOTE: executing as a non-root user, ref: https://superuser.com/a/1081112
sudo -i -u $USER_NONROOT bash -c 'echo; echo Installing with pip for user $USER with home at $HOME; pip install --user catkin-tools'

# CMake
# perl: warning: Falling back to a fallback locale ("en_GB.UTF-8")
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
# sudo apt purge --auto-remove cmake
sudo -H apt-get install -y software-properties-common
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
sudo apt update
sudo -H apt-get install -y cmake

sleep 1
echo
echo "Finishing script on '$HOSTNAME' host"
