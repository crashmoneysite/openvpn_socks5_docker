#!/bin/sh

CONFIG=$(find /etc/openvpn -type f -name "us*.ovpn" | shuf -n 1)

if [ -z "$CONFIG" ]; then
    echo "No configuration files found."
    exit 1
fi

CONFIG_PATH="$CONFIG"

killall openvpn
killall danted
sleep 3

openvpn --config "$CONFIG_PATH" --auth-user-pass /etc/openvpn/auth.txt --daemon
sleep 3
danted -D

echo "Started $CONFIG_PATH"
