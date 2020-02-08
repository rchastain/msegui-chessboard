
unit Rules;

interface

uses
  Main;

function IsMoveLegal(const FromCell, ToCell: cellty): boolean;
procedure DoMove(const FromCell, ToCell: cellty);
function ArbitratorMessage(): string;

implementation

uses
  SysUtils, StrUtils, ChessTypes, Game, Fen, Language;

const
  CSquareName: array[colty, rowty] of string[2] = (
    ('a1', 'a2', 'a3', 'a4', 'a5', 'a6', 'a7', 'a8'),
    ('b1', 'b2', 'b3', 'b4', 'b5', 'b6', 'b7', 'b8'),
    ('c1', 'c2', 'c3', 'c4', 'c5', 'c6', 'c7', 'c8'),
    ('d1', 'd2', 'd3', 'd4', 'd5', 'd6', 'd7', 'd8'),
    ('e1', 'e2', 'e3', 'e4', 'e5', 'e6', 'e7', 'e8'),
    ('f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8'),
    ('g1', 'g2', 'g3', 'g4', 'g5', 'g6', 'g7', 'g8'),
    ('h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'h7', 'h8')
  );

var
  LGame: TChessGame;

function ChangeCastlingNotation(const AMove: string): string;
begin
  if (AMove = 'e1g1') and LGame.IsLegal('e1h1') and LGame.IsCastling('e1h1') then begin result := 'e1h1'; end else
  if (AMove = 'e1c1') and LGame.IsLegal('e1a1') and LGame.IsCastling('e1a1') then begin result := 'e1a1'; end else
  if (AMove = 'e8g8') and LGame.IsLegal('e8h8') and LGame.IsCastling('e8h8') then begin result := 'e8h8'; end else
  if (AMove = 'e8c8') and LGame.IsLegal('e8a8') and LGame.IsCastling('e8a8') then begin result := 'e8a8'; end else
    result := AMove;
end;

function IsMoveLegal(const FromCell, ToCell: cellty): boolean;
var
  LMove: string;
begin
  LMove := Concat(CSquareName[FromCell.col, FromCell.row], CSquareName[ToCell.col, ToCell.row]);
  LMove := ChangeCastlingNotation(LMove);
  result := LGame.IsLegal(LMove);
end;

procedure DoMove(const FromCell, ToCell: cellty);
var
  LMove: string;
begin
  LMove := Concat(CSquareName[FromCell.col, FromCell.row], CSquareName[ToCell.col, ToCell.row]);
  LMove := ChangeCastlingNotation(LMove);
  LGame.DoMove(LMove);
end;

function ArbitratorMessage(): string;
begin
  case LGame.State of
    csProgress:
      result := Concat(
        IfThen(LGame.Check, Concat(GetText(txCheck), ' '), ''),
        IfThen(LGame.ActiveColor = pcWhite, GetText(txWhiteToMove), GetText(txBlackToMove))
      );
    csCheckmate:
      result := Concat(
        GetText(txCheckmate), ' ',
        IfThen(LGame.ActiveColor = pcWhite, GetText(txBlackWins), GetText(txWhiteWins))
      );
    csStalemate:
      result := GetText(txStalemate);
    csDraw:
      result := GetText(txDraw);
  end;
end;

initialization
  LGame := TChessGame.Create(CFenStartPosition);
  
finalization
  LGame.Free;
  
end.
