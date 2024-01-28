# tiago_social_experiments_real

A package that runs a TIAGo robot system to perform specific experiments on real hardware.

## Usage example

### Preliminaries

1. Assuming that the custom workspace has already been successfully compiled, stop the navigation stack and install workspace dependencies (from any machine) using:
  ```sh
  $(rospack find tiago_social_bringup_real)/scripts/prepare_configured_robot.sh
  ```
2. Run `tiago_manager` node on the auxiliary laptop
3. Undock to prepare for the navigation:
  ```sh
  rosservice call tiago_undock "{}"
  ```
4. Create a separate directory for SRPB logs so they won't pollute the user's main directory on the target machine. Search for the `tiago_social_navigation/launch/move_base.launch` and change
  ```xml
  <arg name="benchmark_log_file" default="$(env HOME)/log_$(arg global_planner)_$(arg local_planner)_$(arg costmap_contexts).txt" unless="$(arg multiple)"/>
  <arg name="benchmark_log_file" default="$(env HOME)/log_$(arg robot_namespace)_$(arg global_planner)_$(arg local_planner)_$(arg costmap_contexts).txt" if="$(arg multiple)"/>
  ```
  to:
  ```xml
  <arg name="benchmark_log_file" default="<PATH_TO_A_DIRECTORY_WITH_SRPB_LOGS>/log_$(arg global_planner)_$(arg local_planner)_$(arg costmap_contexts).txt" unless="$(arg multiple)"/>
  <arg name="benchmark_log_file" default="<PATH_TO_A_DIRECTORY_WITH_SRPB_LOGS>/log_$(arg robot_namespace)_$(arg global_planner)_$(arg local_planner)_$(arg costmap_contexts).txt" if="$(arg multiple)"/>
  ```

### On the development machine

1. Run Rviz visualization
  ```sh
  source $(rospack find tiago_social_bringup_real)/scripts/devel_rosmaster_conn.sh
  roslaunch tiago_social_experiments_real development_tools.launch
  ```
2. For the teleoperation, run this GUI application on the development machine (setting the `ROS_MASTER_URI` and `ROS_IP`):
  ```sh
  $(rospack find tiago_social_bringup_real)/scripts/devel_rosmaster_conn.sh
  rosrun rqt_robot_steering rqt_robot_steering
  ```

### On the target machine

1. Connect to the robot PC via `ssh`
  ```sh
  ssh pal@<IP>
  ```
2. Source the previously built custom workspace
  ```sh
  source <PATH_TO_THE_WORKSPACE>/devel/setup.bash
  ```
3. Run the development mode and move the robot to the initial pose of a desired scenario:
  ```sh
  roslaunch tiago_social_experiments_real 012.launch publish_goal:=false local_planner:=teb scenario:=devel
  ```
  One can also publish a goal, e.g.:
  ```sh
  rostopic pub /move_base_simple/goal geometry_msgs/PoseStamped --once --latch --file=$(rospack find tiago_social_experiments_real)/config/012/<PATH_TO_A_DESIRED_POSE>.yaml
  ```
4. Run an experiment for logging, e.g.:
  ```sh
  roslaunch tiago_social_experiments_real 012.launch publish_goal:=true global_planner:=global_planner_contexts costmap_contexts:=social_extended local_planner:=<PLANNER_ID> scenario:=<SCENARIO_NAME> stage:=run
  ```
5. Copy the SRPB logs to a separate directory and process them:
  ```sh
  $(rospack find tiago_social_experiments_real)/scripts/copy_and_process_srpb_logs.sh ~/ <PATH_TO_DIR_WITH_GROUPED_LOGS>
  ```
6. Go back to the initial pose with a planner or teleoperating (see above) to re-run the same experiment:
  ```sh
  roslaunch tiago_social_experiments_real 012.launch publish_goal:=true global_planner:=global_planner_contexts costmap_contexts:=social_extended local_planner:=<PLANNER_ID> scenario:=<SCENARIO_NAME> stage:=return
  ```
