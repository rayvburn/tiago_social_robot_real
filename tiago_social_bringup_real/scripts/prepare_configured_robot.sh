#!/usr/bin/env bash
#
# Prepare environment for a robot that has a proper workspace already built
#
# You are safe to run this once the Web Commander is set up properly (do not try this earlier)
#

# might as well be a hostname but giving IP here is more robust
ROBOT_IP="${1:-192.168.18.66}"

cd $(rospack find tiago_social_bringup_real)/scripts
./script_via_ssh.sh real_stop_nav_stack.sh pal pal $ROBOT_IP
./script_via_ssh.sh real_install_deps.sh root palroot $ROBOT_IP
