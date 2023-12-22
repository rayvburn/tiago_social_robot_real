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
readonly REMOTE_USER="${1:-pal}"
readonly REMOTE_HOSTNAME="${2:-tiago-76c.local}"
readonly REMOTE_WS_DIR="${3:-/home/pal/.jkarwowski}"
readonly WS_TEMP_DIRNAME="${4:-ws_ros_humap}"
# could also play with $(whereis catkin)
readonly REMOTE_CATKIN_CMD="${5:-/home/pal/.local/bin/catkin}"

# Ref: https://stackoverflow.com/a/246128
readonly SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

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

# extra dependencies of the DRL-VO
## path - see relevant section in the `tiago_navigation` rosinstall file
cd $SCRIPT_DIR/$WS_TEMP_DIRNAME/src/$WS_NAV_DIRNAME/drl_vo/drl_vo_nav/setup
## script setting up the DRL-VO dependencies
./setup_deps_common.sh

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
# below are eband planner dependencies
git clone https://github.com/ros-controls/control_toolbox.git -b melodic-devel
git clone https://github.com/ros-controls/realtime_tools.git -b melodic-devel
# the workaround below is related to the issue with one of the DRL-VO dependencies;
# TIAGo's computer has Sophus already installed, but during the compilation of `ecl_linear_algebra`,
# CMake throws "get_target_property() called with non-existent target "Sophus::Sophus"
# discussed here: https://github.com/strasdat/Sophus/issues/247#issuecomment-630833938
git clone https://github.com/strasdat/Sophus.git -b main-1.x
# path to the directory on the target machine
sophus_headers_dir="$REMOTE_WS_DIR/$WS_TEMP_DIRNAME/src/auxiliary/Sophus/sophus"
# change the content of the file stored on the host machine - replace ${sophus_INCLUDE_DIRS} which is empty (?)
sed -i \
    's#\${sophus_INCLUDE_DIRS}#'"$sophus_headers_dir"'#g' \
    $SCRIPT_DIR/$WS_TEMP_DIRNAME/src/$WS_NAV_DIRNAME/drl_vo/drl_vo_common/ecl_core/ecl_linear_algebra/CMakeLists.txt

# delete automatically generated rosinstalls to not copy it to remote
cd $SCRIPT_DIR/$WS_TEMP_DIRNAME
rm src/$WS_NAV_DIRNAME/.rosinstall*
rm src/$WS_PERCEPTION_DIRNAME/.rosinstall*

# create a (first) building script for remote
cd $SCRIPT_DIR/$WS_TEMP_DIRNAME
build_script_name="first_build_sequence.sh"
echo '#!/bin/bash' > $build_script_name
echo "cd $REMOTE_WS_DIR/$WS_TEMP_DIRNAME" >> $build_script_name
echo "catkin build costmap_2d" >> $build_script_name
echo "source devel/setup.bash" >> $build_script_name
echo "catkin build realtime_tools" >> $build_script_name
echo "source devel/setup.bash" >> $build_script_name
echo "catkin build control_toolbox" >> $build_script_name
echo "source devel/setup.bash" >> $build_script_name
echo "catkin build laser_filters dynamic_reconfigure" >> $build_script_name
echo "source devel/setup.bash" >> $build_script_name
echo "catkin build" >> $build_script_name
echo "echo" >> $build_script_name
echo 'echo "Next builds can be simply done with catkin build"' >> $build_script_name
echo "echo" >> $build_script_name
chmod +x $build_script_name

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

echo
echo "Now, build the workspace on the REMOTE"
echo "NOTE: building separate packages instead of a batch should successfully finish building process in most cases"
echo "Use the provided script in the workspace's main directory:"
echo
echo "  $WS_TEMP_DIRNAME/$build_script_name"
echo
echo "Or do it manually following these steps:"
echo
echo "$(cat $SCRIPT_DIR/$WS_TEMP_DIRNAME/$build_script_name)"
echo

# delete collected local resources
cd $SCRIPT_DIR
rm -rf $WS_TEMP_DIRNAME
