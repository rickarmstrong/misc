#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "Usage: new_ros_container CONTAINER_NAME"
    echo
	echo "Build an LXC container with ROS installed. Example"
	echo "./new_ros_container.sh ros-test"
    echo
	exit
fi

CONTAINER_NAME=$1
ROSDISTRO=melodic
LXC_IMAGE=ubuntu:18.04
CONTAINER_SCRIPT_DIR=/home/ubuntu/src

# Create the container.
echo "Creating ${CONTAINER_NAME} from lxc image: ${LXC_IMAGE}"
lxc launch ${LXC_IMAGE} ${CONTAINER_NAME} --profile default --profile gui
sleep 5

## Disable auto-upgrades...
#lxc file push ./resources/20auto-upgrades ${CONTAINER_NAME}/etc/apt/apt.conf.d/20auto-upgrades-test -p --mode 644 --uid 0 --gid 0
#
## Do a manual upgrade.
#lxc exec ${CONTAINER_NAME} -- sudo --login --user ubuntu bash -ilc "sudo apt update"
#lxc exec ${CONTAINER_NAME} -- sudo --login --user ubuntu bash -ilc "sudo apt upgrade"
#
## Push the ROS setup script.
#echo "Pushing ROS setup script."
#lxc file push ./resources/install_ros.sh ${CONTAINER_NAME}${CONTAINER_SCRIPT_DIR}/install_ros.sh -p
#
## Kick off the ROS setup script (~20 minutes).
#echo "Running setup-ros.sh on the container. Takes about 20 minutes."
#lxc exec ${CONTAINER_NAME} -- sudo --login --user ubuntu bash -ilc "/home/ubuntu/src/install_ros.sh ${ROSDISTRO}"
