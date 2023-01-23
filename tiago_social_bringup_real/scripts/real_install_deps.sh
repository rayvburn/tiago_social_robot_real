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

# update GCC etc.
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

# HuBeRo local planner dependency
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
