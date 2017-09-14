#!/usr/bin/env bash
ENV_FOLDER="/home/jenkins/.jenkins"
mkdir -p "$ENV_FOLDER"
touch "$ENV_FOLDER/.env"
env | grep -v '_=' | grep -v 'no_proxy=' | sed s/=/=\\\"/1 | sed s/$/\\\"/g > "$ENV_FOLDER/.env"
sed -i 's/^/export /g' "$ENV_FOLDER/.env"
chmod 777 "$ENV_FOLDER/.env"
