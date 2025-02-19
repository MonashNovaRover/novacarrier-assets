HOST_INSTALL_DIRECTORY="/home/mvanwijk/novacarrier/test"
cd ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra

sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 \
-c tools/kernel_flash//flash_l4t_t234_nvme.xml -p "-c bootloader/generic/cfg/flash_t234_qspi.xml" \
--showlogs --network usb0 novacarrier internal
