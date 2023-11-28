{ @author: Sylvain Maltais (support@gladir.com)
  @created: 1992
  @website(https://www.gladir.com/CODER/HDLLIB-TP)
  @abstract(Target: Turbo Pascal 7)
}

Unit HANDLELB;

INTERFACE

Procedure AddRecord(Handle:Integer;Size:Word;Var Buffer);
Function  CloseFile(Handle:Integer):Integer;
Function  CreateFile(FileName:String):Integer;
Function  DeleteFile(FileName:String):Integer;
Function  DuplicateHandle(Handle:Integer):Integer;
Function  FileSize(Handle:Integer):LongInt;
Function  GetErrCode:Word;
Function  OpenFile(FileName:String;Mode:Byte):Integer;
Procedure ReadRecord(Handle:Integer;Size:Word;Var Buffer);
Procedure ReadRecordAt(Handle:Integer;RecNum:LongInt;Size:Word;Var Buffer);
Procedure SeekFile(Handle:Integer;RecNum:LongInt;Size:Word);
Procedure WriteRecord(Handle:Integer;Size:Word;Var Buffer);
Procedure WriteRecordAt(Handle:Integer;RecNum:LongInt;Size:Word;Var Buffer);

IMPLEMENTATION

Uses DOS;

Var
 HandleErrCode:Word;

Procedure LongIntToDoubleWord(Value:LongInt;Var HighValue,LowValue:Word);Begin
 HighValue:=Value shr 16;
 LowValue:=Value and $FFFF;
End;

Function DoubleWordToLongInt(Grand,Petit:Word):LongInt;Begin
 DoubleWordToLongInt:=LongInt(LongInt(Grand) shl 16)+LongInt(Petit);
End;

Procedure SeekFile(Handle:Integer;RecNum:LongInt;Size:Word);
Var
 Regs:Registers;
 Grand,Petit:Word;
 Position:LongInt;
Begin
 Position:=RecNum*Size;
 LongIntToDoubleWord(Position,Grand,Petit);
 Regs.AH:=$42;
 Regs.AL:=$00;
 Regs.BX:=Handle;
 Regs.CX:=Grand;
 Regs.DX:=Petit;
 MsDos(Regs);
 If((Regs.Flags and 1)<>0)Then HandleErrCode:=Regs.AX
                          Else HandleErrCode:=0;
End;

Function FileSize(Handle:Integer):LongInt;
Var
 Regs:Registers;
Begin
 Regs.AH:=$42;
 Regs.AL:=$02;
 Regs.BX:=Handle;
 Regs.CX:=$00;
 Regs.DX:=$00;
 MsDos(Regs);
 If((Regs.Flags and 1)<>0)Then Begin
  FileSize:=-1;
  HandleErrCode:=Regs.AX;
 End
  Else
 Begin
  FileSize:=DoubleWordToLongInt(Regs.DX,Regs.AX);
  HandleErrCode:=0;
 End;
End;

Function CloseFile(Handle:Integer):Integer;
Var
 Regs:Registers;
Begin
 Regs.AX:=$3E00;
 Regs.BX:=Handle;
 MsDos(Regs);
 If((Regs.Flags and 1)<>0)Then Begin
  CloseFile:=Regs.AX;
  HandleErrCode:=Regs.AX;
 End
  Else
 Begin
  CloseFile:=0;
  HandleErrCode:=0;
 End;
End;

Function DuplicateHandle(Handle:Integer):Integer;
Var
 Regs:Registers;
Begin
 Regs.AX:=$4500;
 Regs.BX:=Handle;
 MsDos(Regs);
 If((Regs.Flags and 1)<>0)Then Begin
  DuplicateHandle:=Regs.AX;
  HandleErrCode:=Regs.AX;
 End
  Else
 Begin
  HandleErrCode:=0;
  DuplicateHandle:=-1;
 End;
End;

Function OpenFile(FileName:String;Mode:Byte):Integer;
Var
 Regs:Registers;
Begin
 FileName:=FileName+#0;
 Regs.AH:=$3D;
 Regs.AL:=$40+Mode;
 Regs.DS:=Seg(FileName[1]);
 Regs.DX:=Ofs(FileName[1]);
 MsDos(Regs);
 If((Regs.Flags and 1)<>0)Then Begin
  OpenFile:=-1;
  HandleErrCode:=Regs.AX;
 End
  Else
 Begin
  HandleErrCode:=Regs.AX;
  HandleErrCode:=0;
 End;
End;

Function CreateFile(FileName:String):Integer;
Var
 Regs:Registers;
Begin
 FileName:=FileName+#0;
 Regs.AH:=$3C;
 Regs.DS:=Seg(FileName[1]);
 Regs.DX:=Ofs(FileName[1]);
 Regs.CX:=$0000;
 MsDos(Regs);
 If((Regs.Flags and 1)<>0)Then Begin
  CreateFile:=-1;
  HandleErrCode:=Regs.AX;
 End
  Else
 Begin
  CreateFile:=Regs.AX;
  HandleErrCode:= 0;
 End;
End;

Function DeleteFile(FileName:String):Integer;
Var
 Regs:Registers;
Begin
 FileName:=FileName+#0;
 Regs.AX:=$4100;
 Regs.DS:=Seg(FileName[1]);
 Regs.DX:=Ofs(FileName[1]);
 MsDos(Regs);
 If((Regs.Flags and 1)<>0)Then Begin
  DeleteFile:=Regs.AX;
  HandleErrCode:=Regs.AX;
 End
  Else
 Begin
  DeleteFile:=0;
  HandleErrCode:=0;
 End;
End;

Procedure ReadRecord(Handle:Integer;Size:Word;Var Buffer);
Var
 Regs:Registers;
Begin
 Regs.AX:=$3F00;
 Regs.BX:=Handle;
 Regs.CX:=Size;
 Regs.DS:=Seg(Buffer);
 Regs.DX:=Ofs(Buffer);
 MsDos(Regs);
 If((Regs.Flags and 1)<>0)Then HandleErrCode:=Regs.AX
                          Else HandleErrCode:=0;
End;

Procedure ReadRecordAt(Handle:Integer;RecNum:LongInt;Size:Word;Var Buffer);
Var
 Regs:Registers;
Begin
 SeekFile(Handle,RecNum,Size);
 Regs.AX:=$3F00;
 Regs.BX:=Handle;
 Regs.CX:=Size;
 Regs.DS:=Seg(Buffer);
 Regs.DX:=Ofs(Buffer);
 MsDos(Regs);
 If((Regs.Flags and 1)<>0)Then HandleErrCode:=Regs.AX
                          Else HandleErrCode:=0;
End;

Procedure WriteRecord(Handle:Integer;Size:Word;Var Buffer);
Var
 Regs:Registers;
Begin
 Regs.AX:=$4000;
 Regs.BX:=Handle;
 Regs.CX:=Size;
 Regs.DS:=Seg(Buffer);
 Regs.DX:=Ofs(Buffer);
 MsDos(Regs);
 If((Regs.Flags and 1)<>0)Then HandleErrCode:=Regs.AX
                          Else HandleErrCode:=0;
End;

Procedure WriteRecordAt(Handle:Integer;RecNum:LongInt;Size:Word;Var Buffer);
Var
 Regs:Registers;
Begin
 SeekFile(Handle,RecNum,Size);
 Regs.AX:=$4000;
 Regs.BX:=Handle;
 Regs.CX:=Size;
 Regs.DS:=Seg(Buffer);
 Regs.DX:=Ofs(Buffer);
 MsDos(Regs);
 If((Regs.Flags and 1)<>0)Then HandleErrCode:=Regs.AX
                          Else HandleErrCode:=0;
End;

Procedure AddRecord(Handle:Integer;Size:Word;Var Buffer);
Var
 RecNum:LongInt;
Begin
 RecNum:=FileSize(Handle) div Size;
 WriteRecordAt(Handle,RecNum,Size,Buffer);
End;

Function GetErrCode:Word;Begin
 GetErrCode:=HandleErrCode;
 HandleErrCode:=0;
End;

END.