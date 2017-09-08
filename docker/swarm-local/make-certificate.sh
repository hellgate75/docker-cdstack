#!/bin/bash
sudo openssl req \
    -newkey rsa:2048 -nodes -x509 -days 1460 -keyout ./domain.key \
    -out ./domain.crt
# sudo openssl req \
#   -newkey rsa:4096 -nodes -sha256 -keyout ./domain.key \
#   -x509 -days 365 -out ./domain.crt
