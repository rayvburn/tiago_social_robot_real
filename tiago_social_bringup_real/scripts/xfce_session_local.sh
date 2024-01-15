#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# default, assuming that the package source code was placed directly in the 'src' directory of the workspace
readonly WS_DIR_DEFAULT=$( cd -- "$( dirname -- "$SCRIPT_DIR/../../../../.." )" &> /dev/null && pwd )
readonly ROS_DISTRO_DEFAULT="melodic"

WS_DIR="$WS_DIR_DEFAULT"
ROS_DISTRO="$ROS_DISTRO_DEFAULT"

if [ "$#" -eq 0 ]; then
    echo "No arguments passed to the script. Assuming the default workspace directory and ROS distro."
fi
if [ "$#" -eq 1 ]; then
    echo "Overriding the default workspace directory with the default ROS distro."
    WS_DIR="$1"
fi
if [ "$#" -eq 2 ]; then
    echo "Overriding the default workspace directory and the ROS distro."
    WS_DIR="$1"
    ROS_DISTRO="$2"
fi
if [ "$#" -gt 2 ]; then
    echo "Usage: xfce_session_local.sh  <path to the main directory of the local ROS workspace>  <ROS distro>"
    exit 1
fi

while true; do
    read -p "Do you wish to proceed with the workspace directory at '${WS_DIR}' and ROS distro '${ROS_DISTRO}'? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 2;;
        * ) echo "Please answer yes or no.";;
    esac
done

WORKDIR_SRC="${WS_DIR}/src"
SOURCE_ROS="source /opt/ros/${ROS_DISTRO}/setup.bash"
SOURCE_DEVEL_CMD="source ${WS_DIR}/devel/setup.bash"

# load the list of sourced packages
${SOURCE_ROS}
${SOURCE_DEVEL_CMD}

SOURCE_ROSMASTER_CMD="source $(rospack find tiago_social_bringup_real)/scripts/devel_rosmaster_conn.sh"
WORKDIR_PKG="$(rospack find tiago_social_bringup_real)/scripts"
DEVEL_TOOLS_CMD="roslaunch tiago_social_experiments_real development_tools.launch"

# start a new terminal session
xfce4-terminal --maximize \
    -T "TIAGo SSH" \
        --working-directory=${WORKDIR_SRC} \
        -e "bash -c '${SOURCE_DEVEL_CMD}; ${SOURCE_ROSMASTER_CMD}; bash'" \
        -H \
    --tab -T "Remote Scripts" \
        --working-directory=${WORKDIR_PKG} \
        -e "bash -c '${SOURCE_ROS}; ${SOURCE_DEVEL_CMD}; ${SOURCE_ROSMASTER_CMD}; bash'" \
        -H \
    --tab -T "RViz Local" \
        --working-directory=${WORKDIR_PKG} \
        -e "bash -c '${SOURCE_ROS}; ${SOURCE_DEVEL_CMD}; ${SOURCE_ROSMASTER_CMD}; echo ${DEVEL_TOOLS_CMD}; bash'" \
        -H \
    --tab -T "Diagnostics local" \
        --working-directory=${WORKDIR_PKG} \
        -e "bash -c '${SOURCE_ROS}; ${SOURCE_DEVEL_CMD}; ${SOURCE_ROSMASTER_CMD}; bash'" \
        -H
