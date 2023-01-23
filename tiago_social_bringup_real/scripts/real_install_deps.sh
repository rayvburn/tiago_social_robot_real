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

sudo -H apt-get install -y libmove-base-msgs-dev
sudo -H apt-get install -y ros-$ROS_DISTRO-move-base-msgs
sudo -H apt-get install -y ros-$ROS_DISTRO-move-base
sudo -H apt-get install -y ros-$ROS_DISTRO-people-msgs
sudo -H apt-get install -y ros-$ROS_DISTRO-laser-filters

# hubero_local_planner dep
sudo -H apt-get install -y libfuzzylite-dev


sleep 1
echo
echo "Finishing script on '$HOSTNAME' host"
