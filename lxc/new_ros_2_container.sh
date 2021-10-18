#!/bin/bash
# BSD 3-Clause License
#
# Copyright (c) 2012, Rick Armstrong
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

if [ "$#" -ne 1 ]; then
	echo "Usage: `basename "$0"` CONTAINER_NAME"
    echo
	echo "Build an LXC container with ROS 2 installed. Example"
	echo "./`basename "$0"`.sh ros-test"
    echo
	exit
fi

CONTAINER_NAME=$1
LXC_IMAGE=ubuntu:20.04
ROSDISTRO=foxy
IGNDISTRO=edifice
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

# Push the IGN setup script.
echo "### Pushing IGN setup script."
lxc file push ./resources/install_ign.sh ${CONTAINER_NAME}${CONTAINER_SCRIPT_DIR}/install_ign.sh -p

echo "### Running install_ign.sh on the container."
lxc exec ${CONTAINER_NAME} -- sudo --login --user ubuntu bash -ilc "/home/ubuntu/src/install_ign.sh ${IGNDISTRO}"

# Tools we'll need to install graphics drivers in the container.
echo "### Installing ubuntu-drivers-common."
lxc exec ${CONTAINER_NAME} -- sudo --login --user ubuntu bash -ilc "sudo apt install ubuntu-drivers-common -y"
