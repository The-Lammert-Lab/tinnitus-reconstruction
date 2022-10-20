xhost +
docker run --rm -e "DISPLAY=:1" -v /tmp/.X11-unix:/tmp/.X11-unix tinnitus-project-standalone