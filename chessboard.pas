
program chessboard;

{$mode objfpc}{$h+}
{$ifdef mswindows}
{$apptype gui}
{$endif}

uses
{$ifdef unix}
  cthreads,
{$endif} 
  msegui, main;

begin
  application.createform(tmainfo, mainfo);
  application.run;
end.
