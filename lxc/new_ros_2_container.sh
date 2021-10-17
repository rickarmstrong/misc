#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "Usage: `basename "$0"` CONTAINER_NAME"
    echo
	echo "Build an LXC container with ROS 2 installed. Example"
	echo "./`basename "$0"`.sh ros-test"
    echo
	exit
fi

CONTAINER_NAME=$1
ROSDISTRO=foxy
LXC_IMAGE=ubuntu:20.04
CONTAINER_SCRIPT_DIR=/home/ubuntu/src

echo "### Creating ${CONTAINER_NAME} from lxc image: ${LXC_IMAGE}"
lxc launch ${LXC_IMAGE} ${CONTAINER_NAME} --profile default --profile gui
sleep 5

echo "### Disabling unattended/auto upgrades and rebooting..."
lxc file push ./resources/20auto-upgrades ${CONTAINER_NAME}/etc/apt/apt.conf.d/20auto-upgrades-test -p --mode 644 --uid 0 --gid 0
lxc exec ${CONTAINER_NAME} -- sudo --login --user ubuntu bash -ilc "sudo reboot"
sleep 5

# Do a manual upgrade.
echo "### Doing 'apt update'."
lxc exec ${CONTAINER_NAME} -- sudo --login --user ubuntu bash -ilc "sudo apt update"
echo "### 'Doing apt upgrade'"
lxc exec ${CONTAINER_NAME} -- sudo --login --user ubuntu bash -ilc "sudo apt upgrade -y"

# Push the ROS setup script.
echo "### Pushing ROS setup script."
lxc file push ./resources/install_ros_2.sh ${CONTAINER_NAME}${CONTAINER_SCRIPT_DIR}/install_ros_2.sh -p

echo "### Running install_ros.sh on the container. Takes about 30 minutes."
lxc exec ${CONTAINER_NAME} -- sudo --login --user ubuntu bash -ilc "/home/ubuntu/src/install_ros_2.sh ${ROSDISTRO}"
