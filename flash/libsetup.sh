#!/bin/bash

edit_nvidia_dts() {

    # Remove fusb301@25 from the device tree
    if [[ "$(sed -n '181p' $1)" == "		padctl@3520000 {" && "$(sed -n '216p' $1)" == "			fusb301@25 {" ]]; then
        echo "Removing fusb301@25 from the device tree..."
        sudo sed -i '181,191d' $1
        sudo sed -i '205,220d' $1
    fi

    # Remove tegra-spidev for SPI-CAN controllers
    if [[ $(sed -n '133p' $1) == '			spi@0 {' && $(sed -n '134p' $1) == '				compatible = "tegra-spidev";' ]]; then
        echo "Removing tegra-spidev for SPI-CAN controller 1..."
        sed -i '133,152d' $1
    fi

    if [[ $(sed -n '139p' $1) == '			spi@0 {' && $(sed -n '140p' $1) == '				compatible = "tegra-spidev";' ]]; then
        echo "Removing tegra-spidev for SPI-CAN controller 2..."
        sed -i '139,158d' $1
    fi
}
