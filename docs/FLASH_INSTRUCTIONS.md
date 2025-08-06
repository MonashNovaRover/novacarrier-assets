# Flashing the Jetson Device

This guide explains how to flash your Jetson device using the provided setup and flashing scripts (in the flash directory).

## Prerequisites

- Ensure you're on a compatible Linux host system with necessary permissions.
  - This process has been verified on a Ubuntu 22.04 host
- Make sure your Jetson device is connected via USB and in recovery mode.
- Install `bash` (if not already installed).

## Steps

1. **Clone or access the repository** containing the setup and flash scripts.

2. **Run the Setup Script**

   This script prepares the device tree and other configuration files.

   ```bash
   chmod +x setup.sh
   sudo ./setup.sh
   
3. **Connect Your Jetson**
   
    - Make sure the Jetson is in recovery mode:
      - Power off the device
      - Hold the Force Recovery button, then press the Reset or Power button
      - Release the Force Recovery button
    - Confirm the device is detected via USB
      ```bash
      lsusb | grep NVIDIA

4. **Run the Flash Script**
     
    This script initiates the flashing process to the Jetson device.
  
    ```bash
    chmod +x flash.sh
    sudo ./flash.sh
    ```
    🚀 This will flash the Jetson with your customized configuration (e.g., pinmux, GPIO, SPI settings).

**Notes**
- The `setup.sh` script creates a default user with username `nova`, password `rovanova` and hostname `novacarrier`
- The files modified in this repo include .dts, .conf, and .txt files to ensure proper SPI, GPIO, and CAN configurations.
- Review and modify these files if additional hardware features need to be enabled.

**Troubleshooting**
- If the device is not detected, double-check USB connections and recovery mode.
- Reboot the host machine or use a different USB port if flashing fails.
- Logs will be printed in the terminal; inspect them for details on any failure.


