# tiago_social_bringup_real

Scripts and launch files to startup a custom navigation stack.

## Instructions

How to prepare a real TIAGo robot to run packages from this workspace.
Note that provided scripts may have the hard-coded hostname of the TIAGo robot.

### Install package dependencies

This step must be executed after each restart of the robot system. Run the script via SSH:

```sh
cd scripts
./script_via_ssh.sh real_install_deps.sh
```

### (only once) Prepare custom workspace

Prepare workspace, but only once. After the first setup, only package dependencies must be installed on the robot's computer.

```sh
cd scripts
./script_via_ssh.sh real_prep_ws.sh
```

### Launch custom configuration of the navigation stack

First, you must stop the applications that start automatically and will conflict with the custom `move_base`:

```sh
cd scripts
./script_via_ssh.sh real_stop_nav_stack.sh
```

(`real_stop_nav_stack` script may not be required to be run via SSH if you connected to the `rosmaster` of the real robot with your development machine)

Then, start the requested launch file on the robot's computer.

### Connecting to the robot with the development machine

You must establish an Internet connection with the robot. To do so, run:

```sh
source devel_rosmaster_conn.sh
```

### Web diagnostics interface

TIAGo robot hosts a web diagnostics interface that is achievable at `http://tiago-<ID>.local:8080/`, e.g.: [`http://tiago-76c.local:8080/`](http://tiago-76c.local:8080/).
