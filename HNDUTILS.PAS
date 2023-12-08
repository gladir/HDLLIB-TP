{ @author: Sylvain Maltais (support@gladir.com)
  @created: 1992
  @website(https://www.gladir.com/CODER/HDLLIB-TP)
  @abstract(Target: Turbo Pascal 7)
}

Unit HndUtils;

INTERFACE

Function FileNo(Var F:File):Integer;

IMPLEMENTATION

Uses DOS;

Function FileNo(Var F:File):Integer;Begin
 FileNo:=FileRec(F).Handle;
End;

END.