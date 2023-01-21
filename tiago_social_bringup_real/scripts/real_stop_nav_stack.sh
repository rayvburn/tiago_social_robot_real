#!/usr/bin/env bash

source /opt/pal/ferrum/setup.bash
DELAY_CALLS=2

rosservice call /pal_startup_control/stop "app: 'localizer'"
sleep $DELAY_CALLS

rosservice call /pal_startup_control/stop "app: 'map_configuration_server'"
sleep $DELAY_CALLS

rosservice call /pal_startup_control/stop "app: 'map_server'"
sleep $DELAY_CALLS

rosservice call /pal_startup_control/stop "app: 'move_base'"
sleep $DELAY_CALLS

rosservice call /pal_startup_control/stop "app: 'navigation_sm'"
sleep $DELAY_CALLS

# app managing /pal_vo_server
rosservice call /pal_startup_control/stop "app: 'vo_server'"
sleep $DELAY_CALLS

rosservice call /pal_startup_control/stop "app: 'look_to_cmd_vel'"

echo "Finishing script execution on '$HOSTNAME' host"
