#!/usr/bin/env bash
#
# Launches rosbag record of topics that allow recreating a full navigation scenario
#
# NOTE: camera-related topics should not be included as transferring them during the operation of a real robot
# is problematic
#
DEFAULT_BAG_NAME="$(date +"%Y%m%d-%H%M%S")"

# Check parameters:
if [ $# -ne 2 ]; then
  echo "Usage: $0 [<planner_id>] [<bag filename>]"
  exit 1
fi

# Desired planner_id to select
desired_planner_id="$1"
# combine args to create a name for the bag file
bag_file_name="${DEFAULT_BAG_NAME}-${desired_planner_id}-$2"

# Lists with different planner_id names
# Define a list as an array
humap_topics=(
    # "/move_base/HumapPlannerROS/cost_cloud" # very computationally expensive
    "/move_base/HumapPlannerROS/explored_trajectories"
    "/move_base/HumapPlannerROS/global_plan"
    "/move_base/HumapPlannerROS/global_plan_pruned"
    "/move_base/HumapPlannerROS/group_intrusion_alt_goal_candidates"
    "/move_base/HumapPlannerROS/group_traj_prediction"
    "/move_base/HumapPlannerROS/local_plan"
    "/move_base/HumapPlannerROS/people_traj_prediction"
    "/move_base/HumapPlannerROS/planner_state"
    "/move_base/HumapPlannerROS/ttc_prediction"
    "/move_base/HumapPlannerROS/vis/dist_obstacle"
    # "/move_base/HumapPlannerROS/vis/force_grid" # computationally expensive
    "/move_base/HumapPlannerROS/vis/marker"
    "/move_base/HumapPlannerROS/vis/marker_array"
    "/move_base/HumapPlannerROS/vis/path"
)
dwa_topics=(
    "/move_base/DWAPlannerROS/global_plan"
    "/move_base/DWAPlannerROS/local_plan"
    "/move_base/DWAPlannerROS/trajectory_cloud"
    # "/move_base/DWAPlannerROS/cost_cloud" # might be computationally expensive
)
trajectory_topics=(
  "/move_base/TrajectoryPlannerROS/global_plan"
  "/move_base/TrajectoryPlannerROS/local_plan"
  # "/move_base/TrajectoryPlannerROS/cost_cloud" # might be computationally expensive
)
teb_topics=(
    "/move_base/TebLocalPlannerROS/global_plan"
    "/move_base/TebLocalPlannerROS/local_plan"
    "/move_base/TebLocalPlannerROS/obstacles"
    "/move_base/TebLocalPlannerROS/teb_feedback"
    "/move_base/TebLocalPlannerROS/teb_markers"
    "/move_base/TebLocalPlannerROS/teb_poses"
    "/move_base/TebLocalPlannerROS/via_points"
)
cohan_topics=(
    "/move_base/CoHANLocalPlannerROS/global_plan"
    "/move_base/CoHANLocalPlannerROS/hateb_log"
    "/move_base/CoHANLocalPlannerROS/human_arrow"
    "/move_base/CoHANLocalPlannerROS/human_global_plans"
    "/move_base/CoHANLocalPlannerROS/human_local_plans"
    "/move_base/CoHANLocalPlannerROS/human_local_plans_fp_poses"
    "/move_base/CoHANLocalPlannerROS/human_local_plans_poses"
    "/move_base/CoHANLocalPlannerROS/human_local_trajs"
    "/move_base/CoHANLocalPlannerROS/human_marker"
    "/move_base/CoHANLocalPlannerROS/human_next_pose"
    "/move_base/CoHANLocalPlannerROS/human_plans_time"
    "/move_base/CoHANLocalPlannerROS/human_trajs_time"
    "/move_base/CoHANLocalPlannerROS/humans_states"
    "/move_base/CoHANLocalPlannerROS/local_plan"
    "/move_base/CoHANLocalPlannerROS/local_plan_fp_poses"
    "/move_base/CoHANLocalPlannerROS/local_plan_poses"
    "/move_base/CoHANLocalPlannerROS/local_traj"
    "/move_base/CoHANLocalPlannerROS/mode_text"
    "/move_base/CoHANLocalPlannerROS/obstacles"
    "/move_base/CoHANLocalPlannerROS/plan_time"
    "/move_base/CoHANLocalPlannerROS/robot_next_pose"
    "/move_base/CoHANLocalPlannerROS/teb_feedback"
    "/move_base/CoHANLocalPlannerROS/teb_markers"
    "/move_base/CoHANLocalPlannerROS/traj_time"
    "/move_base/CoHANLocalPlannerROS/via_points"
)
hateb_topics=(
    "/move_base/HATebLocalPlannerROS/global_plan"
    "/move_base/HATebLocalPlannerROS/human_global_plans"
    "/move_base/HATebLocalPlannerROS/human_local_plans"
    "/move_base/HATebLocalPlannerROS/human_local_plans_fp_poses"
    "/move_base/HATebLocalPlannerROS/human_local_plans_poses"
    "/move_base/HATebLocalPlannerROS/human_local_trajs"
    "/move_base/HATebLocalPlannerROS/human_plans_time"
    "/move_base/HATebLocalPlannerROS/human_trajs_time"
    "/move_base/HATebLocalPlannerROS/local_plan"
    "/move_base/HATebLocalPlannerROS/local_plan_fp_poses"
    "/move_base/HATebLocalPlannerROS/local_plan_poses"
    "/move_base/HATebLocalPlannerROS/local_traj"
    "/move_base/HATebLocalPlannerROS/obstacles"
    "/move_base/HATebLocalPlannerROS/optimization_costs"
    "/move_base/HATebLocalPlannerROS/plan_time"
    "/move_base/HATebLocalPlannerROS/teb_feedback"
    "/move_base/HATebLocalPlannerROS/teb_markers"
    "/move_base/HATebLocalPlannerROS/traj_time"
)
eband_topics=(
    "/move_base/EBandPlannerROS/eband_visualization"
    "/move_base/EBandPlannerROS/eband_visualization_array"
    "/move_base/EBandPlannerROS/global_plan"
    "/move_base/EBandPlannerROS/local_plan"
)
srl_eband_topics=(
    "/move_base/SrlEBandPlannerROS/eband_visualization"
    "/move_base/SrlEBandPlannerROS/eband_visualization_array"
    "/move_base/SrlEBandPlannerROS/global_plan"
    "/move_base/SrlEBandPlannerROS/local_plan"
    "/move_base/SrlEBandPlannerROS/repaired_path_eband_visualization_array"
    "/move_base/SrlEBandPlannerROS/repaired_plan"
    "/move_base/SrlEBandPlannerROS/the_robot_does_not_possess_the_rear_laser"
)
sarl_topics=(
    "/move_base/local_planner/action_marker"
    "/move_base/local_planner/goal_marker"
    "/move_base/local_planner/trajectory_marker"
    "/move_base/local_planner/vehicle_marker"
    "/move_base/ExternalLocalPlannerROS/external_cmd_vel"
    "/move_base/ExternalLocalPlannerROS/global_plan"
    "/move_base/ExternalLocalPlannerROS/local_goal"
)
sarl_star_topics=(
    "/move_base/local_planner/action_marker"
    "/move_base/local_planner/goal_marker"
    "/move_base/local_planner/trajectory_marker"
    "/move_base/local_planner/vehicle_marker"
    "/move_base/ExternalLocalPlannerROS/external_cmd_vel"
    "/move_base/ExternalLocalPlannerROS/global_plan"
    "/move_base/ExternalLocalPlannerROS/local_goal"
)
cadrl_topics=(
    "/move_base/local_planner/cadrl_node/computation_time"
    "/move_base/local_planner/cadrl_node/mode"
    "/move_base/local_planner/goal_path_marker"
    "/move_base/local_planner/local_path_finder/safe_actions"
    "/move_base/local_planner/other_agents_marker"
    "/move_base/local_planner/other_agents_markers"
    "/move_base/local_planner/other_vels"
    "/move_base/local_planner/path_marker"
    "/move_base/local_planner/pose_marker"
    "/move_base/ExternalLocalPlannerROS/external_cmd_vel"
    "/move_base/ExternalLocalPlannerROS/global_plan"
    "/move_base/ExternalLocalPlannerROS/local_goal"
)
drl_topics=(
    "/rl_agent/action"
    "/rl_agent/computation_time"
    "/rl_agent/done"
    "/rl_agent/planner_markers"
    "/rl_agent/trigger_agent"
    "/rl_agent/wp"
    "/rl_map"
    "/scan_narrow_rl_b"
    "/scan_narrow_rl_f"
    "/wp_reached"
    "/wp_vis1"
    "/wp_vis2"
    "/wp_vis3"
    "/wp_vis4"
    "/reward"
    "/reward_num"
    "/state_image1"
    "/state_image2"
    "/state_image3"
    "/state_image4"
    "/state_scan"
)
drl_vo_topics=(
    "/cnn_data"
    "/cnn_goal"
    "/drl_cmd_vel"
    "/drl_computation_time"
    "/robot_pose_drl_vo"
    "/scan_cloud_drl_vo"
    "/scan_combined_drl_vo_range_filter"
    "/scan_drl_vo"
    "/move_base/ExternalLocalPlannerROS/external_cmd_vel"
    "/move_base/ExternalLocalPlannerROS/global_plan"
    "/move_base/ExternalLocalPlannerROS/local_goal"
)

# Create an associative array with arrays as values
declare -A planner_array
planner_array["humap"]="${humap_topics[*]}"
planner_array["dwa"]="${dwa_topics[*]}"
planner_array["trajectory"]="${trajectory_topics[*]}"
planner_array["teb"]="${teb_topics[*]}"
planner_array["cohan"]="${cohan_topics[*]}"
planner_array["hateb"]="${hateb_topics[*]}"
planner_array["eband"]="${eband_topics[*]}"
planner_array["srl_eband"]="${srl_eband_topics[*]}"
planner_array["sarl"]="${sarl_topics[*]}"
planner_array["sarl_star"]="${sarl_star_topics[*]}"
planner_array["cadrl"]="${cadrl_topics[*]}"
planner_array["drl"]="${drl_topics[*]}"
planner_array["drl_vo"]="${drl_vo_topics[*]}"

# Check if the desired planner_id exists in the array
if [[ -n ${planner_array[$desired_planner_id]} ]]; then
    selected_list=("${planner_array[$desired_planner_id]}")
    # echo "Selected list for $desired_planner_id is: ${selected_list[@]}"
else
    echo "Planner ID '$desired_planner_id' not found."
    exit 1
fi

# Join the array elements into a single string so it can be passed to a command
IFS=, traj_planner_topics_list="${selected_list[*]}"

echo "Preparing rosbag record to a file ${bag_file_name}.bag"

# Use eval to execute the command with separate arguments
eval rosbag record --output-name ${bag_file_name} \
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
    /move_base/result \
    /move_base/status \
    /move_base/recovery_status \
    /move_base/cancel \
    /move_base/current_goal \
    /move_base/feedback \
    /move_base/global_costmap/footprint \
    /move_base/local_costmap/footprint \
    /move_base_simple/goal \
    \
    /amcl_pose \
    /mobile_base_controller/odom \
    /odom \
    /mobile_base_controller/cmd_vel \
    /mobile_base_controller/cmd_vel_out \
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
    /move_base/NavfnROS/plan \
    \
    "${traj_planner_topics_list[@]}"

if [ -f ${bag_file_name} ]; then
  echo "Finished rosbag recording. Output saved to a file ${bag_file_name}.bag"
fi
