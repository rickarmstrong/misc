config:
  environment.DISPLAY: :0
  environment.PULSE_SERVER: unix:/home/ubuntu/pulse-native
  nvidia.driver.capabilities: all
  nvidia.runtime: "true"
  user.user-data: |
    #cloud-config
    packages:
      - x11-apps
      - mesa-utils
description: GUI LXD profile
devices:

# This entry causes a race condition at start on LXD images that do not have /home/ubuntu until after first boot.
# We don't need audio, we'll skip it.
#   PASocket1:
#     bind: container
#     connect: unix:/run/user/1000/pulse/native
#     gid: "1000"
#     listen: unix:/home/ubuntuhttps://www.ifish.net/board/forumdisplay.php?f=9/pulse-native
#     mode: "0777"
#     security.gid: "1000"
#     security.uid: "1000"
#     type: proxy
#     uid: "1000"
  X0:
    bind: container
    connect: unix:@/tmp/.X11-unix/X0
    listen: unix:@/tmp/.X11-unix/X0
    security.gid: "1000"
    security.uid: "1000"
    type: proxy
  mygpu:
    type: gpu
name: x11
used_by: []
