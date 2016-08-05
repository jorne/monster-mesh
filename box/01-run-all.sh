#!/usr/bin/env bash

cd `dirname $0`

./02-download.sh
./03-box-init.sh
./04-box-softboil.sh
./05-box-up.sh

#need to wait for box to be ready for login here

./06-box-setup.sh
./09-box-down.sh
