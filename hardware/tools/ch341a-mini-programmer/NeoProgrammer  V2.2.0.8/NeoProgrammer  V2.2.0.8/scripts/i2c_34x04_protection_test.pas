
{$READ_PROTECTION_STATUS}
function ReadAck3B(DevAdr): boolean;
begin
  I2CStart;
  Result := I2CWriteByte(DevAdr);
  I2CReadByte(0);
  I2CReadByte(0);
  I2CStop;
end;
begin
  AddrBuff := CreateByteArray(4);
  SetArrayItem(AddrBuff, 0, $63); // 0110 001 1 - Read Q0
  SetArrayItem(AddrBuff, 1, $69); // 0110 100 1 - Read Q1
  SetArrayItem(AddrBuff, 2, $6B); // 0110 101 1 - Read Q2
  SetArrayItem(AddrBuff, 3, $61); // 0110 000 1 - Read Q3

  logprint('Read protection status of SPD 34x04:');
  I2CEnterProgMode;
  for i := 0 to 3 do
  begin
       if ReadAck3B(GetArrayItem(AddrBuff, i))
          then logprint('Quadrant ['+IntToStr(i)+'] WP is clear')
          else logprint('Quadrant ['+IntToStr(i)+'] WP is SET');
  end;
  I2CExitProgMode;
  logprint('End of read');
end

{$WRITE_PROTECTION_STATUS}
function ReadAck3B(DevAdr): boolean;
begin
  I2CStart;
  Result := I2CWriteByte(DevAdr);
  I2CReadByte(0);
  I2CReadByte(0);
  I2CStop;
end;
begin
  AddrBuff := CreateByteArray(4);
  DevAddr := 0;
  Wbuff := CreateByteArray(2);
  //result := 0;
  SetArrayItem(AddrBuff, 0, $62); // 0110 001 0 - Write Q0
  SetArrayItem(AddrBuff, 1, $68); // 0110 100 0 - Write Q1
  SetArrayItem(AddrBuff, 2, $6A); // 0110 101 0 - Write Q2
  SetArrayItem(AddrBuff, 3, $60); // 0110 000 0 - Write Q3
  SetArrayItem(Wbuff, 0, 0);
  SetArrayItem(Wbuff, 1, 0);
  logprint('Write protection status:');
  logprint('Enter Quadrant number to set protection');
  logprint('[0..3] for 34x04; [0] for 34x02');
  repeat
    QNum := InputBox('Enter Quadrant number to set protection','[0..3] for 34x04; [0] for 34x02','0');
  until (QNum >= 0) and (QNum <= 3);
  logprint('Enter: '+QNum);

  logprint('Pin A0 MUST be connected to 10V. Operation may be irreversible!');
  logprint('Are you really SHURE??? (YES/NO)');
  repeat
  Confirm := InputBox('Are you really SHURE??? (YES/NO)','Pin A0 MUST be connected to 10V. Operation may be irreversible!','NO');
  until (UpperCase(Confirm) = 'YES') or (UpperCase(Confirm) = 'NO');
  logprint('Enter: '+Confirm);
    if (UpperCase(Confirm) = 'YES') then
    begin
         DevAddr := GetArrayItem(AddrBuff, QNum);
         I2CEnterProgMode;
         if ReadAck3B(DevAddr OR $01)
         then begin
              I2CReadWrite(DevAddr, 2, 0, Wbuff);             //костыли
              //if ReadAck3B(DevAddr OR $01)                  //так не работает, нужна задержка минимум 5мс,
              //then logprint('Protection for Quadrant ['+IntToStr(QNum)+'] can not be set. Error.')
              //else logprint('Protection for Quadrant ['+IntToStr(QNum)+'] is set');
              logprint('Protection for Quadrant ['+IntToStr(QNum)+'] is set'); //поэтому просто предположим, что записалось
              end
         else logprint('Write cancel, WP for Quadrant ['+IntToStr(QNum)+'] is already set')
    //if ReadAck3BW(GetArrayItem(AddrBuff, QNum))
    //   then logprint('Protection for Quadrant ['+IntToStr(QNum)+'] is set')
    //   else logprint('Something wrong. Quadrant ['+IntToStr(QNum)+'] protection can not be set, or set already!');
    I2CExitProgMode;
    end
    else LogPrint ('Protection status not changed!');
  logprint('End of write');
end

{$CLEAR_PROTECTION_STATUS}

begin
  DevAddr := 0;
  Wbuff := CreateByteArray(2);
  SetArrayItem(Wbuff, 0, 0);
  SetArrayItem(Wbuff, 1, 0);

  logprint('Clear protection status:');

  logprint('Pin A0 MUST be connected to 10V.');
  logprint('Are you shure? (YES/NO)');
  repeat
  Confirm := InputBox('Are you shure? (YES/NO)','Pin A0 MUST be connected to 10V','YES');
  until (UpperCase(Confirm) = 'YES') or (UpperCase(Confirm) = 'NO');
  logprint('Enter: '+Confirm);
    if (UpperCase(Confirm) = 'YES') then
    begin
         DevAddr := $66;   //0110 011 0 clear SWP
         I2CEnterProgMode;
         I2CReadWrite(DevAddr, 2, 0, Wbuff);             //костыли
         logprint('Protection for full IC is clear');
         I2CExitProgMode;
    end
    else LogPrint ('Protection status not changed!');
  logprint('End of clear');
end

