## Scripts for standing-up new LXC containers.

### new_ros_2_container.sh
Assumes we've already created an LXC GUI profile using `create_x11_profile.sh`. Creates a new container,
does a bunch of administrative stuff, copies a ROS 2 install script to the container, and kicks it off.
Takes about 7 minutes, on my machine.

### test_x11_profile.sh

This one is a smoke test that to see if the x11 LXD profile is going to 
work on your machine. 

Preconditions:
* Your host has an NVidia GPU.
* Your host has a working LXC installation.
* Your host's LXC installation does not already have a profile called `x11`.

Instructions:
```angular2html
git clone https://rick_armstrong@bitbucket.org/rick_armstrong/misc.git

cd misc/lxc

lxc profile create x11

cat resources/x11.profile | lxc profile edit x11

./test_x11_profile.sh glxgears
```
If all goes well, you should see the OpenGL test app `glxgears` pop up, after some waiting
(about 1.5 minutes, if you already have the latest `ubuntu:20.04` lxc image).
