#!/bin/bash
if [[ $# -lt 1 ]]; then
  exit 1
fi
sudo find /var/lib/kubelet/pods/ | grep $1 | grep volumes | grep -v $1\/
