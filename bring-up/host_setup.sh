BSP_BRANCH=36
BSP_MAJOR=4
BSP_MINOR=3
HOST_INSTALL_DIRECTORY="/home/mvanwijk/novacarrier/test"
REPO_ROOT="/home/mvanwijk/novacarrier/novacarrier-assets"
TOOLCHAIN_DIRECTORY="/home/mvanwijk/novacarrier/test"

BSP_VERSION="${BSP_BRANCH}.${BSP_MAJOR}.${BSP_MINOR}"
L4T_RELEASE_PACKAGE="Jetson_Linux_r${BSP_VERSION}_aarch64.tbz2"
SAMPLE_FS_PACKAGE="Tegra_Linux_Sample-Root-Filesystem_r${BSP_VERSION}_aarch64.tbz2"
echo "BSP_VERSION=${BSP_VERSION}"


# Download L4T and Sample FS packages
if [ ! -d ${HOST_INSTALL_DIRECTORY} ]; then
    echo "Creating ${HOST_INSTALL_DIRECTORY}..."
    mkdir -p ${HOST_INSTALL_DIRECTORY}
fi
cd ${HOST_INSTALL_DIRECTORY}

if [ -f ${L4T_RELEASE_PACKAGE} ]; then
    echo "Found ${L4T_RELEASE_PACKAGE}" 
else
    echo "Downloading ${L4T_RELEASE_PACKAGE}..."
    wget "https://developer.nvidia.com/downloads/embedded/l4t/r${BSP_BRANCH}_release_v${BSP_MAJOR}.${BSP_MINOR}/release/Jetson_Linux_r${BSP_VERSION}_aarch64.tbz2"
fi

if [ -f ${SAMPLE_FS_PACKAGE} ]; then
    echo "Found ${SAMPLE_FS_PACKAGE}" 
else
    echo "Downloading ${SAMPLE_FS_PACKAGE}..."
    wget "https://developer.nvidia.com/downloads/embedded/l4t/r${BSP_BRANCH}_release_v${BSP_MAJOR}.${BSP_MINOR}/release/Tegra_Linux_Sample-Root-Filesystem_r${BSP_VERSION}_aarch64.tbz2"
fi

if [ -d "${TOOLCHAIN_DIRECTORY}/l4t-gcc" ]; then
    echo "Found toolchain!"
else
    echo "Downloading toolchain v3.0..."
    mkdir ${TOOLCHAIN_DIRECTORY}/l4t-gcc
    cd ${TOOLCHAIN_DIRECTORY}/l4t-gcc
    wget "https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v3.0/toolchain/aarch64--glibc--stable-2022.08-1.tar.bz2"
    tar xf aarch64--glibc--stable-2022.08-1.tar.bz2
fi
export CROSS_COMPILE=${TOOLCHAIN_DIRECTORY}/l4t-gcc/aarch64--glibc--stable-2022.08-1/bin/aarch64-buildroot-linux-gnu-

# Extract L4T and Sample FS packages
if [ -d "Linux_for_Tegra" ]; then
    echo "Linux_for_Tegra directory found"
else
    echo "Extracting L4T and Sample FS packages..."
    tar xf ${L4T_RELEASE_PACKAGE}
    sudo tar xpf ${SAMPLE_FS_PACKAGE} -C Linux_for_Tegra/rootfs/
fi

# Download source files
if [ -d "Linux_for_Tegra/source/hardware" ]; then
    echo "Source directory found"
else
    echo "Downloading source files..."
    sudo apt install git-core
    sudo apt install build-essential bc
    cd ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/source
    sudo ./source_sync.sh -k -t jetson_${BSP_VERSION}
fi

# Remove fusb301@25 from the device tree
echo "Removing fusb301@25 from the device tree..."
sudo sed -i '181,191d' ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/source/hardware/nvidia/t23x/nv-public/nv-platform/tegra234-p3768-0000+p3767-xxxx-nv-common.dtsi
sudo sed -i '205,220d' ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/source/hardware/nvidia/t23x/nv-public/nv-platform/tegra234-p3768-0000+p3767-xxxx-nv-common.dtsi

