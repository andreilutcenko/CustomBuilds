#!/bin/bash
FAILCOUNT=0

isexist() {
  if [ -f $1 ]; then
    echo [OK]: $1 exists
  else
    echo [FAIL]: $1 not found
    (( FAILCOUNT++ ))
  fi
}

iscontains() {
  count=`grep "$1" $2 | wc -l`
  if [ 0 -ne ${count} ]; then
    echo [OK] $2 contains phrase "$1".
  else
    echo [FAIL] $2 doesn\'t contain phrase "$1".
    (( FAILCOUNT++))
  fi

}

# test if file is exist

while read filename; do
  isexist ${filename}
done << EOF
/lib/firmware/brcm/bcm43xx-0.fw
/lib/firmware/brcm/bcm43xx_hdr-0.fw
/lib/firmware/rt2561.bin
/lib/firmware/rt2561s.bin
/lib/firmware/rt2661.bin
/lib/firmware/rt2860.bin
/lib/firmware/rt2870.bin
/lib/firmware/rt3071.bin
/lib/firmware/rt3090.bin
/lib/firmware/rt3290.bin
/lib/firmware/rt73.bin
/lib/firmware/ipw2100-1.3-i.fw
/lib/firmware/ipw2100-1.3-p.fw
/lib/firmware/ipw2100-1.3.fw
/lib/firmware/libertas/usb8388_v9.bin
/lib/firmware/libertas/usb8682.bin
/lib/firmware/libertas/usb8388_v5.bin
/lib/firmware/libertas/sd8688_helper.bin
/lib/firmware/libertas/sd8688.bin
/lib/firmware/libertas/sd8686_v9_helper.bin
/lib/firmware/libertas/sd8686_v9.bin
/lib/firmware/libertas/sd8686_v8.bin
/lib/firmware/libertas/sd8686_v8_helper.bin
/lib/firmware/libertas/sd8682_helper.bin
/lib/firmware/libertas/sd8682.bin
/lib/firmware/libertas/sd8385_helper.bin
/lib/firmware/libertas/sd8385.bin
/lib/firmware/libertas/gspi8688_helper.bin
/lib/firmware/libertas/gspi8686_v9_helper.bin
/lib/firmware/libertas/gspi8688.bin
/lib/firmware/libertas/gspi8686_v9.bin
/lib/firmware/libertas/gspi8682_helper.bin
/lib/firmware/libertas/gspi8682.bin
/lib/firmware/libertas/cf8385.bin
/lib/firmware/libertas/cf8385_helper.bin
/lib/modules/4.4.52/kernel/drivers/net/wireless/broadcom/brcm80211/brcmsmac/brcmsmac.ko
/lib/modules/4.4.52/kernel/drivers/net/wireless/realtek/rtl818x/rtl8180/rtl818x_pci.ko
/lib/modules/4.4.52/kernel/drivers/net/wireless/marvell/libertas/libertas.ko
/lib/modules/4.4.52/kernel/drivers/net/wireless/marvell/libertas/libertas_sdio.ko
/lib/modules/4.4.52/kernel/drivers/net/wireless/marvell/libertas/usb8xxx.ko
/lib/modules/4.4.52/kernel/drivers/net/ethernet/broadcom/b44.ko
/lib/modules/4.4.52/kernel/drivers/net/ethernet/atheros/atl1c/atl1c.ko
/lib/modules/4.4.52/kernel/drivers/net/ethernet/atheros/atl1e/atl1e.ko
/lib/modules/4.4.52/kernel/drivers/net/ethernet/atheros/atlx/atl1.ko
/lib/modules/4.4.52/kernel/drivers/net/ethernet/atheros/atlx/atl2.ko
/lib/modules/4.4.52/kernel/drivers/net/ethernet/marvell/sky2.ko
/lib/modules/4.4.52/kernel/drivers/gpu/drm/vmwgfx/vmwgfx.ko
/lib/modules/4.4.52/kernel/drivers/hid/hid-lenovo.ko
/usr/lib/dri/vmwgfx_dri.so
/usr/bin/xinput_calibrator
EOF

# test if file contains specified phrases

while IFS=$'\t\n' read phrase filename; do
  iscontains "${phrase}" "${filename}"
done << EOF
CHROMEOS_AUSERVER=http://update.crosbuilder.click:44225/update	/etc/lsb-release
BEGIN PUBLIC KEY	/usr/share/update_engine/update-payload-key.pub.pem
8086:4223	/opt/myscript/hwdb/pci
8086:4224	/opt/myscript/hwdb/pci
8086:1043	/opt/myscript/hwdb/pci
EOF

# test if the size of pem is 451
pem_size=`ls -l /usr/share/update_engine/update-payload-key.pub.pem | grep -o 451`
if [ "${pem_size}" == "451" ]; then
  echo [OK]: The size of update-payload-key.pub.pem is 451 bytes.
else
  echo [FAIL]: The size of update-payload-key.pub.pem is not 451 bytes.
  (( FAILCOUNT++ ))
fi

# test if boot flag is set
rootpart=`rootdev`
rootdrv=${rootpart%?}
bootflg=`sudo dd status=none if=${rootdrv} bs=1024 count=1 | od -Ax -tx1 | grep -e '01b0.*80 00$'`
if [ -n "${bootflg}" ]; then
  echo [OK]: Boot flag of MBR Partition 1 is set.
else
  echo [FAIL]: Boot flag of MBR Partition 1 is not set.
  (( FAILCOUNT++ ))
fi

if [ 0 -eq ${FAILCOUNT} ]; then
  echo OK.
else
  echo ${FAILCOUNT} TESTS FAILED.
fi
