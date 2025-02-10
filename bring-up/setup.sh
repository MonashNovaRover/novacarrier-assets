L4T_RELEASE_PACKAGE="Jetson_Linux_R36.4.3_aarch64.tbz2"
SAMPLE_FS_PACKAGE="Tegra_Linux_Sample-Root-Filesystem_R36.4.3_aarch64.tbz2"
CUSTOM_FILE_LOCATION="novacarrier-assets/bring-up"

tar xf ${L4T_RELEASE_PACKAGE}
sudo tar xpf ${SAMPLE_FS_PACKAGE} -C Linux_for_Tegra/rootfs/

# Add required files
cp ${CUSTOM_FILE_LOCATION}/novacarrier.conf Linux_for_Tegra/novacarrier.conf

cp ${CUSTOM_FILE_LOCATION}/tegra234-mb1-bct-padvoltage-p3767-dp-a03.dtsi Linux_for_Tegra/bootloader/generic/BCT/tegra234-mb1-bct-padvoltage-p3767-dp-a03.dtsi

cp ${CUSTOM_FILE_LOCATION}/tegra234-mb1-bct-pinmux-p3767-dp-a03.dtsi Linux_for_Tegra/bootloader/generic/BCT/tegra234-mb1-bct-pinmux-p3767-dp-a03.dtsi

cp ${CUSTOM_FILE_LOCATION}/tegra234-mb1-bct-gpio-p3767-dp-a03.dtsi Linux_for_Tegra/bootloader/tegra234-mb1-bct-gpio-p3767-dp-a03.dtsi

cp ${CUSTOM_FILE_LOCATION}/tegra234-mb2-bct-misc-p3767-0000.dts Linux_for_Tegra/bootloader/generic/BCT/tegra234-mb2-bct-misc-p3767-0000.dts

cp ${CUSTOM_FILE_LOCATION}/tegra234-novacarrier+p3767-0000-nv.dtb Linux_for_Tegra/kernel/dtb/tegra234-novacarrier+p3767-0000-nv.dtb


sudo ./Linux_for_Tegra/tools/l4t_flash_prerequisites.sh

sudo ./Linux_for_Tegra/apply_binaries.sh

# Create default user
sudo ./Linux_for_Tegra/tools/l4t_create_default_user.sh -u nova -p rovanova -n novacarrier --accept-license

