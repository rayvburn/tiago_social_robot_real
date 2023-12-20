#!/usr/bin/env bash
#
# This is only executive part of the script, use piping via SSH, e.g., https://serverfault.com/a/215757
#
echo "executing script on '$HOSTNAME' host, user is '$(whoami)'"
ROS_DISTRO="melodic"
# non-root user for pip tools installation
USER_NONROOT=pal

# update apt repositories
sudo apt update

# make ros packages available via apt
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo -H apt-get install -y curl
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo apt update

# Deps acquired from rosdep for perception workspace
sudo -H apt-get install -y python-scipy
sudo -H apt-get install -y libnetpbm10-dev
sudo -H apt-get install -y ros-$ROS_DISTRO-roslint
# pkgs below should not be necessary in headless mode
# sudo -H apt-get install -y ros-$ROS_DISTRO-rqt-gui
# sudo -H apt-get install -y ros-$ROS_DISTRO-jsk-rviz-plugins
# sudo -H apt-get install -y ros-$ROS_DISTRO-rqt-gui-py
# sudo -H apt-get install -y ros-$ROS_DISTRO-jsk-topic-tools

# Deps related to navigation workspace
sudo -H apt-get install -y libsuitesparse-dev
sudo -H apt-get install -y libeigen3-dev
sudo -H apt-get install -y libsvm-dev
sudo -H apt-get install -y libsdl-dev
sudo -H apt-get install -y libsdl2-dev
sudo -H apt-get install -y libignition-common-dev
# required by Sophus library
sudo -H apt-get install -y libfmt-dev

# NOTE: python3 is required by the DRL planner (tested with Python 3.6.9)
# TIAGo's computer already has Python 3.6.9 (otherwise `makealtinstall` from sources is required)

sudo -H apt-get install -y libmove-base-msgs-dev
sudo -H apt-get install -y ros-$ROS_DISTRO-move-base-msgs
sudo -H apt-get install -y ros-$ROS_DISTRO-move-base
sudo -H apt-get install -y ros-$ROS_DISTRO-people-msgs
sudo -H apt-get install -y ros-$ROS_DISTRO-laser-filters
sudo -H apt-get install -y ros-$ROS_DISTRO-navigation-layers
sudo -H apt-get install -y ros-$ROS_DISTRO-diagnostic-updater
sudo -H apt-get install -y ros-$ROS_DISTRO-eband-local-planner
sudo -H apt-get install -y ros-$ROS_DISTRO-laser-geometry
sudo -H apt-get install -y ros-$ROS_DISTRO-pcl-conversions
sudo -H apt-get install -y ros-$ROS_DISTRO-pcl-ros
# required by some local-planner-specific nodes for sensor data processing (`tiago_social_navigation` package)
sudo -H apt-get install -y ros-$ROS_DISTRO-ira-laser-tools
# both required by the DRL-VO local planner
sudo -H apt-get install -y ros-$ROS_DISTRO-sophus
sudo -H apt-get install -y ros-$ROS_DISTRO-pointcloud-to-laserscan

# HuMAP local planner dependency
# NOTE1: Ubuntu 18 does not have 6.0 version of the library available as .deb package
# NOTE2: catkin looks for .so only in /usr/lib/x86_64-linux-gnu/, below is the ugly way for a workaround but works
if [ ! -d "/home/$USER_NONROOT/libraries/fuzzylite" ]
then
    # Build only once
    sudo -i -u $USER_NONROOT bash -c 'echo; echo Starting installation of fuzzylite library for user $USER with home at $HOME'
    sudo -i -u $USER_NONROOT bash -c 'mkdir -p $HOME/libraries'
    sudo -i -u $USER_NONROOT bash -c 'cd $HOME/libraries'
    sudo -i -u $USER_NONROOT bash -c 'git clone https://github.com/fuzzylite/fuzzylite.git'
    sudo -i -u $USER_NONROOT bash -c 'cd fuzzylite/fuzzylite'
    sudo -i -u $USER_NONROOT bash -c './build.sh'
fi
# Create symlink each time
sudo ln -s /home/$USER_NONROOT/libraries/fuzzylite/fuzzylite/release/bin/libfuzzylite.so /usr/lib/x86_64-linux-gnu/
sudo ln -s /home/$USER_NONROOT/libraries/fuzzylite/fuzzylite/release/bin/libfuzzylite.so.6.0 /usr/lib/x86_64-linux-gnu/
echo
echo "Created symlinks of the compiled library. Stat:"
sudo -i -u $USER_NONROOT bash -c 'stat /usr/lib/x86_64-linux-gnu/libfuzzylite.so'
echo
sudo -i -u $USER_NONROOT bash -c 'stat /usr/lib/x86_64-linux-gnu/libfuzzylite.so.6.0'
echo

sleep 1
echo
echo "Finishing script on '$HOSTNAME' host"
