#!/usr/bin/env bash

#### Domoticz ####
DOMOTICZ_FILE=domoticz_linux_armv7l
DOMOTICZ_EXT=tgz
DOMOTICZ_URL=http://www.domoticz.com/releases/release/$DOMOTICZ_FILE.$DOMOTICZ_EXT

echo " installing domoticz "
./ssh " wget $DOMOTICZ_URL "
./ssh " sudo mkdir -p /opt/domoticz "
./ssh " cd /opt/domoticz ; sudo tar xf ~/$DOMOTICZ_FILE.$DOMOTICZ_EXT "
./ssh " rm -rf $DOMOTICZ_FILE.$DOMOTICZ_EXT "

# start at boot
./ssh " sudo cp /opt/domoticz/domoticz.sh /etc/init.d/domoticz "
./ssh " sudo chmod +x /etc/init.d/domoticz "
./ssh " sudo update-rc.d domoticz defaults "

# change install dir
./ssh " sudo sed -i 's/DAEMON=.*/DAEMON=\/opt\/domoticz\/\$NAME/' /etc/init.d/domoticz "
