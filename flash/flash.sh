#!/bin/bash
# HOST_INSTALL_DIRECTORY="/home/mvanwijk/novacarrier/test"
# source host_setup.sh
exec > >(tee flash.log) 2>&1
export REPO_ROOT=$(dirname $(pwd))
export HOST_INSTALL_DIRECTORY="${REPO_ROOT}/build"
cd ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra

# TODO: Check lsusb

sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 \
-c tools/kernel_flash//flash_l4t_t234_nvme.xml -p "-c bootloader/generic/cfg/flash_t234_qspi.xml" \
--showlogs --network usb0 novacarrier internal