# Configuring the pinmux Setting of I2C and DP1_AUX
echo "Configuring the pinmux Setting of I2C and DP1_AUX..."
sudo sed -i '122,124d' ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/source/hardware/nvidia/t23x/nv-public/nv-platform/tegra234-p3768-0000+p3767-xxxx-nv-common.dtsi
cd ${REPO_ROOT}/bring-up
sudo sed -i '121r I2C_DPAUX.dts' ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/source/hardware/nvidia/t23x/nv-public/nv-platform/tegra234-p3768-0000+p3767-xxxx-nv-common.dtsi

# Add required files
echo "Copying required files..."
sudo cp ${REPO_ROOT}/bring-up/novacarrier.conf ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/novacarrier.conf
sudo cp ${REPO_ROOT}/bring-up/tegra234-mb1-bct-padvoltage-p3767-dp-a03.dtsi ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/bootloader/generic/BCT/tegra234-mb1-bct-padvoltage-p3767-dp-a03.dtsi
sudo cp ${REPO_ROOT}/bring-up/tegra234-mb1-bct-pinmux-p3767-dp-a03.dtsi ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/bootloader/generic/BCT/tegra234-mb1-bct-pinmux-p3767-dp-a03.dtsi
sudo cp ${REPO_ROOT}/bring-up/tegra234-mb1-bct-gpio-p3767-dp-a03.dtsi ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/bootloader/tegra234-mb1-bct-gpio-p3767-dp-a03.dtsi
sudo cp ${REPO_ROOT}/bring-up/tegra234-novacarrier.dtsi ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/source/hardware/nvidia/t23x/nv-public/tegra234-p3768-0000.dtsi


# Build Jetson Linux Kernel
cd ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/source
make -C kernel
export INSTALL_MOD_PATH=${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/rootfs/
sudo -E make install -C kernel
cp kernel/kernel-jammy-src/arch/arm64/boot/Image ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/kernel/Image

# Build NVIDIA Out of Tree Modules
export KERNEL_HEADERS=$PWD/kernel/kernel-jammy-src
make modules
sudo -E make modules_install
cd ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra
sudo ./tools/l4t_update_initrd.sh

# Build the DTBs
echo "Building DTBs..."
cd ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/source
make dtbs
sudo cp kernel-devicetree/generic-dts/dtbs/* ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/kernel/dtb/


# # Compile device tree overlay
# echo "Compile device tree..."
# dtc -I dts -O dtb -o ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/kernel/dtb/tegra234-novacarrier.dtbo ${REPO_ROOT}/bring-up/tegra234-novacarrier.dtsi
# # dtc -I dts -O dtb -o ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/kernel/dtb/extracted_modified.dtb ${REPO_ROOT}/bring-up/extracted_modified.dts

# # cp ${REPO_ROOT}/bring-up/tegra234-novacarrier+p3767-0000-nv.dtb ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/kernel/dtb/tegra234-novacarrier+p3767-0000-nv.dtb

# echo "Setting carrier board EEPROM read size to 0..."
# sed -i 's|cvb_eeprom_read_size = <0x100>;|cvb_eeprom_read_size = <0x0>;|' ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/bootloader/generic/BCT/tegra234-mb2-bct-misc-p3767-0000.dts

# # Flash prerequisites and apply config to rootfs
# echo "flash prerequisites..."
# cd ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra
# sudo ./tools/l4t_flash_prerequisites.sh

# echo "Applying binaries to rootfs..."
# sudo ./apply_binaries.sh

# # Create default user
# echo "Creating default user..."
# sudo ./tools/l4t_create_default_user.sh -u nova -p rovanova -n novacarrier --accept-license

