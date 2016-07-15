cd `dirname $0`

THISDIR=`dirname $0`

echo " creating rpi.img "


echo " copying raspbian "
cp raspbian.img rpi.img



echo " resizing to 3gig "
qemu-img resize -f raw rpi.img 3G

echo " checking partition information "

PART_BOOT_START=$(parted rpi.img -ms unit s print | grep "^1" | cut -f 2 -d: | cut -f 1 -ds)
PART_ROOT_START=$(parted rpi.img -ms unit s print | grep "^2" | cut -f 2 -d: | cut -f 1 -ds)
echo $PART_BOOT_START $PART_ROOT_START

echo " resizing using fdisk "
fdisk rpi.img <<EOF
p
d
2
n
p
2
$PART_ROOT_START

p
w
EOF


./box-mount

echo " setup boot config to 720p with no overscan and a 32meg gfx card"
sudo tee boot/config.txt >/dev/null <<EOF

gpu_mem=32

hdmi_force_hotplug=1
hdmi_drive=2
hdmi_group=1
config_hdmi_boost=4

#set 720p with no overscan
hdmi_mode=4
disable_overscan=1

EOF

echo " disable console blank and raspi logo "
sudo tee boot/cmdline.txt >/dev/null <<EOF
dwc_otg.lpm_enable=0 console=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait logo.nologo=1 consoleblank=0
EOF


#this is needed to allow qemu to boot
sudo tee root/etc/ld.so.preload.qemu >/dev/null <<EOF

#/usr/lib/arm-linux-gnueabihf/libarmmem.so

EOF
sudo tee root/etc/ld.so.preload.card >/dev/null <<EOF

/usr/lib/arm-linux-gnueabihf/libarmmem.so

EOF

#copy fstab to qemu and card versions
sudo tee root/etc/fstab.card >/dev/null <<EOF

proc            /proc           proc    defaults          0       0
/dev/mmcblk0p1  /boot           vfat    defaults,noatime  0       2
/dev/mmcblk0p2  /               ext4    defaults,noatime  0       1

#/dev/sda2  /               ext4    defaults,noatime  0       1

EOF


#use these for qemu booting
sudo tee root/etc/fstab.qemu >/dev/null <<EOF

proc             /proc           proc    defaults          0       0
#/dev/mmcblk0p1  /boot           vfat    defaults,noatime  0       2
#/dev/mmcblk0p2  /               ext4    defaults,noatime  0       1

/dev/sda2  /               ext4    defaults,noatime  0       1

EOF


#enable built in audio
sudo tee root/etc/modules >/dev/null <<EOF

# /etc/modules: kernel modules to load at boot time.
#
# This file contains the names of kernel modules that should be loaded
# at boot time, one per line. Lines beginning with "#" are ignored.

snd-bcm2835

EOF

#enable usb mic
sudo tee root/etc/asound.conf >/dev/null <<EOF

pcm.usb
{
    type hw
    card Device
}

pcm.internal
{
    type hw
    card ALSA
}

pcm.!default
{
    type asym
    playback.pcm
    {
        type plug
        slave.pcm "internal"
    }
    capture.pcm
    {
        type plug
        slave.pcm "usb"
    }
}

ctl.!default
{
    type asym
    playback.pcm
    {
        type plug
        slave.pcm "internal"
    }
    capture.pcm
    {
        type plug
        slave.pcm "usb"
    }
}


EOF

#autorun the monster mesh on startup
sudo tee root/etc/rc.local >/dev/null <<EOF
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

# Print the IP address
_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "My IP address is %s\n" "$_IP"
fi

#run /home/pi/pi-start as root at startup if it exists
if [ -f /home/pi/pi-start ] ; then
/home/pi/pi-start &
fi

exit 0
EOF


./box-umount
