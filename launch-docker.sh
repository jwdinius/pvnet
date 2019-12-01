# NOTE: run this from dir above scripts!
docker run -it --rm \
    -v $(pwd):/home/joe/pvnet \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=$DISPLAY \
    --name pvnet-nvidia-c \
    --net host \
    --privileged \
    --runtime=nvidia \
    pvnet-nvidia
