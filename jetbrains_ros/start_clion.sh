#!/bin/bash
# Activate the ROS environment for our project, then kick off clion.

# EDIT THIS: set to your installation
CLION_PATH=/opt/clion
source ros_env.sh && ${CLION_PATH}/bin/clion.sh &
