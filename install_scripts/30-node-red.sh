#!/usr/bin/env bash

#### Node-RED ####
echo " installing node-red "
./ssh " sudo npm cache clean "
./ssh " sudo npm install -g --unsafe-perm  node-red "

#TODO start at boot
