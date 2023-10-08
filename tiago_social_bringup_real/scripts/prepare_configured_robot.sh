#!/usr/bin/env bash
#
# Prepare environment for a robot that has a proper workspace already built
#
# You are safe to run this once the Web Commander is set up properly (do not try this earlier)
#
cd $(rospack find tiago_social_bringup_real)/scripts
./script_via_ssh.sh real_stop_nav_stack.sh pal pal
./script_via_ssh.sh real_install_deps.sh root palroot
