#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "Usage: `basename "$0"` IGNDISTRO  "
    echo
	echo "Install Ignition, assuming the correct distribution of ROS 2 is already installed."
	echo "Example: "
	echo "./`basename "$0"` fortress"
    echo
	exit
fi
IGNDISTRO=$1

sudo apt-get update
sudo apt-get install lsb-release wget gnupg -y
sudo wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
sudo apt-get update
sudo apt-get install ignition-${IGNDISTRO} -y
