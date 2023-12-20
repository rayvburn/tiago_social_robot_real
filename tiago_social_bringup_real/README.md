# tiago_social_bringup_real

Scripts and launch files to startup a custom navigation stack.

## Instructions

Instructions show how to prepare a real TIAGo robot to run packages from a custom workspace located on TIAGo's computer. The main goal of instruction is not to touch the read-only partition. Note that provided scripts may have the hard-coded hostname of the TIAGo robot.

### Initial setup

First, make sure that the partition on the robot's computer is read-only:

```sh
grep "[[:space:]]ro[[:space:],]" /proc/mounts
```

See [this answer](https://serverfault.com/a/349025) for the output interpretation.

**1. Install package dependencies**

You start with a clean system of the TIAGo robot and want to run some nodes that should be running on the same machine (e.g. they are sensitive to network lags).

Note that `/usr/*` etc. directories will revert to their initial state after the robot's reboot. This does not apply to `home` directory with the `pal` user, where you have to establish a workspace.

Before you try to build your custom workspace, upgrade all existing packages (`real_apt_upgrade.sh`) and install dependencies (`real_install_deps.sh`).
From my experience, upgrading `apt` packages immediately breaks communication with the `rosmaster` running on the robot so let this not be a surprise in your case.

The scripts given above can be started from the development machine and executed on the remote via SSH:

```sh
cd $(rospack find tiago_social_bringup_real)/scripts
./script_via_ssh.sh real_apt_upgrade.sh root palroot
./script_via_ssh.sh real_install_deps.sh root palroot
```

Additional arguments mark username and password to get into the remote computer.

**2. Prepare a custom workspace**

Now, prepare a custom workspace. Files in the `pal` user's `home` directory are persistent, so you have to put your workspace setup somewhere there. This allows you to execute this step only once.

The `real_prep_ws.sh` script clones all required workspace packages to the local directory and then `scp`s the directory to the remote.

Note that compared to your development machine, you may need to extend the workspace packages list with extra packages that for some reason cannot be found in the PAL system (or are pre-built so do not expose the required `include` directory).

Run the script on your development machine as:

```sh
cd $(rospack find tiago_social_bringup_real)/scripts
./real_prep_ws.sh
```

**3. Build a workspace on the remote**

A typical command should do the job, provided the workspace was prepared well in the script above.

```sh
cd <WORKSPACE>
catkin build
```

**4. Reboot**

```sh
sudo systemctl reboot
```

### Using existing setup

The instructions below are valid, provided you have proceeded with the steps from the previous section.

**1. Stopping PAL's autostarted applications**

To run a custom `move_base` configuration, you must stop the applications that start automatically and will conflict with it.

The `real_stop_nav_stack.sh` script must be called before workspace dependencies installation. In general, all services for app control will be down very soon after a finished installation.

It's best to stop the PAL's applications from the development machine as:

```sh
cd $(rospack find tiago_social_bringup_real)/scripts
./script_via_ssh.sh real_stop_nav_stack.sh pal pal
```

Do not try to run these too soon after the robot's launch since some network interfaces may not be operating properly yet. A rotating head of the robot is a good indicator of its readiness.

**2. Workspace dependencies installation**

Since during the initial setup you break `rosmaster`, sooner or later you will have to reboot the computer and will have to install workspace dependencies again. The procedure at this stage is as follows.
This step must be executed after each restart of the robot system. After the first setup, only package dependencies must be installed on the robot's computer (without upgrades of existing packages).

```sh
cd $(rospack find tiago_social_bringup_real)/scripts
./script_via_ssh.sh real_install_deps.sh root palroot
```

**3. Launch a custom configuration of the navigation stack**

Run, e.g., like this:

```sh
ssh -X pal@tiago-76c.local
source <WS_DIR>/devel/setup.bash
roslaunch tiago_social_experiments_real 012.launch
```

**4. Connecting the robot with the development machine**

To establish a ROS connection with the robot's `rosmaster`, run:

```sh
source $(rospack find tiago_social_bringup_real)/scripts/devel_rosmaster_conn.sh
```

Then, on the development machine, you can:

```sh
rviz -d $(rospack find tiago_social_navigation)/rviz/tiago_navigation.rviz
```

or simply use the provided launch file:

```sh
roslaunch tiago_social_experiments_real development_tools.launch
```

## Web diagnostics interface

TIAGo robot hosts a web diagnostics interface that is achievable at `http://tiago-<ID>.local:8080/`, e.g.: [`http://tiago-76c.local:8080/`](http://tiago-76c.local:8080/).

## Troubleshooting

- There is a common issue with the first `build` being terminated with this error:
  ```console
  CMake Error at /opt/pal/ferrum/share/costmap_2d/cmake/costmap_2dConfig.cmake:110 (message):
    Project 'costmap_2d' specifies 'include' as an include dir, which is not
    found.  It does not exist in '/opt/pal/ferrum/include'.  Check the website
    'http://wiki.ros.org/costmap_2d' for information and consider reporting the
    problem.
  ```
  This procedure should give a workaround (`costmap_2d` built from source instead of PAL's binaries will be used):
  ```sh
  cd <REMOTE_WORKSPACE>
  rm -rf .catkin_tools/ build/ devel/ logs/
  catkin config -DIGN_MATH_VER=4
  catkin build costmap_2d
  source devel/setup.bash
  catkin build tiago_social_navigation
  source devel/setup.bash
  catkin build
  ```

- The issue that occurs rather rarely is a lack of `!=` operator for `geometry_msgs::Pose` type. When building:
  ```console
  error: no match for ‘operator!=’ (operand types are ‘const _pose_type {aka const geometry_msgs::Pose_<std::allocator<void> >}’ and ‘geometry_msgs::PoseStamped_<std::allocator<void> >::_pose_type {aka geometry_msgs::Pose_<std::allocator<void> >}’)
    if (!global_plan_.empty() && orig_global_plan.back().pose != global_plan_.back().pose) {
  ```
  Solution - try to run these scripts on the remote again: `real_install_deps.sh`, `real_apt_upgrade.sh`.

- Another issue related to the TIAGo startup itself is:
  ```console
  [ WARN] [1675190396.011005121]: The rgbd_scan observation buffer has not been updated for 66.05 seconds, and it should be updated every 0.50 seconds.
  ```
  Go to the web interface, `Startup` tab and check if any nodes failed to run due to timeout. If so, start them manually, e.g., `node_doctor_head_xtion`. If this does not help, try to do a power cycle of the robot.

- If a workspace has been built successfully but during the launch, some errors occur, then it is most likely a dependency issue. Check dependencies of packages that are present in the workspace and repeat steps: `real_install_deps.sh`, rebuild the workspace, and reboot the robot's computer.

- In case of some error during compilation (given that workspace packages are all good), try to rebuild the problematic package separately with `catkin build <package>`. Errors during compilation often happen when PAL's package gets overlayed with the package from the workspace or a package from the workspace depends on some common/system package (which PAL provides in a built form). Then, try to `catkin build` again. You may also try to run `real_apt_upgrade.sh`, `real_install_deps.sh` again. The latter often helps.

- One of the packages in the workspace uses the `sophus` library which may cause the issue discussed [here](https://github.com/strasdat/Sophus/issues/247#issuecomment-630833938) when building on the robot's computer (not observed on the development machine). One workaround for the following errors has already been implemented in the workspace preparation script, but if one is still getting:
  ```console
  CMake Error at CMakeLists.txt:29 (get_target_property):
  get_target_property() called with non-existent target "Sophus::Sophus".
  ```
  then calling these on the robot's computer:
  ```sh
  cd /opt/pal/ferrum/lib/cmake/Sophus
  sudo mv SophusConfig.cmake SophusBackupConfig.backup_cmake
  ```
  might help (must be done after each reboot if recompilation is performed).

- Upgrading apt packages will most likely cause `rosmaster` connection errors.

- One may encounter wrong, unchangeable workspace path, like:
  ```console
  WARNING: Source space `/home/pal/src` does not yet exist
  ```
  Probably `catkin build` was called from the home directory. If so, delete `.catkin_tools`, `build`, `devel`, `logs` from the user's home directory.
