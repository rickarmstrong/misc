#!/bin/bash
# BSD 3-Clause License
#
# Copyright (c) 2021, Rick Armstrong
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
GRAPHICS_CARD=gt1060
LXC_IMAGE=ubuntu:20.04  # focal
ROSDISTRO=foxy
IGNDISTRO=fortress
CONTAINER_SCRIPT_DIR=/home/ubuntu/src

echo "###"
echo "### Creating ${CONTAINER_NAME} from lxc image: ${LXC_IMAGE}"
echo "###"
lxc launch ${LXC_IMAGE} ${CONTAINER_NAME} --profile default --profile x11
sleep 10  # Wait for boot to completely finish so our user account will exist.

echo "###"
echo "### Waiting for LXD cloud-init to finish."
echo "###"
lxc exec ${CONTAINER_NAME} -- sudo --login --user ubuntu bash -ilc "cloud-init status --wait"
sleep 5

lxc exec ${CONTAINER_NAME} -- sudo --login --user ubuntu bash -ilc "export DISPLAY=:0; glxgears"

echo "Done."
