# Flashing the Jetson Device

This guide explains how to flash your Jetson device using the provided setup and flashing scripts (in the flash directory).

## Prerequisites

* Ensure you're on a compatible Linux host system with necessary permissions.

  * This process has been verified on a Ubuntu 22.04 host
* Make sure your Jetson device is connected via USB and in recovery mode.
* Install `bash` (if not already installed).

## IMPORTANT NOTE: NVIDIA Devkit vs Monash Nova Rover Jetson Carrier Firmware Compatibility

The NVIDIA devkit firmware is **incompatible** with the Monash Nova Rover Jetson Carrier (MNR JC).

There is a hardware bug on the MNR JC that prevents **USB0 from entering OTG mode** when NVIDIA devkit firmware is loaded on the Jetson SOM. This means:

* You **cannot flash MNR JC firmware on the MNR JC** if the Jetson SOM currently has NVIDIA devkit firmware installed.

A workaround exists:

* The MNR JC firmware includes a custom fix that allows OTG mode to function correctly on the MNR JC.
* The MNR JC firmware **is compatible with the NVIDIA devkit**, although some peripherals may not work.

### Required Bring-Up Procedure for a Jetson SOM on the MNR JC

To recover or correctly flash a Jetson SOM intended for the MNR JC:

1. **Flash the MNR JC firmware using the NVIDIA devkit** (since the Jetson SOM can enter OTG mode with any firmware on the NVIDIA devkit).
2. **Transplant the Jetson SOM back onto the MNR JC.**
3. If you need to reflash again later, the Jetson SOM will now correctly enter OTG mode on the MNR JC **with both MNR JC DIP switches ON and a jumper wire shorting pin 18 of J14C to GND**, because the MNR JC firmware contains the OTG fix.

For more information regarding OTG behaviour on the MNR JC refer to [USB_OTG_BEHAVIOUR.md](USB_OTG_BEHAVIOUR.md).

## Steps

1. **Clone or access the repository** containing the setup and flash scripts.

2. **Run the Setup Script**

   This script prepares the device tree and other configuration files.

   ```bash
   chmod +x setup.sh
   sudo ./setup.sh
   ```

3. **Connect Your Jetson**

   * Make sure the Jetson is in recovery mode:

     * Power off the device
     * Hold the Force Recovery button, then press the Reset or Power button
     * Release the Force Recovery button
   * Confirm the device is detected via USB

     ```bash
     lsusb | grep NVIDIA
     ```

4. **Run the Flash Script**

   This script initiates the flashing process to the Jetson device.

   ```bash
   chmod +x flash.sh
   sudo ./flash.sh
   ```

   🚀 This will flash the Jetson with your customized configuration (e.g., pinmux, GPIO, SPI settings).

## Notes

* The `setup.sh` script creates a default user with username `nova`, password `rovanova` and hostname `novacarrier`.
* The files modified in this repo include `.dts`, `.conf`, and `.txt` files to ensure proper SPI, GPIO, and CAN configurations.
* Review and modify these files if additional hardware features need to be enabled.

## Troubleshooting

* If the device is not detected, double-check USB connections and recovery mode.
* Reboot the host machine or use a different USB port if flashing fails.
* Logs will be printed in the terminal; inspect them for details on any failure.
