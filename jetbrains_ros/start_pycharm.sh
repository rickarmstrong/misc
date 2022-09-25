#!/bin/bash
# Activate the ROS environment for our project, then kick off pycharm.

# EDIT THIS: set to your installation
PYCHARM_PATH=/opt/pycharm
source ros_env.sh && ${PYCHARM_PATH}/bin/pycharm.sh &
