#!/usr/bin/env bash
#
# Prepare environment for a robot that has a proper workspace already built
#
# You are safe to run this once the Web Commander is set up properly (do not try this earlier)
#

# might as well be a hostname but giving IP here is more robust
ROBOT_IP="${1:-192.168.18.66}"

# Ref: https://stackoverflow.com/a/246128
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd $SCRIPT_DIR
./script_via_ssh.sh real_stop_nav_stack.sh pal pal $ROBOT_IP
./script_via_ssh.sh real_install_deps.sh root palroot $ROBOT_IP
