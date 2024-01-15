#!/usr/bin/env bash

echo "Starting execution on '$HOSTNAME' host"

# on the real robot
if [ -f "/opt/pal/ferrum/setup.bash" ]
then
    source /opt/pal/ferrum/setup.bash
else
    # on the development machine
    source /opt/ros/melodic/setup.bash
fi

rosservice call /pal_startup_control/stop "app: 'localizer'"
rosservice call /pal_startup_control/stop "app: 'map_configuration_server'"
rosservice call /pal_startup_control/stop "app: 'map_server'"
rosservice call /pal_startup_control/stop "app: 'move_base'"
rosservice call /pal_startup_control/stop "app: 'navigation_sm'"
rosservice call /pal_startup_control/stop "app: 'look_to_cmd_vel'"
# app managing /pal_vo_server
# rosservice call /pal_startup_control/stop "app: 'vo_server'"

rosservice call /pal_startup_control/stop "app: 'compressed_map_publisher'"
rosservice call /pal_startup_control/stop "app: 'poi_navigation'"
rosservice call /pal_startup_control/stop "app: 'head_manager'"

echo "Finishing script execution on '$HOSTNAME' host"
