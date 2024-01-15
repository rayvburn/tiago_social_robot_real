# tiago_social_experiments_real

A package that runs a TIAGo robot system to perform specific experiments on real hardware.

## Usage example

1. Run `tiago_manager` node on the auxiliary laptop
2. Prepare for navigation:
```sh
rosservice call tiago_undock "{}"
```
3. Run an experiment for logging, e.g.:
```sh
roslaunch tiago_social_experiments_real 012.launch publish_goal:=true local_planner:=trajectory scenario:=dynamic stage:=run
```
4. Go back to rerun the same experiment:
```sh
roslaunch tiago_social_experiments_real 012.launch local_planner:=teb scenario:=dynamic stage:=return
```
One can also publish a goal instead of running the `return` stage, e.g.:
```sh
rostopic pub /move_base_simple/goal geometry_msgs/PoseStamped --latch --file=$(rospack find tiago_social_experiments_real)/config/012_undock_pose.yaml
```
