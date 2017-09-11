#!/bin/bash

PID="$(ps -eaf|grep docker-containerd|awk 'BEGIN {FS=OFS=" "}{print $2}')"

if ! [[ -z "$PID" ]]; then
	echo "Docker is running ..."
else
	echo "Docker is not running ..."
fi
