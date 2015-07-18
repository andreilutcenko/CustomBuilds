#!/bin/bash

. ./script_root.sh
. ./addhistory.sh

addhistory $0 "$@"

# mount EFI-SYSLINUX partition
root=`rootdev`
#root=/dev/sda3
syslinux=`echo ${root}|sed -e 's/\(3\|5\)/12/g'`
echo mount ${syslinux} > /dev/tty1

mkdir /tmp/mnt
mount ${syslinux} /tmp/mnt
if [ 0 -ne $? ]; then
	exit 1
fi
cd /tmp/mnt

# rewrite kernel parameter
cfgdirlist=(/boot /tmp/mnt)
for cfgdir in ${cfgdirlist[@]}; do
  cfglist=(root.A.cfg root.B.cfg usb.A.cfg)
  cd ${cfgdir}
  for cfg in ${cfglist[@]}; do
    content=`cat syslinux/${cfg}`
    content_new=`echo "${content}" | sed -e "s/i915.modeset=0/i915.modeset=1/g" -e "s/radeon.modeset=1/radeon.modeset=0/g" -e "s/nouveau.modeset=1//g"`
    if [ "${content}" != "${content_new}" ]; then
      echo modify ${cfg} > /dev/tty1
      echo "${content_new}" > syslinux/${cfg}
    fi
  done
done

#umount EFI-SYSLINUX
cd ${script_root}
umount /tmp/mnt
echo umount ${syslinux} > /dev/tty1

# disable vesa
${script_root}/disable_vesa.sh nohistory

