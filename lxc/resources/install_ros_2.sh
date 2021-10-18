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

# ROS 2
sudo apt install curl gnupg2 lsb-release -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
sudo apt update
sudo apt install ros-${ROSDISTRO}-desktop -y
echo "source /opt/ros/${ROSDISTRO}/setup.bash" >> ~/.bashrc

# rosdep
sudo apt install python3-rosdep -y
sudo rosdep init
rosdep update

# colcon
sudo sh -c 'echo "deb [arch=amd64,arm64] http://repo.ros2.org/ubuntu/main `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo apt update
sudo apt install python3-colcon-common-extensions -y
echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bashrc

# DDS
echo "export ROS_DOMAIN_ID=0" >> ~/.bashrc

# For gui tools like gazebo.
echo "export DISPLAY=:0" >> ~/.bashrc
