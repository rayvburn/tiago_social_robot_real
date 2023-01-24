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
readonly REMOTE_USER=pal
readonly REMOTE_HOSTNAME=tiago-76c.local
readonly REMOTE_WS_DIR=/home/pal/.jkarwowski
# could also play with $(whereis catkin)
readonly REMOTE_CATKIN_CMD=/home/pal/.local/bin/catkin

readonly SCRIPT_DIR="$(realpath $(dirname $0))"
readonly WS_TEMP_DIRNAME="ws_ros"
# subdirectory names
readonly WS_NAV_DIRNAME=social_nav
readonly WS_PERCEPTION_DIRNAME=perception

echo "First, make sure that the remote directory '$REMOTE_WS_DIR' exists!"
sleep 3

mkdir -p $SCRIPT_DIR/$WS_TEMP_DIRNAME
cd $SCRIPT_DIR/$WS_TEMP_DIRNAME
mkdir -p src/$WS_NAV_DIRNAME
mkdir -p src/$WS_PERCEPTION_DIRNAME

# clone repos of the first WS
cd $SCRIPT_DIR/$WS_TEMP_DIRNAME/src/$WS_NAV_DIRNAME
git clone --recurse-submodules git@github.com:rayvburn/tiago_social_robot.git -b pkg-separation
git clone --recurse-submodules git@github.com:rayvburn/tiago_social_robot_real.git -b devel
rosinstall -n . tiago_social_robot/tiago_navigation-melodic.rosinstall
rosinstall -n . tiago_social_robot_real/tiago_experiments-melodic.rosinstall

# clone repos of another WS (whose contents most likely won't change)
cd $SCRIPT_DIR/$WS_TEMP_DIRNAME/src/$WS_PERCEPTION_DIRNAME
# Possible SPENCER perception problems:
# https://github.com/spencer-project/spencer_people_tracking/tree/master/detection/monocular_detectors/3rd_party#important
rosinstall -n . $SCRIPT_DIR/$WS_TEMP_DIRNAME/src/$WS_NAV_DIRNAME/tiago_social_robot/tiago_perception-melodic.rosinstall

# extra (some strange errors occur on the TIAGo computer)
cd $SCRIPT_DIR/$WS_TEMP_DIRNAME/src
mkdir -p auxiliary
cd auxiliary
git clone https://github.com/ros-perception/laser_filters.git -b kinetic-devel
git clone https://github.com/ros/dynamic_reconfigure.git -b melodic-devel

# delete automatically generated rosinstalls to not copy it to remote
cd $SCRIPT_DIR/$WS_TEMP_DIRNAME
rm src/$WS_NAV_DIRNAME/.rosinstall*
rm src/$WS_PERCEPTION_DIRNAME/.rosinstall*

# copy to remote
cd $SCRIPT_DIR
echo
echo "Copying '$WS_TEMP_DIRNAME' directory into the remote '$REMOTE_WS_DIR' of '$REMOTE_HOSTNAME'"
sshpass -p "$REMOTE_USER" scp -r $WS_TEMP_DIRNAME $REMOTE_USER@$REMOTE_HOSTNAME:$REMOTE_WS_DIR

# catkin ws config - add custom compilation flag
catkin_config=$(cat <<EOF
cd $REMOTE_WS_DIR/$WS_TEMP_DIRNAME;
$REMOTE_CATKIN_CMD config -DIGN_MATH_VER=4;
EOF
)
echo "Connecting to the remote '$REMOTE_HOSTNAME' to configure catkin workspace at '$REMOTE_WS_DIR/$WS_TEMP_DIRNAME'"
echo "Command to be executed on remote:"
echo
echo "$catkin_config"
echo
echo $catkin_config | sshpass -p "$REMOTE_USER" ssh $REMOTE_USER@$REMOTE_HOSTNAME /bin/bash
echo

# delete downloaded local sources
cd $SCRIPT_DIR
rm -rf $WS_TEMP_DIRNAME

echo
echo "Now, build the workspace on the REMOTE"
echo
echo "cd $REMOTE_WS_DIR/$WS_TEMP_DIRNAME"
echo "catkin build"
echo
