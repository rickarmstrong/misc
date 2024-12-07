#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "Usage: `basename "$0"` LXC_PROFILE_NAME"
    echo
	echo "Create a new LXC GUI profile called LXC_PROFILE_NAME. Example:"
	echo "./`basename "$0"`.sh x11"
    echo
	exit
fi
LXC_PROFILE_NAME=$1

echo "###"
echo "### Creating a new LXC profile with name $1."
echo "###"

# Populate our profile template, edit, import it to LXC.
lxc profile create ${LXC_PROFILE_NAME}
if [ $? -eq 0 ]; then
    sed "s/{{ DISPLAY }}/`echo $DISPLAY`/g" resources/x11.profile.in |
    sed "s/{{ x11_socket }}/`ls /tmp/.X11-unix/`/g" |
    sed "s/{{ gid }}/`id -u`/g" |
    sed "s/{{ uid }}/`id -g`/g" | lxc profile edit ${LXC_PROFILE_NAME}
else
  exit 1
fi

