#!/bin/bash
if [[ -z "$(ps -eaf | grep sonar | grep -v grep)" ]]; then
  echo "stopped"
else
  echo "running"
fi
