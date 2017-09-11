#!/bin/bash

PID="$(ps -eaf|grep docker-containerd|grep -v grep|awk 'BEGIN {FS=OFS=" "}{print $3}')"

if ! [[ -z "$PID" ]]; then
	kill $PID &>/dev/null
	PID2="$(ps -eaf|grep custom-start-docker|awk 'BEGIN {FS=OFS=" "}{print $2}')"
	if ! [[ -z "$PID2" ]]; then
		kill $PID2 &>/dev/null
	fi
else
	echo "Docker is not running ..."
fi
exit 0
