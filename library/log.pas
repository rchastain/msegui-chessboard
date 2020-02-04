
unit Log;

interface

uses
  SysUtils, Settings;

type
  TLog = class
    class procedure Append(const ALine: string);
  end;

implementation

var
  LLog: text;

class procedure TLog.Append(const ALine: string);
begin
  WriteLn(LLog, ALine);
  Flush(LLog);
end;
  
initialization
  Assign(LLog, LLogPath);
  Rewrite(LLog);
    
finalization
  Close(LLog);
  
end.
