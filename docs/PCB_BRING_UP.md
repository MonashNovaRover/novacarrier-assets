The I2C EEPROM (Microchip 25LC256) on the power board can be programmed using the following commands. This first erases the EEPROM, then writes tps25750.bin to the EEPROM and finally reads back from the EEPROM into the file verify.bin. 

`./ch341eeprom -v -s 24c256 -e` \
`./ch341eeprom -v -s 24c256 -w tps25750.bin` \
`./ch341eeprom -v -s 24c256 -r verify.bin` 

To compare the binary file read back from the EEPROM to the original tps25750.bin file you can use the below command to list the discrepencies or use a checksum such as `md5sum` or `sha512sum`. 

`cmp -l tps25750.bin verify.bin | gawk '{printf "%08X %02X %02X\n", $1, strtonum(0$2), strtonum(0$3)}'`

To program the EEPROM for the USB-PCIe bridge (Renasas UPD720201), you can use the below command, 

`flashrom -p ch341a_spi -w upd720201.bin`

Note flashrom will automatically first erase the EEPROM, then verify after writing to the EEPROM. 
