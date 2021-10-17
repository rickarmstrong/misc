#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "Usage: `basename "$0"` ROSDISTRO"
    echo
	echo "Install ROS 2. Example:"
	echo "./`basename "$0"` foxy"
    echo
	exit
fi

ROSDISTRO=$1

sudo apt install curl gnupg2 lsb-release -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
sudo apt update
sudo apt install ros-${ROSDISTRO}-desktop -y
echo "source /opt/ros/${ROSDISTRO}/setup.bash" >> ~/.bashrc
