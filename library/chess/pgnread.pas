
unit PgnRead;

interface

uses
  SysUtils, Classes;

type
  TGroupIndex = 1..6;
  PGroups = ^TGroups;
  TGroups = array[TGroupIndex] of string;
  
  TChessGame = class
    FTags: TStringList;
    FMoves: TList;
    FTermination: string;
    constructor Create; overload;
    destructor Destroy; override;
  end;
  
function ParsePgnText(AText: string): TList;

implementation

uses
  RegExpr;

constructor TChessGame.Create;
begin
  inherited;
  FTags := TStringList.Create;
  FTags.Sorted := TRUE;
  FMoves := TList.Create;
end;

destructor TChessGame.Destroy;
var
  LIndex: integer;
  LGroups: PGroups;
begin
  FTags.Free;
  for LIndex := Pred(FMoves.Count) downto 0 do
  begin
    LGroups := FMoves[LIndex];
    Dispose(LGroups);
  end;
  FMoves.Free;
  inherited;
end;

function ParsePgnText(AText: string): TList;
const
  CFile = '[a-h]';
  CRank = '[1-8]';
  CKingSideCastling = 'O-O';
  CQueenSideCastling = 'O-O-O';
  CPiece = '[PNBRQK]';
  CDisambiguation = CFile + '|' + CRank + '|' + CFile + CRank;
  CCapture = 'x';
  CSquareOrCastling = CFile + CRank + '|' + CQueenSideCastling + '|' + CKingSideCastling;
  CPromotion = '=[NBRQ]';
  CCheckOrCheckmate = '[+#]';
  CSanMove =
    '(' + CPiece            + ')?' +
    '(' + CDisambiguation   + ')?' +
    '(' + CCapture          + ')?' +
    '(' + CSquareOrCastling + ')' +
    '(' + CPromotion        + ')?' +
    '(' + CCheckOrCheckmate + ')?';
  CFullMove = '(\d+)\.\s+(' + CSanMove + '\s+){1,2}';
  CMovesSection = '(' + CFullMove + ')+';
  CTagPair = '\[(\w+)\s+"([^"]+)"\]';
  CTagPairsSection  = '(' + CTagPair + '\s+)+';
  CGameTermination = '(1-0|0-1|1/2-1/2|\*)';
  CGame = CTagPairsSection + CMovesSection + CGameTermination;
type
  TSearch = (searchGame, searchTagPair, searchFullMove, searchTermination, searchMove);
const
  CPatterns: array[TSearch] of string = (CGame, CTagPair, CFullMove, CGameTermination, CSanMove);
var
  LExpr: array[TSearch] of TRegExpr;
  LSearch: TSearch;
  LGame: TChessGame;
procedure ParseFullMove(const AFullMove: string);
var
  LIndex: integer;
  LGroups: PGroups;
begin
  with LExpr[searchMove] do
    if Exec(AFullMove) then
      with LGame do
      repeat
        New(LGroups);
        FMoves.Add(LGroups);
        for LIndex := 1 to SubExprMatchCount do
          LGroups^[LIndex] := Match[LIndex];
      until not ExecNext;
end;
begin
  for LSearch in TSearch do
    LExpr[LSearch] := TRegExpr.Create(CPatterns[LSearch]);
  
  result := TList.Create;
  
  try
    if LExpr[searchGame].Exec(AText) then
      repeat
        AText := LExpr[searchGame].Match[0];
        
        LGame := TChessGame.Create;
        result.Add(LGame);
        
        with LExpr[searchTagPair] do
          if Exec(AText) then
          repeat
            LGame.FTags.Append(Format('%s=%s', [Match[1], Match[2]]));
          until not ExecNext;
        
        with LExpr[searchFullMove] do
          if Exec(AText) then
          repeat
            ParseFullMove(Match[0]);
          until not ExecNext;
        
        with LExpr[searchTermination] do
          if Exec(AText) then
            LGame.FTermination := Match[0];
            
      until not LExpr[searchGame].ExecNext;
  finally
    for LSearch in TSearch do
      LExpr[LSearch].Free;
  end;
end;

end.
