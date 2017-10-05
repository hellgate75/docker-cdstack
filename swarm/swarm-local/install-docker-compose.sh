#!/bin/sh
sudo curl -L "https://github.com/docker/compose/releases/download/1.16.1/docker-compose-$(uname -s)-$(uname -m)" -o /tmp/docker-compose &&
    sudo chmod 777 /tmp/docker-compose &&
    sudo cp /tmp/docker-compose /usr/local/bin/docker-compose
