// designed for Eon EN25x05 to EN25x256 with OTP sector of 256 or 512 bytes
// READ / WRITE / ERASE OTP SECTOR, read and set OTP_LOCK bit

{$ READ_ID}
begin
  ID_9F:= CreateByteArray(3);

  if not SPIEnterProgMode(_SPI_SPEED_MAX) then LogPrint('Error setting SPI speed');
  LogPrint ('Start read ID');

  // read ID
  SPIWrite (0, 1, $9F);
  SPIRead(1, 3, ID_9F);
  logprint('ID(9F): ' + inttohex((GetArrayItem(ID_9F, 0)),2)+ inttohex((GetArrayItem(ID_9F, 1)),2)+ inttohex((GetArrayItem(ID_9F, 2)),2));

  LogPrint ('End read ID ');
  SPIExitProgMode ();
end

{$ READ_OTP_LOCK_BIT}
begin
  if not SPIEnterProgMode(_SPI_SPEED_MAX) then LogPrint('Error setting SPI speed');
  sreg :=0;
  SPIWrite (1, 1, $3A);                      //Enter OTP mode
  SPIWrite (0, 1, $05);
  SPIRead  (1, 1, sreg);
  SPIWrite (1, 1, $04);                      //Exit OTP mode
  if (sreg and $80) then LogPrint ('OTP LockBit = 1')
  else                   LogPrint ('OTP LockBit = 0');

  SPIExitProgMode ();
end

{$ READ_OTP_SECTOR}
begin
  if not SPIEnterProgMode(_SPI_SPEED_MAX) then LogPrint('Error setting SPI speed');
  LogPrint ('Start read OTP sector');
  buff:= CreateByteArray(4);
  if _IC_Size > 1048576 then RegSize :=512 else RegSize :=256;
  Addr:= _IC_Size -4096; // address of last sector
  SetArrayItem(buff, 0, $03);
  SetArrayItem(buff, 1, (addr shr 16));
  SetArrayItem(buff, 2, (addr shr 8));
  SetArrayItem(buff, 3, (addr));
  SPIWrite (1, 1, $3A);        //Enter OTP mode
  SPIWrite (0, 4, buff);       //read last sector
  SPIReadToEditor (1, RegSize);
  SPIWrite (1, 1, $04);        //Exit OTP mode

  LogPrint ('End read OTP sector');
  SPIExitProgMode ();
end

{$ ERASE_OTP_SECTOR}
begin
  if not SPIEnterProgMode(_SPI_SPEED_MAX) then LogPrint('Error setting SPI speed');
  LogPrint ('Start Erase OTP sector');
  buff:= CreateByteArray(4);
  Addr:= _IC_Size -4096; // address of last sector
  SetArrayItem(buff, 0, $20);
  SetArrayItem(buff, 1, (addr shr 16));
  SetArrayItem(buff, 2, (addr shr 8));
  SetArrayItem(buff, 3, (addr));
  sreg := 0;
  SPIWrite (1, 1, $06);                     // write enable
  SPIWrite (1, 1, $3A);                     // Enter OTP mode

  SPIWrite (0, 1, $05);
  SPIRead  (1, 1, sreg);
  if       (sreg and $80) then LogPrint ('OTP LockBit = 1, write or erase not possible anymore!')
  else if  (sreg and $1C) then LogPrint ('BP bits are set, please check STATUS')
  else SPIWrite (1, 4, buff); // Erase last sector 

  SPIWrite (1, 1, $04);                     //Exit OTP mode
  LogPrint ('End Erase OTP sector');
  SPIExitProgMode ();
end

{$ WRITE_OTP_SECTOR}
begin
  if not SPIEnterProgMode(_SPI_SPEED_MAX) then LogPrint('Error setting SPI speed');
  LogPrint ('Start write OTP sector');
  PageSize :=256;
  sreg := 0;
  buff:= CreateByteArray(4);
  if _IC_Size > 1048576 then RegSize :=512 else RegSize :=256;
  Addr:= _IC_Size -4096; // address of last sector
  SetArrayItem(buff, 0, $02);
  SetArrayItem(buff, 1, (addr shr 16));
  SetArrayItem(buff, 2, (addr shr 8));
  SetArrayItem(buff, 3, (addr));
  
  SPIWrite (1, 1, $06);                     // write enable
  SPIWrite (1, 1, $3A);                     // Enter OTP mode

  SPIWrite (0, 1, $05);
  SPIRead  (1, 1, sreg);
  if       (sreg and $80) then LogPrint ('OTP LockBit = 1, write or erase not possible anymore!')
  else if  (sreg and $1C) then LogPrint ('BP bits are set, please check STATUS')
  else 
  begin
    SPIWrite (0, 4, buff);      // First page of sector
    SPIWriteFromEditor(1, PageSize, 0);
    repeat                                    //Busy
      SPIWrite(0, 1, $05);
      SPIRead(1, 1, sreg);
    until((sreg and 1) <> 1);

    if RegSize = 512 then
    begin
      SPIWrite (1, 1, $06);
      SetArrayItem(buff, 2, ((addr+PageSize) shr 8)); // addr +256
      SPIWrite (0, 4, buff);      // second page of sector
      SPIWriteFromEditor(1, PageSize, 0+PageSize);
      repeat                                    //Busy
        SPIWrite(0, 1, $05);
        SPIRead(1, 1, sreg);
      until((sreg and 1) <> 1);
    end;
  end;
  SPIWrite (1, 1, $04);                     // write disable
  LogPrint ('End write OTP sector');
  SPIExitProgMode ();
end

{$ SET_OTP_LOCK_BIT_FOR_EVER!!}
begin
  if not SPIEnterProgMode(_SPI_SPEED_MAX) then LogPrint('Error setting SPI speed');
  sreg :=0;
  SPIWrite (0, 1, $05);
  SPIRead  (1, 1, sreg);
  if  (sreg and $1C) then LogPrint ('BP bits are set, please check STATUS')
  else 
  begin
    repeat
      Confirm := InputBox('Are you really SURE??? (YES/NO)','','NO');
    until (Confirm = 'YES') or (Confirm = 'NO');
    if (Confirm = 'YES') then
    begin
      SPIWrite (1, 1, $06);                     // write enable
      SPIWrite (1, 1, $3A);                     // Enter OTP mode
      SPIWrite (1, 2, $01, $00);                // WRSR without data to set OTP_LOCK bit
      SPIWrite (1, 1, $04);                     // Exit OTP mode
      LogPrint ('OTP LockBit written!');
    end
    else LogPrint ('OTP LockBit not written, good choice!');
 end;
  SPIExitProgMode ();
end

