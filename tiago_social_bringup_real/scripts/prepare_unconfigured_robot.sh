#!/usr/bin/env bash
#
# Prepare workspace for robot that has not proper workspace yet or its workspace it to be rebuild
#

# might as well be a hostname but giving IP here is more robust
ROBOT_IP="${1:-192.168.18.66}"

cd $(rospack find tiago_social_bringup_real)/scripts
./script_via_ssh.sh real_stop_nav_stack.sh pal pal $ROBOT_IP
./script_via_ssh.sh real_install_deps.sh root palroot $ROBOT_IP
./script_via_ssh.sh real_apt_upgrade.sh root palroot $ROBOT_IP
./script_via_ssh.sh real_install_deps.sh root palroot $ROBOT_IP
./real_prep_ws.sh
echo ""
echo "Now, build the workspace on the remote. Follow the given instructions"
