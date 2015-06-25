unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Timer1: TTimer;
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Button1Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure TimeOn(Sender: TObject);
    procedure Strike(x, y, act: integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  type bulls = record
    x,y: integer;
    act: integer;
    time: TTimer;
    fl: boolean;
    strike: boolean;
  end;


var
  Form1: TForm1;
  tank: array [1..4] of TBitMap;
  wall, bull, nobull: TBitMap;
  actT, mX, mY: integer;
  t: TTimer;
  iB: integer;
  bullM: array[1..1000] of bulls;
  wallC: array[1..3] of TColor;
implementation

{$R *.dfm}

procedure Cart();
var
  j: integer;
begin
  with Form1.Canvas do begin
    Draw(22, 30, wall);
    j := 23;
    while (j < Form1.Width - 100) do begin
      Draw(j, 30, wall);
      inc(j, 13);
    end;

    Draw(250, 125, wall);
    Draw(270, 125, wall);

    j := 57;
    while(j < 130) do begin
      Draw(j, 110, wall);
      Draw(j, 122, wall);
      inc(j, 12);
      Draw(j + 250, 145, wall);
      Draw(j + 350, 90, wall);
    end;
    j := 160;
    while(j < 200) do begin
      Draw(35, j, wall);
      inc(j, 12);
    end;
    j := 55;
    while(j < 150) do begin
      Draw(210, j, wall);
      inc(j, 12);
    end;
    j := 85;
    while(j < 235) do begin
      Draw(j, 200, wall);
      inc(j, 12);
    end;
  end;
end;

function Prov(x, y, act: integer):boolean;  //проверка при движении танка
var
  i: integer;
begin
  result := true;
  if(act = 1) then begin
    for i := x to x+22 do begin
      if(Form1.Canvas.Pixels[i, y-1] <> clblack) then begin
        result := false;
      end;
    end;
  end;
  if(act = 2) then begin
    for i := x to x+22 do begin
      if(Form1.Canvas.Pixels[i, y+23] <> clblack) then begin
//        Form1.Canvas.Brush.Color := Form1.Canvas.Pixels[i, y+1];
//        Form1.Canvas.Rectangle(550, 550, 600, 600);
//        ShowMessage(Form1.Canvas.Pixels[i, y+1]);
        result := false;
      end;
    end;
  end;
  if(act = 3) then begin
    for i := y to y+22 do begin
      if(Form1.Canvas.Pixels[x+23, i] <> clblack) then begin
        result := false;
      end;
    end;
  end;
  if(act = 4) then begin
    for i := y to y+22 do begin
      if(Form1.Canvas.Pixels[x-1, i] <> clblack) then begin
        result := false;
      end;
    end;
  end;

end;

function wallPr(c: TColor): boolean;      //проверка, совпадает ли цвет пикселя с цветом стены
var
  k: integer;
begin
  result := false;
  for k := 1 to 3 do begin
    if(c = wallC[k]) then begin
      result := true;
    end;
  end;
end;

procedure clearWall(x, y, act: integer);
var
  i, j: integer;
  n1, n2: integer;
begin
  if (act = 1) or (act = 2) then begin
    if(act = 1) then begin
      n1 := 5; n2 := 0;
    end
    else begin
      n1 := 0; n2 := 5;                               // для уничтожения стен сверху и снизу
    end;
    for i := x-4 to x+5 do begin
        for j := y-n1 to y+n2 do begin
          if(wallPr(Form1.Canvas.Pixels[i, j])) then begin
            Form1.Canvas.Pixels[i, j] := clblack;
          end;
        end
    end;
  end;
  if (act = 3) or (act = 4) then begin
    if(act = 3) then begin
      n1 := 0; n2 := 5;
    end
    else begin
      n1 := 5; n2 := 0;                               // для уничтожения стен справа и слева
    end;
    for i := y-4 to y+5 do begin
        for j := x-n1 to x+n2 do begin
          if(wallPr(Form1.Canvas.Pixels[j, i])) then begin
            Form1.Canvas.Pixels[j, i] := clblack;
          end;
        end
    end;
  end;
end;

procedure TForm1.TimeOn(Sender: TObject);
var
  tX, tY: integer;
  i: integer;
  f: boolean;
begin
  if ((bullM[iB].x < 0) or (bullM[iB].y < 0) or (bullM[iB].x > Form1.Width) or (bullM[iB].y > Form1.Height)) then begin
    Form1.Canvas.Rectangle(bullM[iB].x-2, bullM[iB].y-2, bullM[iB].x+4, bullM[iB].y+3);
    bullM[iB].time.Destroy;
    bullM[iB].fl := false;
  end;

  if(bullM[iB].act = 1) then begin
    f := true; //можно рисовать пулю
    with Form1.Canvas do begin
      if(bullM[iB].strike) then begin
        Brush.Color := clBlack;
        Rectangle(bullM[iB].x-2, bullM[iB].y-2+10, bullM[iB].x+4, bullM[iB].y+3+10); //закрашиваем пулю
      end;
      for i := mY downto bullM[iB].y do begin
        if(wallPr(Pixels[bullM[iB].x+1, i]) or (wallPr(Pixels[bullM[iB].x, i]))) then begin
          //ShowMessage('Yes mX: ' + inttostr(mX) + ' mY: ' + inttostr(mY) + ' bullY: ' + inttostr(bullM[iB].y));
          Rectangle(bullM[iB].x-2, bullM[iB].y-2+10, bullM[iB].x+4, bullM[iB].y+3+10); //закрашиваем пулю
          bullM[iB].time.Destroy;
          bullM[iB].fl := false;
          clearWall(bullM[iB].x, i, bullM[iB].act); //чистим стену
          f := false;
          break;
        end;
      end;
      if (f) then begin
        Brush.Color := clWhite;
        Rectangle(bullM[iB].x-2, bullM[iB].y-2, bullM[iB].x+4, bullM[iB].y+3);
        bullM[iB].strike := true;
        //для act = 1;
        dec(bullM[iB].y, 10);
      end;
    end;
  end;

  if(bullM[iB].act = 2) then begin
    f := true; //можно рисовать пулю
    with Form1.Canvas do begin
      if(bullM[iB].strike) then begin
        Brush.Color := clBlack;
        Rectangle(bullM[iB].x-2, bullM[iB].y-2-10, bullM[iB].x+4, bullM[iB].y+3-10); //закрашиваем пулю
      end;
      for i := mY to bullM[iB].y do begin
        if(wallPr(Pixels[bullM[iB].x+1, i]) or (wallPr(Pixels[bullM[iB].x, i]))) then begin
          Rectangle(bullM[iB].x-2, bullM[iB].y-2-10, bullM[iB].x+4, bullM[iB].y+3-10); //закрашиваем пулю
          bullM[iB].time.Destroy;
          bullM[iB].fl := false;
          clearWall(bullM[iB].x, i, bullM[iB].act); //чистим стену
          f := false;
          break;
        end;
      end;
      if (f) then begin
        Brush.Color := clWhite;
        Rectangle(bullM[iB].x-2, bullM[iB].y-2, bullM[iB].x+4, bullM[iB].y+3);
        bullM[iB].strike := true;
        //для act = 1;
        inc(bullM[iB].y, 10);
      end;
    end;
  end;

  if(bullM[iB].act = 3) then begin
    f := true; //можно рисовать пулю
    with Form1.Canvas do begin
      if(bullM[iB].strike) then begin
        Brush.Color := clBlack;
        Rectangle(bullM[iB].x-2-10, bullM[iB].y-2, bullM[iB].x+3-10, bullM[iB].y+4); //закрашиваем пулю
      end;
      for i := mX to bullM[iB].x do begin
        if(wallPr(Pixels[i, bullM[iB].y+1]) or (wallPr(Pixels[i, bullM[iB].y]))) then begin
          //ShowMessage('Yes mX: ' + inttostr(mX) + ' mY: ' + inttostr(mY) + ' bullY: ' + inttostr(bullM[iB].y));
          Rectangle(bullM[iB].x-2-10, bullM[iB].y-2, bullM[iB].x+3-10, bullM[iB].y+4); //закрашиваем пулю
          bullM[iB].time.Destroy;
          bullM[iB].fl := false;
          clearWall(i, bullM[iB].y, bullM[iB].act); //чистим стену
          f := false;
          break;
        end;
      end;
      if (f) then begin
        Brush.Color := clWhite;
        Rectangle(bullM[iB].x-2, bullM[iB].y-2, bullM[iB].x+3, bullM[iB].y+4);
        bullM[iB].strike := true;
        //для act = 1;
        inc(bullM[iB].x, 10);
      end;
    end;
  end;

  if(bullM[iB].act = 4) then begin
    f := true; //можно рисовать пулю
    with Form1.Canvas do begin
      if(bullM[iB].strike) then begin
        Brush.Color := clBlack;
        Rectangle(bullM[iB].x-2+10, bullM[iB].y-2, bullM[iB].x+3+10, bullM[iB].y+4); //закрашиваем пулю
      end;
      for i := mX downto bullM[iB].x do begin
        if(wallPr(Pixels[i, bullM[iB].y+1]) or (wallPr(Pixels[i, bullM[iB].y]))) then begin
          //ShowMessage('Yes mX: ' + inttostr(mX) + ' mY: ' + inttostr(mY) + ' bullY: ' + inttostr(bullM[iB].y));
          Rectangle(bullM[iB].x-2+10, bullM[iB].y-2, bullM[iB].x+3+10, bullM[iB].y+4); //закрашиваем пулю
          bullM[iB].time.Destroy;
          bullM[iB].fl := false;
          clearWall(i, bullM[iB].y, bullM[iB].act); //чистим стену
          f := false;
          break;
        end;
      end;
      if (f) then begin
        Brush.Color := clWhite;
        Rectangle(bullM[iB].x-2, bullM[iB].y-2, bullM[iB].x+3, bullM[iB].y+4);
        bullM[iB].strike := true;
        //для act = 1;
        dec(bullM[iB].x, 10);
      end;
    end;
  end;

end;


procedure TForm1.Strike(x, y, act: integer);
var
  step : integer;
begin
  iB := 1;
  if(bullM[iB].fl = false) then begin
    bullM[iB].time := TTimer.Create(Form1);
    bullM[iB].time.Interval := 200;
    bullM[iB].time.OnTimer := TimeOn;
    bullM[iB].strike := false;

    bullM[iB].act := act;
    if(act = 1) then begin
      bullM[iB].x := mX + 10;
      bullM[iB].y := mY - 3;
    end;

    if(act = 2) then begin
      bullM[iB].x := mX + 10;
      bullM[iB].y := mY + 22 + 3;
    end;

    if(act = 3) then begin
      bullM[iB].x := mX + 22 + 3;
      bullM[iB].y := mY + 10;
    end;

    if(act = 4) then begin
      bullM[iB].x := mX - 3;
      bullM[iB].y := mY + 10;
    end;

    bullM[iB].fl := true;
    bullM[iB].time.Enabled := true;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i: integer;
begin
  Form1.Button1.Enabled := false;
  for i := 1 to 4 do begin
    tank[i] := TBitMap.Create;
  end;
  tank[1].LoadFromFile(string(GetCurrentDir + '\res\pl_up.bmp'));
  tank[2].LoadFromFile(string(GetCurrentDir + '\res\pl_down.bmp'));
  tank[3].LoadFromFile(string(GetCurrentDir + '\res\pl_right.bmp'));
  tank[4].LoadFromFile(string(GetCurrentDir + '\res\pl_left.bmp'));

  Form1.Canvas.Draw(Form1.Width div 2, Form1.Height div 2, tank[1]);
  mX := Form1.Width div 2;
  mY :=  Form1.Height div 2;
  actT := 1;


  Cart();
  Form1.Focused;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.Width := 300;
  Form1.Height := 300;
  Form1.Color := clblack;
  wall := TBitMap.Create();
  wall.LoadFromFile(string(GetCurrentDir + '\res\bl_1.bmp'));
  bull := TBitMap.Create();
  bull.LoadFromFile(string(GetCurrentDir + '\res\bull.bmp'));
  nobull := TBitMap.Create();
  nobull.LoadFromFile(string(GetCurrentDir + '\res\nobull.bmp'));

  iB := 0;
//  Form1.Timer1.Enabled := true;
  bullM[1].fl := false;

  wallC[1] := RGB(198,113,0);
  wallC[2] := RGB(165,48,0);
  wallC[3] := RGB(192,192,192);

end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
var
  i: integer;
begin
//  ShowMessage(inttostr(ord(Key)));
  with Form1.Canvas do begin
    if(ord(Key) = 1094) or (ord(Key) = 119) then begin
      if(actT = 1) then begin
          if(Prov(mX, mY, actT)) then begin
            Brush.Color := clblack;
            Rectangle(mX, mY, mX + 22, mY + 22);
            Draw(mX, mY - 1, tank[1]);
            dec(mY, 1);
          end;
      end
      else begin
        Rectangle(mX, mY, mX + 22, mY + 22);
        Draw(mX, mY, tank[1]);
        actT := 1;
      end;
    end;
    if(ord(Key) = 1099) or (ord(Key) = 115)  then begin
      if(actT = 2) then begin
          if(Prov(mX, mY, actT)) then begin
            Brush.Color := clblack;
            Rectangle(mX, mY, mX + 22, mY + 22);
            Draw(mX, mY + 1, tank[2]);
            inc(mY, 1);
          end;
      end
      else begin
        Rectangle(mX, mY, mX + 22, mY + 22);
        Draw(mX, mY, tank[2]);
        actT := 2;
      end;
    end;
    if(ord(Key) = 1074) or (ord(Key) = 100)  then begin
      if(actT = 3) then begin
        if(Prov(mX, mY, actT)) then begin
          Brush.Color := clblack;
          Rectangle(mX, mY, mX + 22, mY + 22);
          Draw(mX + 1, mY, tank[3]);
          inc(mX, 1);
        end;
      end
      else begin
        Rectangle(mX, mY, mX + 22, mY + 22);
        Draw(mX, mY, tank[3]);
        actT := 3;
      end;
    end;
    if(ord(Key) = 1092) or (ord(Key) = 97)  then begin
      if(actT = 4) then begin
        if(Prov(mX, mY, actT)) then begin
          Brush.Color := clblack;
          Rectangle(mX, mY, mX + 22, mY + 22);
          Draw(mX - 1, mY, tank[4]);
          dec(mX, 1);
        end;
      end
      else begin
        Rectangle(mX, mY, mX + 22, mY + 22);
        Draw(mX, mY, tank[4]);
        actT := 4;
      end;
    end;
    if(ord(Key) = 1081) or (ord(Key) = 113)  then begin
      Strike(mX, mY, actT);
    end;

  end;

end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
//  Form1.Caption := 'X: ' + inttostr(x) + '  y: ' + inttostr(y);
//  Form1.Canvas.Pixels[x,y] := RGB(Random(255), Random(255), Random(255));
end;

end.
