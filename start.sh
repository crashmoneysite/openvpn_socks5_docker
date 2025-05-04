#!/bin/bash

NAME="openvpn_holder"
IMAGE="openvpn_holder"

# Start container (if not already started)
if [ ! "$(docker ps -q -f name=$IMAGE)" ]; then

    docker run \
    --hostname "${NAME}" \
    --name "${NAME}" \
    --privileged \
    --interactive \
    --detach \
    -p 9050:1080 \
    -p 8086:40000 \
    -p 2043:2053 \
    -p 1070:1090 \
    -p 1071:1091 \
    --volume "$(pwd)/config:/etc/openvpn" \
    --volume "$(pwd)/config/danted.conf:/etc/danted.conf" \
    $IMAGE

fi
