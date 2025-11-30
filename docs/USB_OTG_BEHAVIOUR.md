# USB OTG Data Role Behaviour on MNR JC 

The following table describes the USB OTG data-role behaviour depending on the PCB nets **USB2_REC_VBUS** and **SPI0_1V8.CS1b**.

## USB OTG Role Matrix

| Row | USB2_REC_VBUS (PCB Net) | VBUS_DETECT | SPI0_1V8.CS1b (PCB Net)| ID | USB Data Role            | Description                                                                                                                             |
| ----| ----------------------- | ----------- | ---------------------- | -- | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | 1                       | 0           | 0                      | 1  | **Device**               | Connected to host computer (VBUS_DETECT shorted to GND). GPIO header J14C pin 18 shorted to pin 24 (SPI0_1V8.CS1b shorted to GND).      |
| 2   | 1                       | 0           | 1                      | 0  | **Host**                 | Connected to host computer (VBUS_DETECT shorted to GND). GPIO header J14C pin 18 floating/pulled to 1.8V.                               |
| 3   | 0                       | 1           | 0                      | 1  | **Not Connected / None** | Disconnected from host computer (VBUS_DETECT pulled to 1.8V). GPIO header J14C pin 18 shorted to pin 24 (SPI0_1V8.CS1b shorted to GND). |
| 4   | 0                       | 1           | 1                      | 0  | **Host**                 | Disconnected from host computer (VBUS_DETECT pulled to 1.8V). GPIO header J14C pin 18 floating/pulled to 1.8V.                          |

### Notes

* The “**b**” suffix indicates an **active-low** signal.
  Example: `SPI0_1V8.CS1b` is active-low.
* The **ID** signal is negated from `SPI0_1V8.CS1b` in the device tree.
  Relevant line:

  ```dts
  id-gpio = <&gpio TEGRA234_MAIN_GPIO(Z, 7) GPIO_ACTIVE_LOW>;
  ```
* The **VBUS_DETECT** signal is negated from **USB2_REC_VBUS** on the MNR JC PCB with a logical NOT circuit.
* **Rows 1 and 4** represent **normal operating conditions**:

  * *Device mode*: flashing the Jetson SOM from a host computer
  * *Host mode*: connecting USB peripherals to the Jetson SOM
* **Rows 2 and 3** represent **non-standard configurations** and should be avoided.

---

## Checking the Current USB Data Role

To check the current USB role of the OTG port, run:

```bash
cat /proc/device-tree/padctl@3520000/ports/usb2-0/mode
```

This will print one of:

* `device`
* `host`
* `none`

## References
* https://forums.developer.nvidia.com/t/how-to-use-usb0-as-otg-in-device-and-host-mode-without-changing-device-tree-after-flashing/261772/13 
* https://docs.nvidia.com/jetson/archives/r35.3.1/DeveloperGuide/text/HR/JetsonModuleAdaptationAndBringUp/JetsonAgxOrinSeries.html?highlight=universal#porting-the-universal-serial-bus 

