#!/bin/bash
trap 'echo "Error occurred!"; exit 1' ERR

BSP_BRANCH=36
BSP_MAJOR=4
BSP_MINOR=3
export REPO_ROOT=$(dirname $(pwd))
export HOST_INSTALL_DIRECTORY="${REPO_ROOT}/build"
export TOOLCHAIN_DIRECTORY=${HOST_INSTALL_DIRECTORY}

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
cd ${HOST_INSTALL_DIRECTORY}
if [ -d "Linux_for_Tegra" ]; then
    echo "Linux_for_Tegra directory found"
else
    echo "Extracting L4T and Sample FS packages..."
    tar xf ${L4T_RELEASE_PACKAGE}
    sudo tar xpf ${SAMPLE_FS_PACKAGE} -C Linux_for_Tegra/rootfs/
    
    # Flash prerequisites and apply config to rootfs
    echo "flash prerequisites..."
    cd ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra
    sudo ./tools/l4t_flash_prerequisites.sh

    echo "Applying binaries to rootfs..."
    sudo ./apply_binaries.sh
fi

# Download source files
cd ${HOST_INSTALL_DIRECTORY}
if [ -f "public_sources.tbz2" ]; then
    echo "Found public_sources.tbz2"
else
    echo "Downloading public_sources.tbz2..."
    wget "https://developer.nvidia.com/downloads/embedded/l4t/r${BSP_BRANCH}_release_v${BSP_MAJOR}.${BSP_MINOR}/sources/public_sources.tbz2"
    sudo apt install git-core
    sudo apt install build-essential bc
fi

# Download source files
if [ -d "Linux_for_Tegra/source/hardware" ]; then
    echo "Source directory found"
else
    echo "Extracting source files..."
    cd ${HOST_INSTALL_DIRECTORY}
    tar xf public_sources.tbz2 -C Linux_for_Tegra/..
    cd Linux_for_Tegra/source
    tar xf kernel_src.tbz2
    tar xf kernel_oot_modules_src.tbz2
    tar xf nvidia_kernel_display_driver_source.tbz2
fi

# Remove fusb301@25 from the device tree
export COMMON_DTSI=${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/source/hardware/nvidia/t23x/nv-public/nv-platform/tegra234-p3768-0000+p3767-xxxx-nv-common.dtsi
if [[ "$(sed -n '181p' ${COMMON_DTSI})" == "		padctl@3520000 {" && "$(sed -n '216p' ${COMMON_DTSI})" == "			fusb301@25 {" ]]; then
    echo "Removing fusb301@25 from the device tree..."
    sudo sed -i '181,191d' ${COMMON_DTSI}
    sudo sed -i '205,220d' ${COMMON_DTSI}
fi

# Remove tegra-spidev for SPI-CAN controllers
if [[ $(sed -n '133p' ${COMMON_DTSI}) == '			spi@0 {' && $(sed -n '134p' ${COMMON_DTSI}) == '				compatible = "tegra-spidev";' ]]; then
    echo "Removing tegra-spidev for SPI-CAN controller 1..."
    sed -i '133,142d' ${COMMON_DTSI}
fi

if [[ $(sed -n '149p' ${COMMON_DTSI}) == '			spi@0 {' && $(sed -n '150p' ${COMMON_DTSI}) == '				compatible = "tegra-spidev";' ]]; then
    echo "Removing tegra-spidev for SPI-CAN controller 2..."
    sed -i '149,158d' ${COMMON_DTSI}
fi

# Add required files
echo "Copying required files..."
sudo cp ${REPO_ROOT}/flash/novacarrier.conf ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/novacarrier.conf
sudo cp ${REPO_ROOT}/flash/tegra234-mb1-bct-padvoltage-p3767-dp-a03.dtsi ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/bootloader/generic/BCT/tegra234-mb1-bct-padvoltage-p3767-dp-a03.dtsi
sudo cp ${REPO_ROOT}/flash/tegra234-mb1-bct-pinmux-p3767-dp-a03.dtsi ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/bootloader/generic/BCT/tegra234-mb1-bct-pinmux-p3767-dp-a03.dtsi
sudo cp ${REPO_ROOT}/flash/tegra234-mb1-bct-gpio-p3767-dp-a03.dtsi ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/bootloader/tegra234-mb1-bct-gpio-p3767-dp-a03.dtsi
sudo cp ${REPO_ROOT}/flash/tegra234-novacarrier.dtsi ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/source/hardware/nvidia/t23x/nv-public/tegra234-p3768-0000.dtsi

echo "Setting carrier board EEPROM read size to 0..."
sed -i 's|cvb_eeprom_read_size = <0x100>;|cvb_eeprom_read_size = <0x0>;|' ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/bootloader/generic/BCT/tegra234-mb2-bct-misc-p3767-0000.dts

# # Setup kernel config
echo "Setting up kernel config..."
# sudo apt install wget lbzip2 build-essential bc zip libgmp-dev libmpfr-dev libmpc-dev vim-common libncurses-dev bison flex libssl-dev libelf-dev
sudo cp ${REPO_ROOT}/flash/defconfig ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/source/kernel/kernel-jammy-src/arch/arm64/configs/defconfig

# Build kernel
echo "Building Jetson Linux Kernel..."
cd ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/source
make -C kernel -j$(nproc)
export INSTALL_MOD_PATH=${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/rootfs/
sudo -E make install -C kernel -j$(nproc)
cp kernel/kernel-jammy-src/arch/arm64/boot/Image ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/kernel/Image

# Build NVIDIA OOT Modules
echo "Building NVIDIA Out of Tree Modules..."
export KERNEL_HEADERS=$PWD/kernel/kernel-jammy-src
make modules -j$(nproc)
sudo -E make modules_install -j$(nproc)
cd ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra
sudo ./tools/l4t_update_initrd.sh

# Build the DTBs
echo "Building DTBs..."
cd ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/source
make dtbs -j$(nproc)
sudo cp kernel-devicetree/generic-dts/dtbs/* ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra/kernel/dtb/

# Create default user
echo "Creating default user..."
cd ${HOST_INSTALL_DIRECTORY}/Linux_for_Tegra
sudo ./tools/l4t_create_default_user.sh -u nova -p rovanova -n novacarrier --accept-license
