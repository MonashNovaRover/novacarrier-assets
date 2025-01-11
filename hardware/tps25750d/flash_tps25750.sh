./ch341eeprom -v -s 24c256 -e
./ch341eeprom -v -s 24c256 -w tps25750.bin
./ch341eeprom -v -s 24c256 -r verify.bin
cmp -l tps25750.bin verify.bin | gawk '{printf "%08X %02X %02X\n", $1, strtonum(0$2), strtonum(0$3)}'

