#!/usr/bin/env bash
#
# Launches rosbag record of topics that allow recreating a full navigation scenario
#
# NOTE: camera-related topics should not be included as transferring them during the operation of a real robot
# is problematic
#
DEFAULT_BAG_NAME="$(date +"%Y%m%d-%H%M%S")"
BAG_NAME=${DEFAULT_BAG_NAME}

# Check parameters:
if [ $# -gt 1 ]; then
  echo "Usage: $0 [<bag filename>]"
  exit 1
elif [ $# -eq 1 ]; then
  BAG_NAME="$1"
fi

echo "Preparing rosbag record to a file ${BAG_NAME}.bag"

rosbag record --output-name ${BAG_NAME} \
    /clock \
    /tf \
    /tf_static \
    /map \
    \
    /robot_description \
    /dynamic_footprint_publisher/footprint_stamped \
    \
    /move_base/local_costmap/footprint_layer/footprint_stamped \
    /move_base/goal \
    /move_base/cancel \
    /move_base/global_costmap/costmap \
    /move_base/global_costmap/footprint \
    /move_base/global_costmap/costmap_updates \
    /move_base/local_costmap/costmap \
    /move_base/local_costmap/footprint \
    /move_base/local_costmap/costmap_updates \
    /move_base_simple/goal \
    \
    /mobile_base_controller/odom \
    \
    /nav_vel \
    /phone_vel \
    /joy_vel \
    \
    /scan_raw \
    /scan_combined \
    /scan \
    /scan_narrow \
    /rgbd_scan \
    /sonar_base \
    \
    /people \
    /people/grouped/marker_array \
    /people/markers \
    \
    /spencer/perception/detected_persons \
    /spencer/perception/detected_persons_composite \
    /spencer/perception/detected_persons_unfiltered \
    /spencer/perception/spatial_relations \
    /spencer/perception/tracked_groups \
    /spencer/perception/tracked_persons \
    /spencer/perception/tracked_persons_confirmed_by_HOG \
    /spencer/perception/tracked_persons_confirmed_by_HOG_and_upper_body \
    /spencer/perception/tracked_persons_confirmed_by_HOG_or_upper_body \
    /spencer/perception/tracked_persons_confirmed_by_HOG_or_upper_body_or_moving \
    /spencer/perception/tracked_persons_confirmed_by_upper_body \
    /spencer/perception/tracked_persons_moving \
    /spencer/perception/tracked_persons_not_confirmed_by_HOG_and_upper_body \
    /spencer/perception/tracked_persons_not_confirmed_by_HOG_or_upper_body \
    /spencer/perception/tracked_persons_not_confirmed_by_HOG_or_upper_body_or_moving \
    /spencer/perception/tracked_persons_orientation_fixed \
    \
    /move_base/GlobalPlanner/plan \
    \
    /move_base/HuberoPlannerROS/global_plan \
    /move_base/HuberoPlannerROS/global_plan_pruned \
    /move_base/HuberoPlannerROS/local_plan \
    /move_base/HuberoPlannerROS/planner_state \
    /move_base/HuberoPlannerROS/trajectories \
    /move_base/HuberoPlannerROS/vis/dist_obstacle \
    /move_base/HuberoPlannerROS/vis/marker \
    /move_base/HuberoPlannerROS/vis/marker_array \
    /move_base/HuberoPlannerROS/vis/path \
    \
    /move_base/DWAPlannerROS/global_plan \
    /move_base/DWAPlannerROS/local_plan \
    /move_base/DWAPlannerROS/trajectory_cloud \
    \
    /move_base/TebLocalPlannerROS/teb_markers \
    /move_base/TebLocalPlannerROS/teb_poses \
    \
    /move_base/CoHANLocalPlannerROS/teb_markers \
    /move_base/CoHANLocalPlannerROS/global_plan \
    /move_base/CoHANLocalPlannerROS/human_arrow \
    /move_base/CoHANLocalPlannerROS/human_global_plans \
    /move_base/CoHANLocalPlannerROS/human_local_plans \
    /move_base/CoHANLocalPlannerROS/human_local_plans_poses \
    /move_base/CoHANLocalPlannerROS/human_marker \
    /move_base/CoHANLocalPlannerROS/human_next_pose \
    /move_base/CoHANLocalPlannerROS/local_plan \
    /move_base/CoHANLocalPlannerROS/local_plan_poses \
    /move_base/CoHANLocalPlannerROS/mode_text \
    /move_base/CoHANLocalPlannerROS/robot_next_pose \
    /move_base/HATebLocalPlannerROS/global_plan \
    /move_base/HATebLocalPlannerROS/human_local_plans_poses \
    /move_base/HATebLocalPlannerROS/local_plan \
    /move_base/HATebLocalPlannerROS/local_plan_poses \
    /move_base/HATebLocalPlannerROS/teb_markers \
    \
    /move_base/EBandPlannerROS/eband_visualization \
    /move_base/EBandPlannerROS/eband_visualization_array \
    /move_base/EBandPlannerROS/global_plan \
    /move_base/EBandPlannerROS/local_plan \
    \
    /move_base/local_planner/action_marker \
    /move_base/local_planner/goal_marker \
    /move_base/local_planner/goal_path_marker \
    /move_base/local_planner/goal_path_marker_array \
    /move_base/local_planner/other_agents_marker \
    /move_base/local_planner/other_agents_marker_array \
    /move_base/local_planner/other_agents_markers \
    /move_base/local_planner/path_marker \
    /move_base/local_planner/path_marker_array \
    /move_base/local_planner/pose_marker \
    /move_base/local_planner/pose_marker_array \
    /move_base/local_planner/trajectory_marker \
    /move_base/local_planner/vehicle_marker \
    /move_base/local_planner/vehicle_marker_array \
    \
    /move_base/ExternalLocalPlannerROS/external_cmd_vel \
    \
    /move_base/local_planner/cadrl_node/mode \
    /move_base/local_planner/goal_path_marker \
    /move_base/local_planner/goal_path_marker_array \
    /move_base/local_planner/local_path_finder/safe_actions \
    /move_base/local_planner/other_agents_marker \
    /move_base/local_planner/other_agents_marker_array \
    /move_base/local_planner/other_agents_markers \
    /move_base/local_planner/other_vels \
    /move_base/local_planner/path_marker \
    /move_base/local_planner/path_marker_array \
    /move_base/local_planner/pose_marker \
    /move_base/local_planner/pose_marker_array

echo "Finished rosbag recording. Output saved to a file ${BAG_NAME}.bag"
