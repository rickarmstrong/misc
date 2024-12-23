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

##############################################################################
# Verify that we can run a GUI application in an LXC container on this host.
# This is useful on a fresh OS install, as a smoke test to verify that we have
# it setup correctly to run stuff like Gazebo, RVIZ, etc.
##############################################################################
CONTAINER_NAME=tempcontainer
LXC_IMAGE=ubuntu:22.04
LXC_PROFILE_NAME="`date +%Y%m%d%H%M%S`.X11.profile"

echo "###"
echo "### Creating lxc GUI profile ${LXC_PROFILE_NAME}"
echo "###"
source ./create_x11_profile.sh $LXC_PROFILE_NAME

echo "###"
echo "### Creating temporary container named ${CONTAINER_NAME} from lxc image: ${LXC_IMAGE}"
echo "###"
lxc launch ${LXC_IMAGE} ${CONTAINER_NAME} --profile default --profile ${LXC_PROFILE_NAME}
sleep 10  # Wait for boot to completely finish so our user account will exist.

echo "###"
echo "### Waiting for LXD cloud-init to finish."
echo "###"
lxc exec ${CONTAINER_NAME} -- sudo --login --user ubuntu bash -ilc "cloud-init status --wait"
sleep 5

echo "###"
echo "### Starting glxgears. You should see...gears. :)"
echo "###"
lxc exec ${CONTAINER_NAME} -- sudo --login --user ubuntu bash -ilc 'export DISPLAY='"${DISPLAY}"';glxgears'

echo "###"
echo "### Cleanup: deleting container ${CONTAINER_NAME}."
echo "###"
lxc delete -f ${CONTAINER_NAME}

echo "###"
echo "### Cleanup: deleting profile ${LXC_PROFILE_NAME}."
echo "###"
lxc profile delete ${LXC_PROFILE_NAME}

echo "Done."
