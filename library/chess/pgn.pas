
unit Pgn;

interface

uses
  SysUtils, Classes;

procedure WritePgnFile(const APath: TFileName; const AData: TStringList; const AChess960: boolean);

implementation

procedure WritePgnFile(const APath: TFileName; const AData: TStringList; const AChess960: boolean);
const
  CWhiteName       = 0;
  CBlackName       = 1;
  CInitialPosition = 2;
  CFirstMove       = 3;
var
  LFile: text;
  i: integer;
  s: string;
begin
  Assign(LFile, APath);
  Rewrite(LFile);
  Write(
    LFile,
    Format(
      '[Event "?"]'#13#10 +
      '[Site "?"]'#13#10 +
      '[Date "%s"]'#13#10 +
      '[Round "?"]'#13#10 +
      '[White "%s"]'#13#10 +
      '[Black "%s"]'#13#10 +
      '[Result "%s"]'#13#10,
      [
        FormatDateTime('YYYY.MM.DD', Now),
        AData[CWhiteName],
        AData[CBlackName],
        AData[Pred(AData.Count)]
      ]
    )
  );
  
  if AChess960 then
    WriteLn(
      LFile,
      Format(
        '[SetUp "1"]'#13#10 +
        '[FEN "%s"]'#13#10,
        [
          AData[CInitialPosition]
        ]
      )
    )
  else
    WriteLn(LFile);

  s := '';
  for i := CFirstMove to AData.Count - 2 do
  begin
    if i mod 2 = 1 then
    s := s + Format('%d. ', [i div 2]);
    s := s + Format('%s ', [AData[i]]);
  end;
  s := s + AData[Pred(AData.Count)];

  while Length(s) > 72 do
  begin
    i := 72;
    while (s[i] <> ' ') or (s[Pred(i)] = '.') or not (s[Succ(i)] in ['1'..'9']) do
      Dec(i);
    WriteLn(LFile, Copy(s, 1, Pred(i)));
    Delete(s, 1, i);
  end;
  WriteLn(LFile, s);

  Close(LFile);
end;

end.
