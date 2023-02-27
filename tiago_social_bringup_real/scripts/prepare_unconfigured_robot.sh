#!/usr/bin/env bash
#
# Prepare workspace for robot that has not proper workspace yet or its workspace it to be rebuild
#
cd $(rospack find tiago_social_bringup_real)/scripts
./script_via_ssh.sh real_stop_nav_stack.sh pal pal
./script_via_ssh.sh real_install_deps.sh root palroot
./script_via_ssh.sh real_apt_upgrade.sh root palroot
./script_via_ssh.sh real_install_deps.sh root palroot
./real_prep_ws.sh
echo ""
echo "Now, build the workspace on the remote. Follow given instructions"
