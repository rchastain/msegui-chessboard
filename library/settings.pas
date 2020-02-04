
unit Settings;

interface

procedure ReadFromINIFile(
  out AStartPos: string;
  out AChess960: boolean;
  out AMoveTime: integer
);
procedure WriteToINIFile(
  const AStartPos: string;
  const AChess960: boolean;
  const AMoveTime: integer
);

var
  LFenPath: string;
  LLogPath: string;
  
implementation

uses
  SysUtils,
  IniFiles,
  Fen;

const
  CTraditionalStartPosition = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
  
const
  CSection = 'eschecs';
  CDefaultStartPos = CTraditionalStartPosition;
  CDefaultChess960 = 'FALSE';
  CDefaultMoveTime = 0;
  
var
  LIniPath: string;
  
procedure ReadFromINIFile(
  out AStartPos: string;
  out AChess960: boolean;
  out AMoveTime: integer
);
begin
  with TIniFile.Create(LIniPath) do
  try
    AStartPos := ReadString(CSection, 'position', CDefaultStartPos);
    AChess960 := ReadString(CSection, 'chess960', CDefaultChess960) = 'TRUE';
    AMoveTime := ReadInteger(CSection, 'movetime', CDefaultMoveTime)
  finally
    Free;
  end;
end;

procedure WriteToINIFile(
  const AStartPos: string;
  const AChess960: boolean;
  const AMoveTime: integer
);
begin
  with TIniFile.Create(LIniPath) do
  try
    WriteString(CSection, 'position', AStartPos);
    WriteString(CSection, 'chess960', UpperCase(BoolToStr(AChess960, TRUE)));
    WriteInteger(CSection, 'movetime', AMoveTime);
    UpdateFile;
  finally
    Free;
  end;
end;

begin
  LLogPath := ChangeFileExt(ParamStr(0), '.log');
  LIniPath := ChangeFileExt(ParamStr(0), '.ini');
  LFenPath := ChangeFileExt(ParamStr(0), '.fen');
end.
