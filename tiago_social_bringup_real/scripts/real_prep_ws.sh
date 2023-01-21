#!/usr/bin/env bash
#
# This script locally prepares workspaces for a real robot and sends it to the remote via scp
#
# Preprequisites (local):
#   sudo apt install python-rosinstall
#   sudo apt install sshpass
#
# Preprequisites (remote):
#   pip install --user catkin-tools
#
# Notes:
#   - username, password and remote address are hard-coded in this script!
#   - directory of the remote workspace is hard-coded
#   - IGN_MATH_VER=4 is also hard-coded, valid for the Ubuntu 18
#
readonly REMOTE_WS_DIR=/home/pal/.jkarwowski

readonly SCRIPT_DIR="$(realpath $(dirname $0))"
readonly WS_TEMP_DIRNAME=".temp_ws"
readonly WS_NAV_DIRNAME=ws_social_nav
readonly WS_PERCEPTION_DIRNAME=ws_perception

echo "First, make sure that the remote directory '$REMOTE_WS_DIR' exists!"
sleep 3

mkdir -p $SCRIPT_DIR/$WS_TEMP_DIRNAME
cd $SCRIPT_DIR/$WS_TEMP_DIRNAME
mkdir -p $WS_NAV_DIRNAME/src
mkdir -p $WS_PERCEPTION_DIRNAME/src

# clone repos of the first WS
cd $WS_NAV_DIRNAME/src
git clone --recurse-submodules git@github.com:rayvburn/tiago_social_robot.git -b pkg-separation
git clone --recurse-submodules git@github.com:rayvburn/tiago_social_robot_real.git -b devel
rosinstall -n . tiago_social_robot/tiago_navigation-melodic.rosinstall
rosinstall -n . tiago_social_robot_real/tiago_experiments-melodic.rosinstall

# clone repos of another WS (whose contents most likely won't change)
cd ../../$WS_PERCEPTION_DIRNAME/src
# Possible SPENCER perception problems:
# https://github.com/spencer-project/spencer_people_tracking/tree/master/detection/monocular_detectors/3rd_party#important
rosinstall -n . tiago_social_robot/tiago_perception-melodic.rosinstall
# extra (some strange errors occur on the TIAGo computer)
git clone https://github.com/ros/dynamic_reconfigure.git -b melodic-devel

# delete automatically generated rosinstalls to not copy it to remote
cd $SCRIPT_DIR/$WS_TEMP_DIRNAME
rm $WS_NAV_DIRNAME/src/.rosinstall
rm $WS_PERCEPTION_DIRNAME/src/.rosinstall

# copy to remote
cd ../..
echo "Copying '$WS_NAV_DIRNAME' directory to the remote"
sshpass -p "pal" scp -r $WS_NAV_DIRNAME pal@tiago-76c.local:$REMOTE_WS_DIR
echo "Copying '$WS_PERCEPTION_DIRNAME' directory to the remote"
sshpass -p "pal" scp -r $WS_PERCEPTION_DIRNAME pal@tiago-76c.local:$REMOTE_WS_DIR

# catkin ws config
catkin_config="cd $REMOTE_WS_DIR/$WS_NAV_DIRNAME; catkin config -DIGN_MATH_VER=4"
echo "Connecting to the remote to configure catkin workspace"
sshpass -p 'pal' ssh pal@tiago-76c.local '$catkin_config'

# delete downloaded local sources
cd $SCRIPT_DIR
rm -rf $WS_TEMP_DIRNAME

echo
echo "Now, build the workspace on the remote."
echo "See 'tiago_social_robot' pkg README for instructions."
