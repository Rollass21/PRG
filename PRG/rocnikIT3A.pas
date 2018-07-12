unit rock;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ExtCtrls, Vcl.StdCtrls,
  System.Actions, Vcl.ActnList, Vcl.Buttons, System.UITypes,
  Math; // Imports Random*(*) functions

type
  TForm1 = class(TForm)
    StringGrid1: TStringGrid;
    ScoreLabel: TLabel;
    RESETbtn: TButton;
    downbtn: TButton;
    upbtn: TButton;
    leftbtn: TButton;
    rightbtn: TButton;
    mvIndicatorLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure RESETbtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure leftbtnClick(Sender: TObject);
    procedure upbtnClick(Sender: TObject);
    procedure rightbtnClick(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

{/////////////////////////////////////////////
            TYPES/CONSTS/GLOBALS
}/////////////////////////////////////////////

type
  // rolands Type POSition
  rTPos = record
    i : integer;
    j : integer;
  end;

const
  sgLastINDEX = 15;
  //Selects/Focuses rectangle at [0,-1]
  NoSelection: TGridRect = (Left: 0; Top: -1; Right: 0; Bottom: -1);

  //Changeable
  EMPTY = '';
  ENDGAMESCORE = 2048;
  HIGHLIGHTNEW = TRUE;

var
  Form1: TForm1;
  MaxScore : LongInt;
  ReachedGoal : Boolean; { Flag that signals whether we already reached
                           ENDGAMESCORE. }

implementation






{/////////////////////////////////////////////
            FUNCTIONS/PROCEDURES
}/////////////////////////////////////////////

{$R *.dfm}
{ isGridFull()
  Validates number of empty cells( equal to zero or empty strings) in a grid.
  Helper function for newRandCell().
  = Return value is the number of free cells found.

  @sg         IN - StringGrid object in which to find 'free' cells.
  @freeCells OUT - Array of positions in grid, its length must be appropriately
                   pre-declared according to @sg dimenstions.
}
function isGridFull(sg : TStringGrid;
                    var freeCells : array of rTPos) : Integer;
  var i, j, len: integer;
begin
  len := 0;

  for i := 0 to sg.RowCount - 1 do
    for j := 0 to sg.ColCount - 1 do
      if (sg.Cells[i,j] = '0') or (sg.Cells[i,j] = EMPTY) then
        begin
          freeCells[len].i := i;
          freeCells[len].j := j;
          len := len + 1;
        end;

  isGridFull := len;
end;

{ newRandCell()
  Finds empty cell in grid and randomly writes into it '2' or '4' based on probability.
  = Returns boolean 'True' if succesfully written random number into grid,
    otherwise returns 'False'.

  @sg IN/OUT - StringGrid object in which we firstly find empty cells
                         and then write into one of them.
                         Cell values that evaluate as 'empty' can be found in
                         isGridFull() function declaration.
}
function newRandCell(var sg : TStringGrid) : Boolean;
var randi, randj, randPos, freeLen, randVal, chance : integer;
      freeCells : array[0..sgLastINDEX] of rTPos;
begin
  newRandCell := False;

  freeLen := IsGridFull(sg, freeCells);

  if (freeLen > 0) then
    begin
      randPos := RandomRange(0, freeLen - 1);
      randi := freeCells[randPos].i;
      randj := freeCells[randPos].j;

      chance := RandomRange(0, 100);
      // 60% chance of 2
      // 40% chance of 4
      if (chance <= 60) then
        randVal := 2
      else
        randVal := 4;

      sg.Cells[randi, randj] := IntToStr(randVal);
      if (HIGHLIGHTNEW) then
        begin
          sg.Col := randi;
          sg.Row := randj;
        end
      else
        sg.Selection:= NoSelection;


      newRandCell := True;
    end;

end;

{ CleanUp()
  Rewrites every value of grid to EMPTY constant

  @sg IN/OUT - StringGrid to empty.
}
procedure CleanUp(var sg : TStringGrid);
  var i,
      j : integer;
begin
  for i := 0 to sg.RowCount do
    for j := 0 to sg.ColCount do
      sg.Cells[i,j] := EMPTY;
end;

{ ResetGame()
  Resets all values that might have been modified during the game and starts a
  new one.

  @sg IN/OUT - StringGrid containing game grid to reset.
}
procedure ResetGame(var sg : TStringGrid);
begin
  Form1.upbtn.Enabled := True;
  Form1.downbtn.Enabled := True;
  Form1.leftbtn.Enabled := True;
  Form1.rightbtn.Enabled := True;

  ReachedGoal := False;
  CleanUp(sg);
  MaxScore := 0;
  newRandCell(sg);
  newRandCell(sg);
  Form1.mvIndicatorLabel.Caption := '';
  Form1.ScoreLabel.Caption := IntToStr(MaxScore);
end;

{ RMostEmpty() Right Most Empty
  Finds the Right MOST EMPTY cell in a row.
  = Returns the column index of the right most empty cell.

  @sg       IN/OUT - StringGrid over which to operate.
  @rowindex     IN - Row in which to find the right most empty cell.
}
function RMostEmpty(sg : TStringGrid;
                    rowindex : Integer) : Integer;
var j : Integer;
begin
  RMostEmpty := -1;

  for j := 0 to sg.ColCount - 1 do
    if (sg.Cells[j, rowindex] = EMPTY) then
      RMostEmpty := j;

end;

{ PushRightRow()
  Pushes all non-empty elements of a row to the right edge i.e. moves all empty
  cells to the left edge.
  = Returns number of pushed cells, if @push is set to FALSE:
    returns only value > 0.

  @sg       IN/OUT - StringGrid over which to operate.
  @rowindex     IN - Row which cells to 'push to the right'.
  @push         IN - Used to decide whether to push cells or just count the
                     possible pushes.
}
function PushRightRow(var sg : TStringGrid;
                      rowindex : Integer;
                      push : Boolean) : Integer;

var j, rmost, npushes : Integer;
begin
  npushes := 0;

  //Find the right-most empty cell index
  rmost := RMostEmpty(sg, rowindex);
  //If there are any EMPTY cells, continue
  if (rmost >= 0) then
    for j := rmost downto 0 do
        begin
          //If anything else than EMPTY, then...
          if (sg.Cells[j, rowindex] <> EMPTY) then
            begin
              if (push) then
                begin
                  sg.Cells[rmost, rowindex]:= sg.Cells[j, rowindex];
                  sg.Cells[j, rowindex] := EMPTY;
                end;
              npushes := npushes + 1;
              rmost := RMostEmpty(sg, rowindex);
            end;
        end;

  PushRightRow := npushes;
end;

{ PushRight()
  Finds sets of two same values in all rows and merges them, more info in
  function MergeRightRow().
  = Returns number of merges, if @push is set to FALSE:
    returns only value > 0.

  @sg       IN/OUT - Stringgrid over which to operate.
  @rowindex     IN - Index of the row over which to operate.
  @push         IN - Used to decide whether to push cells or just count the
                     possible pushes.
}
function PushRight(var sg : TStringGrid;
                   push : Boolean) : Integer;
var i, npushes : Integer;
begin
  npushes := 0;

  for i := 0 to sg.RowCount - 1 do
    begin
      npushes := npushes + PushRightRow(sg, i, push);
    end;

  PushRight := npushes;
end;

{ MergeRightRow()
  Finds sets of two same values in a row, if @merge is set to TRUE: merges them
  into the double of one of them, the doubled result is saved into the right
  cell and the left cell is EMPTYed,
  otherwise if @merge is set to FALSE: just increment the merge counter i.e.
  just to test if there is any merge possible.
  = Returns number of merges, if @merge is set to FALSE:
    returns only value > 0.

  @sg       IN/OUT - Stringgrid over which to operate.
  @rowindex     IN - Index of the row over which to operate.
  @merge        IN - Used to decides whether to merge cells or just count the
                     possible merges.
}
function MergeRightRow(var sg : TStringGrid;
              rowindex : Integer;
              merge : Boolean) : Integer;

var j, nmerges : integer;
    skip : boolean;
begin
  skip := False;
  nmerges := 0;

  for j := sg.ColCount - 1 downto 1 do
    begin
      // If on non-EMPTY cell AND there are two same values AND don't need to skip
      if (sg.Cells[j, rowindex] <> EMPTY) and
         (sg.Cells[j, rowindex] = sg.Cells[j - 1, rowindex])
         and (skip = False) then
        begin
          if (merge) then
            begin
              sg.Cells[j - 1, rowindex] := EMPTY;
              sg.Cells[j, rowindex] := IntToStr(StrToInt(sg.Cells[j, rowindex]) * 2);
            end;
          nmerges := nmerges + 1;
          skip := True;
        end;
      skip := False;
    end;

    MergeRightRow := nmerges;
end;

{ MergeRight()
  Finds sets of two same values in all rows and merges them, more info in
  function MergeRightRow().
  Just a wrapper for MergeRightRow().
  = Returns number of merges, if @merge is set to FALSE:
    returns value > 0.

  @sg       IN/OUT - Stringgrid over which to operate.
  @rowindex     IN - Index of the row over which to operate.
  @merge        IN - Used to decide whether to merge cells or just count the
                     possible merges.
}
function MergeRight(var sg : TStringGrid;
                  merge : Boolean) : Integer;

  var i, nmerges : integer;
begin
  nmerges := 0;

  for i := 0 to sg.RowCount - 1 do
    begin
      nmerges := nmerges + MergeRightRow(sg, i, merge);
    end;

  MergeRight := nmerges;
end;

{ Transpose()
  Replaces given StringGrid with its transpose.

  @sg IN/OUT - StringGrid that will be 'transposed'.
}
procedure Transpose(var sg : TStringGrid);
var i, j  : Integer;
    tempS : string;
begin
  for i := 0 to sg.RowCount - 1 do
    for j := 0 to i do
      begin
        tempS := sg.Cells[i, i-j];
        sg.Cells[i, i-j] := sg.Cells[i-j,i];
        sg.Cells[i-j,i] := tempS;
      end;
end;

{ SwapRows()
  Swaps rows in given StringGrid.

  @sg   IN/OUT - StringGrid which rows to swap.
  @rowA     IN - Index of a row to swap with @rowB.
  @rowB     IN - Index of a row to swap with @rowA.
}
procedure SwapRows(var sg : TStringGrid;
                     rowA : integer;
                     rowB : integer);
var j : integer;
    tempS : string;
begin
  if (rowA <> rowB) then  
    for j := 0 to sg.ColCount - 1 do
      begin
        tempS := sg.Cells[rowA, j];
        sg.Cells[rowA, j] := sg.Cells[rowB, j];
        sg.Cells[rowB, j] := tempS;
      end;
end;

{ RotRight()
  Rotate given StringGrid @rots times by 90° to the right.

  @sg   IN/OUT - StringGrid to rotate.
  @rots     IN - Number of rotations.
}
procedure RotRight(var sg : TStringGrid;
                   rots : Integer);
var i, r : integer;
begin
  for r := 1 to rots do
  begin
    Transpose(sg);
    for i := 0 to 1 do
      SwapRows(Form1.StringGrid1, i, sg.RowCount - i - 1);
  end;
end;

{ RotLeft()
  Rotate given StringGrid @rots times by 90° to the left.
  Just a wrapper for function RotRight().

  @sg   IN/OUT - StringGrid to rotate.
  @rots     IN - Number of rotations.
}
procedure RotLeft(var sg : TStringGrid;
                  rots : Integer);
begin
  RotRight(sg, rots * 3);
end;






{/////////////////////////////////////////////
              SWIPE FUNCTIONS
}/////////////////////////////////////////////

{ SwipeRight()
  Shortcut function, allowing for another extra level of abstraction.
  Essentially moves all values to right, merges them and then moves again.
  For more information, lookup functions MergeRight() and PushRight().
  = Returns whether this function can actually change/do something(TRUE) or
    can't, which is later used for evaluating fail endgame.

  @sg       IN/OUT - StringGrid over which to operate.
  @execute      IN - Used to decide whether to allow changes to the subfunctions
                     (TRUE) or to just test their potential (FALSE).
}
function SwipeRight(var sg : TStringGrid; execute : Boolean) : Boolean;
var DoesSmthin : Boolean;
begin
  DoesSmthin := False;

  // Boolean operators placement order is crucial in circumstances like this
  DoesSmthin :=  (PushRight(sg, execute) > 0) or DoesSmthin;
  DoesSmthin := (MergeRight(sg, execute) > 0) or DoesSmthin;
  DoesSmthin :=  (PushRight(sg, execute) > 0) or DoesSmthin;

  SwipeRight := DoesSmthin;
end;

{ SwipeDown()
  Just a wrapper around SwipeRight(), rotates @sg and then applies right swipe.
  = Returns return value of SwipeRight() function.

  @sg       IN/OUT - StringGrid over which to operate.
  @execute      IN - Used to decide whether to allow changes to the subfunctions
                     (TRUE) or to just test their potential (FALSE).
}
function SwipeDown(var sg : TStringGrid; execute : Boolean) : Boolean;
begin
  RotLeft(sg, 1);
  SwipeDown := SwipeRight(sg, execute);
  RotRight(sg, 1);
end;

{ SwipeLeft()
  Just a wrapper around SwipeRight(), rotates @sg and then applies right swipe.
  = Returns return value of SwipeRight() function.

  @sg       IN/OUT - StringGrid over which to operate.
  @execute      IN - Used to decide whether to allow changes to the subfunctions
                     (TRUE) or to just test their potential (FALSE).
}
function SwipeLeft(var sg : TStringGrid; execute : Boolean) : Boolean;
begin
  RotRight(sg, 2);
  SwipeLeft := SwipeRight(sg, execute);
  RotLeft(sg, 2);
end;

{ SwipeUp()
  Just a wrapper around SwipeRight(), rotates @sg and then applies right swipe.
  = Returns return value of SwipeRight() function.

  @sg       IN/OUT - StringGrid over which to operate.
  @execute      IN - Used to decide whether to allow changes to the subfunctions
                     (TRUE) or to just test their potential (FALSE).
}
function SwipeUp(var sg : TStringGrid; execute : Boolean) : Boolean;
begin
  RotRight(sg, 1);
  SwipeUp := SwipeRight(sg, execute);
  RotLeft(sg, 1);
end;

{ TryMove()
  Evaluates whether any of Swipe*() function can be used to continue to play the
  game.
  = Returns boolean 'True' if any move is possible i.e. game can continue,
    otherwise returns 'False'.

  @sg IN - StringGrid over which to try moves.
}
function TryMove(sg : TStringGrid) : Boolean;
var canSwipe : Boolean;
    chosenButton : Integer;
begin
  canSwipe := SwipeUp(sg, False) or SwipeDown(sg, False) or
              SwipeLeft(sg, False) or SwipeRight(sg, False);
  TryMove := canSwipe;

  if not(canSwipe) then
     begin
      chosenButton := MessageDlg('No more possible moves, You Failed!', mtError, [mbOK, mbRetry], 0);
      if (chosenButton = mrRetry) then
        ResetGame(sg)
      else
        begin
          Form1.upbtn.Enabled := False;
          Form1.downbtn.Enabled := False;
          Form1.leftbtn.Enabled := False;
          Form1.rightbtn.Enabled := False;
        end;
     end;
end;






{/////////////////////////////////////////////
                USER INPUT
}/////////////////////////////////////////////

// SWIPE DOWN
procedure TForm1.Button1Click(Sender: TObject);
begin
  if (SwipeDown(Form1.StringGrid1, True)) then
    begin
      mvIndicatorLabel.Caption := (Sender As TButton).Caption[1];
      newRandCell(Form1.StringGrid1);
    end;
  TryMove(Form1.StringGrid1);
end;

// SWIPE LEFT
procedure TForm1.leftbtnClick(Sender: TObject);
begin
  if (SwipeLeft(Form1.StringGrid1, True)) then
    begin
      mvIndicatorLabel.Caption := (Sender As TButton).Caption[1];
      newRandCell(Form1.StringGrid1);
    end;
  TryMove(Form1.StringGrid1);
end;

// SWIPE UP
procedure TForm1.upbtnClick(Sender: TObject);
begin
  if (SwipeUp(Form1.StringGrid1, True)) then
    begin
      mvIndicatorLabel.Caption := (Sender As TButton).Caption[1];
      newRandCell(Form1.StringGrid1);
    end;
  TryMove(Form1.StringGrid1);
end;

// SWIPE RIGHT
procedure TForm1.rightbtnClick(Sender: TObject);
begin
  if (SwipeRight(Form1.StringGrid1, True)) then
    begin
      mvIndicatorLabel.Caption := (Sender As TButton).Caption[Length((Sender As TButton).Caption)];
      newRandCell(Form1.StringGrid1);
    end;
  TryMove(Form1.StringGrid1);
end;

// RESET game
procedure TForm1.RESETbtnClick(Sender: TObject);
begin
  ResetGame(StringGrid1);
end;




{/////////////////////////////////////////////
            GAME START/RENDER
}/////////////////////////////////////////////

// Gets called for each cell in StringGrid.Cells
procedure TForm1.StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  { If youd apply a switcheroo to these two boolean expression below, youd get
    an error ( '' Isn't a valid integer value! ) because:

    If you use boolean 'and', Delphi firstly asks whether the first expression
    is True, and if NOT it doesn't even try to evaluate the second expression,
    thus not trying to evaluate EMPTY as integer.
  }
  if (StringGrid1.Cells[ACol, ARow] <> EMPTY) and
     (StrtoInt(StringGrid1.Cells[ACol, ARow]) > MaxScore) then
    begin
      MaxScore := StrtoInt(StringGrid1.Cells[ACol, ARow]);
      ScoreLabel.Caption := IntToStr(MaxScore);
    end;

  if (MaxScore >= ENDGAMESCORE) and not(ReachedGoal) then
    begin
      ReachedGoal := True;
      MessageDlg('Goal of ' + IntToStr(ENDGAMESCORE) + ' reached!', mtInformation, [mbOK], 0);
    end;

end;

procedure TForm1.FormCreate(Sender: TObject);
  var n, size : integer;
begin
  size := 64;
  n := 4;

  with StringGrid1 do
  begin
    ColCount := n;
    RowCount := n;

    DefaultColWidth := size;
    DefaultRowHeight := size;
    GridLineWidth := 5;

    Width := (DefaultColWidth + GridLineWidth) * ColCount;
    Height := (DefaultRowHeight + GridLineWidth) * RowCount;
  end;

  Form1.Width := StringGrid1.Width + 2 * StringGrid1.GridLineWidth;
  Form1.Height := StringGrid1.Height + StringGrid1.Top * 2 + 100;

  ResetGame(StringGrid1);

  //StringGrid1.Cells[0,0] := '12345';
end;

end.
