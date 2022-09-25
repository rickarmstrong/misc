#!/bin/bash
# Activate the ROS environment for our project, then kick off pycharm.

# EDIT THIS: set to your installation
PYCHARM_DIR=pycharm
source ros_env.sh && /opt/${PYCHARM_DIR}/bin/pycharm.sh &
