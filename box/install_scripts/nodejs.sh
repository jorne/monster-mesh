#!/usr/bin/env bash

#### NodeJS ####
NODE_FILE=node-v4.4.7-linux-armv6l
NODE_EXT=tar.xz
NODE_URL=https://nodejs.org/dist/v4.4.7/$NODE_FILE.$NODE_EXT

echo " installing nodejs "
./ssh " wget $NODE_URL "
./ssh " tar xf $NODE_FILE.$NODE_EXT "
./ssh " sudo cp -r $NODE_FILE/bin $NODE_FILE/include $NODE_FILE/lib $NODE_FILE/share /usr/local/ "
./ssh " rm -rf $NODE_FILE $NODE_FILE.$NODE_EXT "
./ssh " node --version "
./ssh " npm --version "
