#!/bin/bash
ver_num=`cat ../openwrt/.config | grep CONFIG_VERSION_NUMBER= | cut -d '=' -f 2 | tr -d  '\r'`
ver_code=`cat ../openwrt/.config | grep CONFIG_VERSION_CODE= | cut -d '=' -f 2 | tr -d  '\r'`

firmware="firmware.bin"

version_number=${ver_num//\"}
version_code=${ver_code//\"}

target_file_name="openwrt-${version_number}-${version_code}-layerscape-armv8_64b-ls1012afrwy-ext4-sdcard.img"
target_file="../openwrt/bin/targets/layerscape/armv8_64b/${target_file_name}.gz"

echo "extract file from $target_file"

cp $target_file .

gzip -d $target_file_name

# DONT cut the firmware size, change it from openwrt/.config
#dd if=$target_file_name of=$firmware bs=128M count=1
#dd if=$target_file_name of=$firmware
mv $target_file_name $firmware

size=`ls -al | grep firmware | cut -d ' ' -f 6 | tr -d '\r'`

echo "prepare build directory"

rm -rf build

mkdir -p build/data/tmp

cp $firmware build/data/tmp/$firmware

pushd build/data

tar -czf data.tar.gz *

popd

mkdir -p build/control


cat  << EOF > build/control/control
Package: gopher-firmware
Version: ${version_number}.${version_code}
Source: package/kernel/linux
SourceName: openwrt
License: GPL-2.0
Section: kernel
Architecture: aarch64_generic
Installed-Size: ${size}
Description:  Gopher SD Card firmware
EOF


cp -rf src/control build/

pushd build/control
tar -czf control.tar.gz *
popd

echo "prepare final pack"

cp build/control/control.tar.gz build/

cp build/data/data.tar.gz build/

rm -rf build/control

rm -rf build/data

cp src/debian-binary build/

pushd build

tar -czf gopher-${version_number}-${version_code}.ipk *

popd

cp build/*.ipk .
