#!/bin/bash

echo "Clone source code"
#git clone https://github.com/openwrt/openwrt.git
git clone https://source.codeaurora.org/external/qoriq/qoriq-components/openwrt.git

echo "Update openwrt packages"
pushd openwrt
git checkout github.lede-project/openwrt-19.07
./scripts/feeds update -a
./scripts/feeds install -a
popd

echo "Setup config"
cp openwrt_gopher_1907 openwrt/.config
