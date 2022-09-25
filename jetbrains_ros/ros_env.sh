#!/bin/bash
# NOTE: you shouldn't call this script, you should source it. This script
# assumes that this directory is in the top-level dir of a working Catkin workspace.

. ${HOME}/.bashrc

# cd to this dir (so that we can source it from anywhere).
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" > /dev/null

# Figure out what ROS distribution we're running.
IFS='/' read -r -a tokens <<< `find /opt/ros -name env.sh`
DISTRO=${tokens[3]}

# Source the base ROS environment.
. /opt/ros/${DISTRO}/setup.bash

# Load this workspace's environment.
. ../devel/setup.bash

# Uncomment this if you want to activate a virtualenv.
# . ~/venv/cmd_vel_filter/bin/activate

export ROS_MASTER_URI=http://127.0.0.1:11311
