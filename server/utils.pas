// полезные функции
{$R-,S-,B-}
unit utils;
interface

uses
  Windows, Graphics, Classes, SysUtils, ComCtrls, strUtils, forms, dialogs, messages, shellApi, math,
  registry, zLib, {$if CompilerVersion > 18}imaging.pngimage,{$ifEnd} jpeg;


type
int =integer;
str =ansiString;
chr =ansiChar;
bool=boolean;
Taos =array of str;
Taoi =array of int;
taaoi=array of taoi;
Taosi=array of smallInt;
Talw =array of longWord;
Taob =array of byte;
const
logFile='log.txt';
fontS=12; fontT={'Courier';//}'Consolas'; // шрифт текстов
DA=#13#10; // разделитель строк в файлах
BR='<br>'; // разделитель строк в html

type // hash массив: h:=THash.Create; h['key']:='Значение';  if h.find('key') then showMessage('найдено значение '+h.val);
  THash = class(TObject)
    i,l,nFind:int;
    k,v: array[0..255] of taos;
    val:str;
    p:^taos;
    function  find(key:str):bool;
    function  GetValue(const key: str): str;
    procedure putValue(const key: str; val:str);
    property  keyVal[const key: str]:str read GetValue write PutValue; default;
  end;

var
DecimalSeparator: char;
cd: str;   // dir exe
pExe: str; // путь: cd+'/'
timeStart,t2,a1,a2,counterPerSec : TLargeInteger;
clearRich: bool=true;
splitQ: int;        // размер массива результата split
pt1,pt2:int;        // позиции текстов в tmt
sWidth,sHeight:int; // размеры экрана
stmt: str;          // весь текст в tmt вместе с текстами, между которыми
ntmt: bool;         // нет текста в tmt
wLog,rLog:bool;     // Писать в logFile, выполнять
runS:taos; runN:int=-1; // Для выполнения из лога
rrr: int;  sss:str; // временные рабочие
prog:  bool=false;  // компонент измененяет программа - не выполнять другите

procedure iniUtils;
function  read(const n:str): str;           // чтение файла в строку
function  readL(const n:str; q:int): taos;  // чтение последних q строк файла в массив
function  readByte(fileName:str):taob;      // чтение файла в массив байт
procedure write(const imf, s: str);         // запись строки s в файл imf
procedure writeE(const imf, s:str; e:bool); // запись строки s в файл imf, e-в конец
procedure moveFile(const p; n:str; q:int); overLoad; // вывод в файл n из памяти p q байт
procedure moveFile(n:str; const p; q:int); overLoad; // ввод из файла n в память p q байт
procedure copyFile(Const InfileName, OutFileName: String);
function  testFile(f:str):str; // проверка наличия файла с выходом без него
function  IsDriveRemovable(const fileName: str): bool;
procedure log(const s:str; time:bool=false);  overLoad;  // запись строки s в конец файла
procedure log(const title:str; const a:taos); overLoad;  // запись массива a по строкасм в конец файла
function  getFiles(path:str; s:bool=false):Taos; // имена файлов из папки в массив
function  getFileName(const iniDir:str; t:str='Select File'; f:str='All|*.*'):str; // выбор имени файла из тех что есть
procedure delFiles(const p:str);         // удаление файлов в папке
function  efn(const s: str): str;        // extracFileName
function  dsl(s:str; r:char='/'):str;    //добавка / в конец, если ещё нет
procedure message(const s1:str;s2:str='');
function  perf:int64; var t:int64;
function  mSec:int64;  //  время в мсек от t1
function  ms2s:str;    // мСек в сек.12
function  split(const s:str; r: str=' '):Taos;
function  splitI(const s:str)  :Taoi; // из строки с числами через ' ' в массив чисел
function  join(m:Taos; const r:str; n:int=0; k:int=0): str; overLoad
function  join(m:Taoi; const r:str; n:int=0): str; overLoad
procedure push (var m:Taos; const s:str); overload;
procedure push1(var m:Taos; const s:str); overload;  // только в 1 экземпляре
procedure push (var m:Taoi; const s:int); overload;
procedure push (var m:Taob; s:byte);      overload;
function  concat(m1: Taos; m2:Taos; m3:Taos=nil): Taos; // объединение 2 или 3 массивов
function  s2m(const s:str;q:int):Taos; // создание массива длиной q из строк s
function  splice(m:Taos; n,q:int; z:Taos=nil):Taos; overload;      // замена в массиве m с позиции n q элементов на массив z
function  splice(const s:str; n,q:int; const z:str):str; overload; // замена с позиции n q позиций на z
function  trimA(a: Taos):Taos;          // trim всех элементов
function  delEmpty(m:taos):taos;        // удаление пустых
//function  l2a(sl:tStringList):taos;     // tStringList в taos
function  tmt (const s,t1:str; t2:str=''):str; // текст между
function  tmts(const s,t1:str; t2:str=''):str; // текст между и весь сравнённый текст в stmt
function  utm (s,t1:str; t2:str=''):str; // удалить текст между t1 и t2
function  val(s:str):str;                // значение после =
function  amp2bm(s:str):str;       // замена &gt; &lt; на ><
function  bm2amp(s:str):str;       // наоборот
function  rex (s,r:str): Taos; // текст вместо *
//function  addT(s:str; t1:str; t2:str; n1:str; n2:str):str;// добавка n1 после t1 и n2 перед t2
function  ren(const s,r:str):Taos; // имя из ~...~ в r,  значение на месте имени в s...
function  getVar(const par,s: str): str;
function  getF  (const par,s: str): single;
function  getI  (const par,s: str): int;
function  f2(f:single):str;
function  f1(f:single):str;         // 0.0
function  f0(f:single):str;         // удаление последних нулей
function  f3(f:single):str;         // 0.00
function  fv(const n:str;f:single):str; // n:f;
function  pv(const n:str;f:single):str; // n:f 4 значащие цифры;
function  fs(f:single): str;        // floatToStr 4 значащие цифры
function  toScreen(xywh:str):str;   // реальные координаты в относительно экрана
function  fromScreen(xywh:str):str; // координаты из относительно экрана в реальные
function  rzs(const s:str):str;     // замена запрещённых в именах файлах символов
function  timeF:str;                // форматирование текущего времени для имени файла
function  reg(root:int; key:str):str;  // чтение реестра
function  delLast(const s:str; c:chr):str; // удаление символов в конце
function  delCom(const s:str):str;         // удаление комментариев
function  repl (const s,o:str; n:str=''):str;
function  repl1(const s,o,n:str):str;
function  repl2(const s,o,n,o2,n2:str):str;
function  replS(s,z:str; r:str='|'):str;// замена по списку в z с разделителем r
procedure rep(var s:str; const o:str; const n:str=''); // замена на месте
function  ins(w,s: str; p:int):str;      // вставка как функция
function  ups(const s:str):str;          // удаление последнего символа
function  u1 (const s:str):str;          // удаление первого символа
function  copyK(const s:str; p:int):str; // copy до конца
function  setSep(const s:str):str;   // замена ,. на текущий DecimalSeparator
function  fn(const n:str):str;       // имя файла
function  ps(const p,s:str):bool;    // pos bool
function  bs(const p,s:str): bool;   // в начале строки s есть p;
function  posEx(const substr : str; const s : str; const start: int=1):int;
function  posR(const o,s: str; start: int=1):int; // поиск подстроки между разделителями
function  psR (const o,s: str; start: int=1):bool;// поиск подстроки между разделителями
function  repR(s,o,n:str; r1:bool=false):str;// замена подстроки между разделителями, r1-1 раз
function  trim(const S: str): str;
function  posL(const p,s:str):int;    // pos last
function  psi(const s:str)   :str;    // последний символ
function  dcd(const s:str;r:char='\'):str; // добавка cd - текущего директория
function  EncodeBase64(const inStr:   str): str;
function  DecodeBase64(const CinLine: str): str;
function  ToAnotherCodePage(const Source: String; FromCodePage, ToCodePage: LongWord) : string;
function  Utf8ToWin(s: string): string;
function  ConvertDfm(strOld: string): string;
//function  Utf8ToAnsi(const s:string):str;
function  enCodeUrl(const source:str):str;  // кодирование в %16
function  str2zip(var s:str; filein:str=''):str; // упаковка строки или файла в строку
function  zip2str(b: str): str;            // распаковка из строки в строку
function  extractFiles(run:bool=true):taos; // извлечение файлов из exe программы, собранной exe_plus
procedure key_ru; // переключение языка клавиатуры
procedure key_en;
function  ru(s:string):bool; // русский текст
function  sKl(k:int) : bool; // состояние клавиш vk_Control vk_Shift vk_Menu
function  ifi(u:bool;t:int;f:int=0):int;    // u? t:f
function  ifs(u:bool;const t:str; const f:str=''):str;   // u? t:f
function  ifc(u:bool;t:chr;f:chr=' '):chr;  // u? t:f
function  ifb(u:bool;t:bool;f:bool=false):bool; // u? t:f
function  ifr(u:bool;t:real;f:real=0):real; // u? t:f
function  pri(var i:int; v:int):int;     // i:=v присвоение в выражении
function  prs(var i:str; const v:str):str;     // i:=v присвоение в выражении
function  ui(var i:int):int; // i++
procedure inf(var f: real; v: real); overload; // inc для float
procedure def(var f: real; v: real); overload; // dec для float
procedure inf(var f: extended; v: extended); overload; // inc для float
procedure def(var f: extended; v: extended); overload; // dec для float
function  og(i,min:int; max:int=maxInt):int;  overload;// ограничение в пределах
function  og(i,min:single;max:single=maxInt):single; overload;
function  i2s(i:int):str;        // укорочение
function  i2h(i:int):str;        // укорочение
function  f2s(f:real):str;       // укорочение
function  b2s(b:bool):str;    // укорочение
function  s2i(const s:str; d:int=-1):int; // укорочение
function  s2f(const s:str; d:real=0):real;// укорочение
procedure setDecimalSeparator;
function  psl(s:str):str; // первое слово до пробела
function  getTxt(const t,s,n:str; var r:str):bool; // получение текста от человека t-заголовок,s-приглашение,n-начальное значение,r-результат
function  wopros(const s:str):bool; // спросить человека
function  open(const FileName: string):bool; // показ файла программой, связанной с этим типом файла
function  tg(const c:int; size:int=0; font:str=''):str; // тег с цветом и размером шрифта
function  ConvertHtmlHexToTColor(Col: str): graphics.TColor;
procedure html2rich(const txtHTML: str; var rchHTML_: TRichEdit);
function  exeAndWait_old(const ExeNameAndParams: string; ncmdShow: Integer = SW_SHOWNORMAL): Integer;
function  ExeAndWait(CmdLine, params: shortString; const winState: Word=SW_NORMAL; wait:bool=true): bool; export;
procedure killSelf;
function  findWin(const w:str):bool; overload; // есть ли окно
function  findWin(title:str; var wnd:hwnd; var s:str; t:bool=true):bool; overload; // поиск окна по заголовку или части - t=false
function  findWin(title:str; var s:str):bool; overload;// поиск окна по части и возврат в s полного названия
function  listWin():str;       // вывод списка окон
procedure clickMouse(x,y:int); // нажатие мыши в координатах
procedure forceForegroundWindow(hwnd: THandle); // окно на передний план
function  send(const s,frame: str):bool;// посылка сообщение окну frame
procedure setFocusApl;            // установка приложения в фокус
function  glueForm(f:tForm):bool; // прилипание формы к краям экрана
procedure centr(f:tForm);         // форма в ценрт экрана
function  delPE(const f:str):str; // удаление pExe в имени файла
function  ic(c:int; i:int):int;   // изменение яркости
function  jpg2bmp(const f:str; var w:int; var h:int; js:tJpegScale=jsFullSize):TBitmap; // чтение файла jpg в bitmap
function  png2bmp(const f:str; var w:int; var h:int):tBitmap;
procedure bmp2a(bmp:tBitmap; var a:taoi; free:bool=true); // из bitmap в массив
procedure a2bmp(a:taoi; w,h:int; var bmp:tBitmap);        // из массива в bmp
procedure a2jpg(a:taoi; w,h:int; const f:str; jq:int=90); // из массива в файл
procedure bmp2jpg(bmp:tBitmap; const f:str; jq:int=90);   // из bitmap в jpg
function  findImage(const f:str; var xi,yi:int):bool;     // поиск картнки из файла на экране и возврат координат её середины
function  findM(const s:str; m:taos):bool; // поиск строки s в массиве m
function  b4ToBin32(var Value): string;    // 4 байта в строку битов 01
function form2s(f:tForm; name:str='form'): str;  // размеры формы в строку
procedure s2form(s:str; var form);         // строка в размеры формы
procedure wav2a(const wav:str; var a:taob);// данные wav в массив

implementation

var
colI: int; nameI: str; // до изменение для возврата
rchHTML: TRichEdit;
conFirst:bool=false;
//br: bool=false;

function ic(c:int; i:int):int; // изменение яркости
var c3:array[0..3] of byte absolute c; n:int;
begin
  n:=c3[0]+i; if n<0 then n:=0 else if n>255 then n:=255; c3[0]:=n;
  n:=c3[1]+i; if n<0 then n:=0 else if n>255 then n:=255; c3[1]:=n;
  n:=c3[2]+i; if n<0 then n:=0 else if n>255 then n:=255; c3[2]:=n;
  result:=c;
end;

function jpg2bmp(const f:str; var w:int; var h:int; js:tJpegScale=jsFullSize):tBitmap; // чтение jpg в bmp
var jpg : tJpegImage;
begin
  perf;
  if not fileExists(f) then begin w:=0; h:=0; message('Не найден файл '+f); end
  else begin
       jpg:=tJpegImage.Create;
       jpg.Scale:=js;
       jpg.LoadFromFile(f);
       w:=jpg.Width;
       h:=jpg.Height;
  end;
  result:=TBitmap.Create;
  result.pixelformat:=pf32bit;
  result.width:=w;
  result.height:=h;
  if w=0 then exit;
  result.canvas.draw(0,0,jpg);
  jpg.free;
  rrr:=msec;
end;

function png2bmp(const f:str; var w:int; var h:int):tBitmap;
{$if CompilerVersion > 18}
var png: TPngImage;
begin
  png := TPngImage.Create;
  result:=TBitmap.Create; result.pixelformat:=pf32bit;
  try
    png.LoadFromFile(f);
    w:=png.width;   result.width :=w;
    h:=png.height;  result.height:=h;
    if w=0 then exit;
    result.Assign(png);
  finally
    PNG.Free;
  end;
{$else}
begin 
result:=nil;
{$ifEnd}
end;

{
procedure bmp2a_(bmp:tBitmap; var a:taoi); // из bitmap в массив
type ab4=array[0..3] of byte;
var w,h,x,y,c,r,g,b:int;   line: ^longWord; ab:^ab4;
begin
  w:=bmp.Width;
  h:=bmp.Height;
  setLength(a,w*h);
  For y:=0 to h-1 do Begin
    line :=bmp.scanline[h-y-1];   // flip JPEG
    For x:=0 to w-1 do Begin
      c:=Line^ and $FFFFFF; // Need to do a color swap
      r:=c and $FF;
      g:=(c and $FF00) shr 8;
      b:=c shr 16;
      a[x+y*w] :=    b+(g shl 8)+(r shl 16)+$FF000000;//($FF shl 24);
      inc(line);
    End;
  End;
  bmp.free;
end;
}
procedure bmp2a(bmp:tBitmap; var a:taoi; free:bool=true); // из bitmap в массив
type ab4=array[0..3] of byte;
var w,h,x,y,p:int; r:byte;  ab:^ab4;
begin
  w:=bmp.Width;
  h:=bmp.Height;
  setLength(a,w*h);
  p:=0;
  for y:=h-1 downTo 0 do Begin
    ab:=bmp.scanline[y];   // flip JPEG
    for x:=0 to w-1 do begin
        r:=ab^[0];
        ab^[0]:=ab^[2];
        ab^[2]:=r;
        ab^[3]:=255;
        inc(ab);
    end;
    move(bmp.scanline[y]^,a[p],w*4);
    inc(p,w);
  end;
  if free then bmp.free;
end;

procedure a2bmp(a:taoi; w,h:int; var bmp:tBitmap); // из массива в bmp
var  p1,p2: pbytearray; y,j:int;    pbuf: pointer;
begin
   bmp := TBitmap.Create; bmp.PixelFormat := pf32bit; bmp.Width :=w; bmp.Height:=h;
   pBuf:=@a[0];
   w:=w*4;
   dec(h);
   for y := 0 to h do begin
      p1:=bmp.ScanLine[y];
      p2:=pointer(int(pbuf)+ (h-y) * w);
      j:=0;
      while j<w do begin // CopyMemory( p1, p2, bmp.Width * 4);
         p1[j]  :=p2[j+2];
         p1[j+1]:=p2[j+1];
         p1[j+2]:=p2[j];
         //if y>500 then p1[j+3]:=110 else
         p1[j+3]:=255;
         inc(j,4);
      end;
   end;
end;

procedure bmp2jpg(bmp:tBitmap; const f:str; jq:int=90);
var  jpg : tJpegImage;
begin
   jpg:=TJPEGImage.Create;
   jpg.Assign(bmp);
   jpg.CompressionQuality:=jq;
   jpg.SaveToFile(f);
   jpg.Free;
end;

procedure a2jpg(a:taoi; w,h:int; const f:str; jq:int=90); // из массива в файл jpg
var  bmp: TBitmap; p1,p2: pbytearray; y,j:int;    pbuf: pointer;
begin
   bmp := TBitmap.Create; bmp.PixelFormat := pf32bit; bmp.Width :=w; bmp.Height:=h;
   pBuf:=@a[0];
   w:=w*4;
   dec(h);
   for y := 0 to h do begin
      p1:=bmp.ScanLine[y];
      p2:=pointer(int(pbuf)+ (h-y) * w);
      j:=0;
      while j<w do begin // CopyMemory( p1, p2, bmp.Width * 4);
         p1[j]  :=p2[j+2];
         p1[j+1]:=p2[j+1];
         p1[j+2]:=p2[j];
         p1[j+3]:=255;
         inc(j,4);
      end;
   end;

   bmp2jpg(bmp, f, jq);
   bmp.Free;
end;

function getTxt(const t,s,n:str; var r:str):bool; // получение текста от человека t-заголовок,s-приглашение,n-начальное значение,r-результат
var a:string;
begin
   a:=n;
   result:=InputQuery(t, ifs(s[1]='я',' '+s,s), a);
   r:=trim(a);
end;

function wopros(const s:str):bool; begin result:=messageDlg(s,mtConfirmation,[mbYes,mbNo],0)=idYes end; // спросить человека

function  delPE(const f:str):str; begin if bs(pExe,f) then result:=repl1(f,pExe,'') else result:=f end; // удаление pExe

function efn(const s: str): str; // extracFileName
var i: int;
begin
  for i:=length(s) downto 1 do
    if s[i] in ['\','/'] then begin result:=copyK(s,i+1); exit end;
  Result:=s;
end;

procedure setDecimalSeparator;
begin
   DecimalSeparator:=',';
//delphi7-14    delphi11-35
   {$if CompilerVersion > 18} FormatSettings.DecimalSeparator:=DecimalSeparator;
   {$else}                    sysutils.DecimalSeparator:=DecimalSeparator;
   {$ifEnd}
end;

procedure iniUtils; // инициализация переменных utils в начале
begin
setDecimalSeparator;
//11 LongTimeFormat := 'hh:mm.zzz'; // для log
QueryPerformanceFrequency(counterPerSec); // число тиков в секунду
cd:=ansiLowerCase(extractFileDir(application.exeName));
pExe:=cd+'\';
sWidth:=screen.Width; sHeight:=screen.Height;
end;

procedure key_ru;
  var Layout: array[0.. KL_NAMELENGTH] of char;
  begin LoadKeyboardLayout(StrCopy(Layout,'00000419'),KLF_ACTIVATE) end;
procedure key_en;
  var Layout: array[0.. KL_NAMELENGTH] of char;
  begin LoadKeyboardLayout(StrCopy(Layout,'00000409'),KLF_ACTIVATE) end;

function ru(s:string):bool;
var i: integer; qa,qr: integer; c:char;
begin
  qa:=0; qr:=0;
  for i:=length(s) downTo 1 do begin
     c:=s[i];
     if ((c>='A') and (c<='Z')) or  ((c>='a') and (c<='z')) then inc(qa) else
     if  (c>='А') and (c<='я') then inc(qr);
  end;
  result:=qr>qa
end;


function sKl(k:int) : bool; // состояние клавиш vk_Control vk_Shift vk_Menu
var State : TKeyboardState;
begin GetKeyboardState(State); Result := ((State[k] and 128) <> 0) end;

{-------------------------------------------------------------------------------}
{  Find the position of a substring in a string starting at a certain position  }
{-------------------------------------------------------------------------------}
function  posEx(const substr: str; const s: str; const start: int=1):int;
Type StrRec = record
       allocSiz: Longint;
       refCnt: Longint;
       length: Longint;
     end;
Const  skew = sizeof(StrRec);
asm
{     ->EAX     Pointer to substr               }
{       EDX     Pointer to string               }
{       ECX     Pointer to start      //cs      }
{     <-EAX     Position of substr in s or 0    }

        TEST    EAX,EAX
        JE      @@noWork
        TEST    EDX,EDX
        JE      @@stringEmpty
        TEST    ECX,ECX           //cs
        JE      @@stringEmpty     //cs

        PUSH    EBX
        PUSH    ESI
        PUSH    EDI

        MOV     ESI,EAX                         { Point ESI to  }
        MOV     EDI,EDX                         { Point EDI to  }

        MOV     EBX,ECX        //cs save start
        MOV     ECX,[EDI-skew].StrRec.length    { ECX =    }
        PUSH    EDI                             { remember s position to calculate index }

        CMP     EBX,ECX        //cs
        JG      @@fail         //cs

        MOV     EDX,[ESI-skew].StrRec.length    { EDX = bstr)          }

        DEC     EDX                             { EDX = Length(substr) -   }
        JS      @@fail                          { < 0 ? return             }
        MOV     AL,[ESI]                        { AL = first char of       }
        INC     ESI                             { Point ESI to 2'nd char of substr }
        SUB     ECX,EDX                         { #positions in s to look  }
                                                { = Length(s) - Length(substr) + 1      }
        JLE     @@fail
        DEC     EBX       //cs
        SUB     ECX,EBX   //cs
        JLE     @@fail    //cs
        ADD     EDI,EBX   //cs

@@loop:
        REPNE   SCASB
        JNE     @@fail
        MOV     EBX,ECX                         { save outer loop                }
        PUSH    ESI                             { save outer loop substr pointer }
        PUSH    EDI                             { save outer loop s              }

        MOV     ECX,EDX
        REPE    CMPSB
        POP     EDI                             { restore outer loop s pointer      }
        POP     ESI                             { restore outer loop substr pointer }
        JE      @@found
        MOV     ECX,EBX                         { restore outer loop nter    }
        JMP     @@loop

@@fail:
        POP     EDX                             { get rid of saved s nter    }
        XOR     EAX,EAX
        JMP     @@exit

@@stringEmpty:
        XOR     EAX,EAX
        JMP     @@noWork

@@found:
        POP     EDX                             { restore pointer to first char of s    }
        MOV     EAX,EDI                         { EDI points of char after match        }
        SUB     EAX,EDX                         { the difference is the correct index   }
@@exit:
        POP     EDI
        POP     ESI
        POP     EBX
@@noWork:
end;

function Trim(const S: str): str;
var
  I, L: int;
begin
  L:=length(S);
  I:=1;
  if (L>0) and (S[I]>' ') and (S[L]>' ') then begin result:=s; exit end;
  while (I<=L) and (S[I]<=' ') do Inc(I);
  if I>L then begin result:=''; exit end;
  while S[L]<=' ' do Dec(L);
  result:=copy(S, I, L-I+1);
end;

procedure message(const s1:str;s2:str=''); begin showMessage(s1) end;
function testFile(f:str):str;    begin if fileExists(f) then result:=f else begin message('Нужен файл '+f); halt; end end;
function QPCounter:int64;var t:int64; begin QueryPerformanceCounter(t); result:=t end;
function perf:int64; begin result:=QPCounter; timeStart:=result end;
function mSec:int64; begin result:=(QPCounter-timeStart)*1000 div counterPerSec end;
function ms2s:str;   begin result:=f2(mSec/1000) end;
function trimA(a: Taos):Taos; var i:int; begin for i:=0 to length(a)-1 do a[i]:=trim(a[i]); result:=a end;
function ifi(u:bool;t:int;f:int=0):int;   begin if u then result:=t else result:=f end; // u? t:f
function ifs(u:bool; const t:str; const f:str='') :str; begin if u  then result:=t else result:=f end;
function ifc(u:bool;t:chr;f:chr=' '):chr; begin if u then result:=t else result:=f end;
function ifr(u:bool;t:real;f:real=0):real;begin if u then result:=t else result:=f end;
function ifb(u:bool;t:bool;f:bool=false):bool;begin if u then result:=t else result:=f end;
function ui(var i:int):int;          begin ui:=i; inc(i) end; // i++
procedure inf(var f: real; v: real); overload; begin f:=f+v end; // inc для float
procedure def(var f: real; v: real); overload; begin f:=f-v end; // dec для float
procedure inf(var f: extended; v: extended); overload; begin f:=f+v end; // inc для float
procedure def(var f: extended; v: extended); overload; begin f:=f-v end; // dec для float
function pri(var i:int; v:int):int;        begin i:=v;  pri:=v end; // i:=v присвоение в выражении
function prs(var i:str; const v:str):str;  begin i:=v;  prs:=v end; // i:=v присвоение в выражении
function repl (const s,o:str; n:str=''):str; begin result:=StringReplace(s,o,n,[rfReplaceAll]) end;
function repl1(const s,o,n:str):str;       begin result:=StringReplace(s,o,n,[]) end;
function repl2(const s,o,n,o2,n2:str):str; begin result:=StringReplace(StringReplace(s,o,n,[rfReplaceAll]), o2,n2,[rfReplaceAll]) end;
procedure rep(var s:str; const o:str; const n:str=''); begin s:=StringReplace(s,o,n,[rfReplaceAll]) end; // замена на месте
function  ins(w,s: str; p:int)    :str;    begin insert(w,s,p); result:=s end; // вставка как функция
function  ps(const p,s:str)       :bool;   begin result:=posEx(p,s)>0 end;
function  bs(const p,s:str)       :bool;   begin result:=posEx(p,s)=1 end;     // в начале строки s есть p;
function  ups(const s:str)        :str;    begin ups:=copy(s,1,length(s)-1) end;
function  u1 (const s:str)        :str;    begin u1 :=copy(s,2,maxInt) end;
function  copyK(const s:str;p:int):str;    begin result:=copy(s,p,maxInt) end;
function  setSep(const s:str) :str;        begin result:=repl(repl(s,'.',DecimalSeparator),',',DecimalSeparator) end;
function  fn    (const n:str) :str;        begin result:=ansiLowerCase(changeFileExt(efn(n),'')) end;
function  og(i,min:int; max:int=maxInt):int;  overload;// ограничение в пределах
   begin  if i<min then result:=min else if i>max then result:=max else result:=i end;
function  og(i,min,max:single):single; overload;
   begin  if i<min then result:=min else if i>max then result:=max else result:=i end;
function  zsl(const s,r:str):str;
begin
  if r='/' then result:=repl(s,'\','/') else
  if r='\' then result:=repl(s,'/','\') else
  result:=s
end;
function  dcd(const s:str;r:char='\'):str;
begin
  if not ps(':', s) then result:=zsl(dsl(cd,r),r)+s else result:=s
end;
function  psi(const s:str):str; begin if s='' then psi:='' else psi:=s[length(s)] end; // последний символ

function open(const FileName: string):bool;
begin
  result := ShellExecute(0, 'open', PChar(FileName), nil, nil, SW_SHOWNORMAL)>32; // Успешное выполнение если результат > 32
end;

function  replS(s,z:str; r:str='|'):str;// замена по списку в z с разделителем r
var m:taos; i:int;
begin
  m:=trimA(split(z,r));
  result:=s;
  if length(m)<2 then exit;
  i:=0; while i<high(m) do begin rep(result,m[i],m[i+1]); inc(i,2) end
end;

function posR(const o,s: str; start: int=1):int;// поиск подстроки между разделителями
var p,k:int;
const buk: set of ansiChar = ['А'..'я','Ё','ё','A'..'Z','a'..'z','0'..'9'];
begin
while pri(p,posEx(o,s,start))>0 do begin
   k:=p+length(o);
   if ((p>1) and (s[p-1] in buk)) or ((k<=length(s)) and (s[k] in buk)) then start:=p+1
   else begin result:=p; exit end
end;
result:=0;
end;
function psR(const o,s: str; start: int=1):bool;// поиск подстроки между разделителями
begin result:=posR(o,s,start)>0 end;

function repR(s,o,n:str; r1:bool=false):str;// замена подстроки между разделителями, r1-1 раз
var i,p:int;
begin
i:=1;
while pri(p,posR(o,s,i))>0 do begin
  i:=p+length(o);
  s:=copy(s,1,p-1)+n+copyK(s,i);
  if r1 then break;
end;
result:=s;
end;

function  posL(const p,s:str):int;   // pos last
var i:int;
begin
  i:=0; result:=0;
  while true do begin i:=posEx(p,s,i+1); if i>0 then result:=i else break end;
end;

function fs(f:single): str; // floatToStr 4 значащие цифры
var i,q: byte; s:str; z,e,exp:bool; c: chr;
begin
  s:=floatToStr(f);
  z:=false; e:=true; exp:=false; result:=''; q:=0;
  for i := 1 to length(s) do begin
      c:=s[i];
      if not (c in['-','0','.',',','+']) then z:=true;
      if z and (c<>',') and (c<>'.')     then inc(q);
      if c='E' then begin result:='0'; exit end; //exp:=true; e:=true end;
      if (q>4) and not exp               then e:=false;
      if e then result:=result+c;
  end;
end;

function toScreen(xywh:str):str; // реальные координаты в относительно экрана
var a:taos; i:int;
begin
a:=split(xywh);
result:='';
for i:=0 to high(a) do
    result:=result+ifs(i>0,' ')+i2s(s2i(a[i])*10000 div ifi(i in[0,2],sWidth,sHeight))
end;

function fromScreen(xywh:str):str; // координаты из относительно экрана в реальные
var a:taos; i:int;
begin
a:=split(xywh);
result:='';
for i:=0 to high(a) do
    result:=result+ifs(i>0,' ')+i2s(s2i(a[i])*ifi(i in[0,2],sWidth,sHeight) div 10000)
end;

function reg(root:int; key:str):str;  // чтение реестра
var  Reg : TRegistry;
begin
  result := '';
  Reg := TRegistry.Create;
  Reg.RootKey := root; //HKEY_LOCAL_MACHINE;
  if Reg.OpenKeyReadOnly(key) then
  begin
    if Reg.ValueExists('')  then result := Reg.ReadString('');
    Reg.CloseKey;
  end;
  Reg.Free;
end;

function rzs(const s:str):str; begin result:=repl(repl2(s,'/','-',':','-'),'.','_') end;  // замена запрещённых в именах файлах символов
function timeF           :str; begin result:=rzs(DateToStr(now))+'_'+rzs(TimeToStr(now)) end;// форматирование текущего времени для имени файла
function delLast(const s:str; c:chr):str; begin result:=s; while result[length(result)]=c do result:=copy(result,1,length(result)-1) end;
function delCom(const s:str):str;
var p:int;
begin
 p:=pos('//',s); if p>0 then result:=copy(s,1,p-1) else result:=s;
end;
function f1(f:single):str; begin result:=formatFloat('0.0',f)   end;
function f2(f:single):str; begin result:=formatFloat('0.00',f)  end;
function f3(f:single):str; begin result:=formatFloat('0.000',f) end;
function f0(f:single):str; begin result:=repl(delLast(delLast(f2(f),'0'),','),',','.') end;
function fv(const n:str; f:single):str; begin result:=' '+n+':'+f2(f)+';' end;
function pv(const n:str; f:single):str; begin result:=' '+n+':'+fs(f)+';' end;
procedure push (var m:Taos; const s:str); overload; begin setLength(m,length(m)+1); m[length(m)-1]:=s end;
procedure push1(var m:Taos; const s:str); overload; begin if not findM(s,m) then push(m,s) end; // только в 1 экземпляре
procedure push(var m:Taoi; const s:int);  overload; begin setLength(m,length(m)+1); m[length(m)-1]:=s end;
procedure push(var m:Taob; s:byte); overload;  begin setLength(m,length(m)+1); m[length(m)-1]:=s end;
//function  l2a(sl:tStringList):taos; var i:int; begin setLength(result,sl.Count); for i:=0 to sl.count-1 do result[i]:=sl.strings[i] end;

function delEmpty(m:taos):taos;// удаление пустых
var i,j:int;
begin
setLength(result,length(m));
j:=0; for i:=0 to high(m) do if trim(m[i])<>'' then result[ui(j)]:=m[i];
setLength(result,j);
end;

function split(const s:str; r: str=' '):Taos;
var i,l,n:int;
begin
l:=length(r);
setLength(result,og(length(s),1,1000));
splitQ:=0;
n:=1;
while true do begin
   i:=posEx(r,s,n);
   if splitQ>=length(result) then setLength(result,length(result)+1000);
   if i<1 then begin result[splitQ]:=copy(s,n,length(s)-n+1); inc(splitQ); break; end;
   result[splitQ]:=copy(s,n,i-n);
   inc(splitQ);
   n:=i+l;
end;
setLength(result,splitQ);
end;

function splitI(const s:str):Taoi; // из строки с числами в массив чисел
var m:Taos; i,q: int;
begin
  m:=split(s,' ');
  setLength(result,length(m));
  q:=0;
  for i:=0 to high(m) do if m[i]<>'' then begin
      result[q]:=strToIntDef(trim(m[i]),-1);
      //if result[q]>=0 then 
      inc(q);
  end;
  setLength(result,q);
end;

function join(m:Taos; const r:str; n:int=0; k:int=0): str; overLoad
var i:int;
begin
  result:='';
  if k=0 then k:=high(m);
  for i:=n to k do result:=result+ifs(i>n,r)+m[i];
end;
function join(m:Taoi; const r:str; n:int=0): str; overLoad
var i:int;
begin
  result:='';
  for i:=n to high(m) do result:=result+ifs(i>n,r)+intToStr(m[i]);
end;

function concat(m1: Taos; m2:Taos; m3:Taos=nil): Taos;
var i,q: int;
begin
  q:=length(m1);
  setLength(result,q + ifi(m2=nil,0,length(m2)) + ifi(m3<>nil,length(m3)));
  for i:=0 to high(m1) do result[i]:=m1[i];
  if m2<>nil then for i:=0 to high(m2) do result[ui(q)]:=m2[i];
  if m3<>nil then for i:=0 to high(m3) do result[ui(q)]:=m3[i];
end;

function s2m(const s:str; q:int):Taos; // создание массива длиной q из строк s
var i:int;
begin
  setLength(result,q); for i:=0 to high(result) do result[i]:=s;
end;

function splice(m:Taos; n,q:int; z:Taos=nil):Taos;overload; // замена в массиве m с позиции q элементов на массив z
begin
  result:=concat(copy(m,0,n), z, copy(m,n+q,length(m)-n-q));
end;
function splice(const s:str; n,q:int; const z:str):str; overload; // замена с позиции n q позиций на z
begin
  result:=copy(s,1,n-1)+z+copyK(s,n+q)
end;

function tmt(const s, t1:str; t2:str=''):str; // текст между
var pt:int;
begin
  if t1='' then pt1:=1 else pt1:=pos(t1,s);
  if pt1<=0 then begin result:=''; exit end;
  pt:=pt1+length(t1);
  if t2='' then pt2:=length(s)+1 else pt2:=posEx(t2,s,pt);
  if pt2<=0 then begin result:=''; exit end;
  result:=copy(s,pt,pt2-pt);
end;

function tmts(const s, t1:str; t2:str=''):str; // текст между и весь сравнённый текст в stmt
begin
result:=tmt(s,t1,t2);
if (pt1<=0) or (pt2<=0) then begin stmt:=''; ntmt:=true end
   else begin stmt:=copy(s,pt1,pt2+length(t2)-pt1); ntmt:=false end
end;

function  utm(s,t1:str; t2:str=''):str; // удалить текст между t1 и t2
var p,k:int;
begin
  if t1='' then p:=1 else p:=pos(t1,s);
  if p<=0 then begin result:=s; exit end;
  inc(p,length(t1));
  if t2='' then k:=length(s)+1 else k:=posEx(t2,s,p);
  if k<=0 then begin result:=s; exit end;
  delete(s,p,k-p);
  result:=s
end;

function val(s:str):str; begin result:=tmt(s,'=') end;

function rex(s,r:str):Taos; // текст вместо *
var t: Taos; i: int;
begin
  t:=split(r,'*');
  setLength(result,length(t)-1);
  for i:=0 to high(result) do begin
     result[i]:=tmt(s,t[i],t[i+1]);
     delete(s,1,pt2-1);
  end;
end;
{
function addT(s:str; t1:str; t2:str; n1:str; n2:str):str;// добавка n1 после t1 и n2 перед t2
var i,p,l1,l2:int;
begin
p:=1; l1:=length(t1);  l2:=length(t2);
while true do begin
  i:=posEx(t1,s,p); if i<1 then break; s:=copy(s,1,i)+n1+copy(s,i+l1); p:=i+length(n2)+l1-1;
  i:=posEx(t2,s,p); if i<1 then break; s:=copy(s,1,i-1)+n2+copy(s,i);  p:=i+length(n2)+l2;
end;
result:=s;
end;
}
function ren(const s,r:str):Taos; // имя из ~...~ в r,  значение на месте имени в s...
var i,q:int; t: Taos;
begin
  t:=split(r,'~');
  setLength(result,length(t)-1);
  i:=0; q:=0;
  while i<length(t)-1 do begin
     result[q]:=t[i+1];             inc(q);
     result[q]:=tmt(s,t[i],t[i+2]); inc(q);
     inc(i,2);
  end;
end;

function getFiles(path:str; s:bool=false):Taos;
var SR: TSearchRec; q: int;
begin
  q:=0;
  if path<>'' then begin
  path:=dsl(path);
  if FindFirst(path + '*.*', faAnyFile, SR)=0 then begin
     repeat
        if (sr.name='.') or (sr.name='..') then continue;
        if (sr.Attr and faDirectory)>0 then begin
           if s then begin
              result:=concat(copy(result,0,q),getFiles(path+sr.name,true));
              q:=length(result);
           end;
           continue;
        end;
        if length(result)<=q then setLength(result,length(result)+100);
        result[q]:=SR.Name;
        inc(q);
     until FindNext(SR)<>0;
     FindClose(SR);
  end;
  end;
  setLength(result,q);
end;

function getFileName(const iniDir:str; t:str='Select File'; f:str='All|*.*'):str;
var openDialog:TopenDialog;
begin
openDialog:=TopenDialog.Create(nil);
with openDialog do begin
   if iniDir<>'' then begin
      initialDir:=iniDir;
      if not fileExists(iniDir) then createDir(iniDir);
   end;
   Title:=t;
   Filter:=f;
   if execute then result:=fileName else result:='';
end;
openDialog.free;
end;

function  dsl(s:str; r:char='/'):str; //добавка / в конец, если ещё нет
begin
if (s='') or not ps(s[length(s)],'/\') then result:=s+'/' else result:=s;
end;

procedure delFiles(const p:str); // удаление файлов в папке
var m: taos; i:int;
begin
m:=getFiles(p);
for i:=0 to high(m) do deleteFile(dsl(p)+m[i]);
end;

function read(const n:str): str; // чтение файла imf в строку
  var f: file; fs: int;
  begin
  fileMode:=0;
  assignFile(f,n);
  {$i-} reset(f,1); {$i+}
  fileMode:=2;
  if ioresult<>0 then begin result:=''; {message('Не найден файл '+n,'read');} exit; end;
  fs:=fileSize(f);
  setLength(result,fs);
  blockRead(f,result[1],fs);
  closeFile(f);
end;

function readByte(fileName:str):taob;
var f:file; fs:int;
begin
  fileMode:=0;
  assignFile(f,fileName);
  {$i-} reset(f,1); {$i+}
  if ioresult<>0 then begin setLength(result,0); exit; end;
  fileMode:=2;
  fs:=fileSize(f);
  setLength(result,fs);
  blockRead(f,result[0],fs);
  closeFile(f);
end;


function  readL(const n:str; q:int): taos;  // чтение последних q строк файла imf в массив
  var f: file; fs,nf,nm,maxL: int; s:str;
  begin
  fileMode:=0;  assignFile(f,n);  {$i-}reset(f,1);{$i+}  fileMode:=2;
  if ioresult<>0 then begin setLength(result,0); exit; end;
  fs:=fileSize(f);
  maxL:=100;
  while True do begin
     nf:=max(fs-q*maxL,0);
     seek(f,nf);
     setLength(s,fs-nf);
     blockRead(f,s[1],length(s));
     result:=split(s,#13#10);
     if (nf>0) and (length(result)-1<q) then begin maxL:=maxL*2; continue end;
     nm:=max(length(result)-q,0);
     result:=copy(result,nm,q);
     break;
  end;
  closeFile(f);
end;

procedure writeE(const imf, s:str; e:bool); // запись строки s в файл imf, e-в конец
var
h: int;
begin
  if not fileExists(imf) then h:=FileCreate(imf) else
  begin
      h:=FileOpen(imf, fmOpenWrite);
      if e then FileSeek(h, 0, 2);
  end;
  FileWrite(h, s[1],length(s));
  SetEndOfFile(h);
  FileClose(h);
end;

procedure write(const imf,s:str); // запись строки s в файл imf
begin writeE(imf,s,false) end;

procedure moveFile(const p; n:str; q:int); overLoad; // вывод в файл n из памяти p q байт
var f:file;  s:pChar;
begin
s:=pChar(@p); assignFile(f,n); rewrite(f,1); blockWrite(f,s[0],q); closeFile(f);
end;
procedure moveFile(n:str; const p; q:int); overLoad; // ввод из файла n в память p q байт
var f:file;  s:pChar;
begin
fileMode:=0; s:=pChar(@p); assignFile(f,n); reset(f,1); blockRead(f,s[0],q); closeFile(f); fileMode:=2;
end;

procedure copyFile(Const InfileName, OutFileName: String);
Const BufSize = 3*4*4096; { 48Kbytes дает прекрасный результат }
Type
PBuffer = ^TBuffer;
TBuffer = array [1..BufSize] of Byte;
var
Size             : int;
Buffer           : PBuffer;
infile, outfile  : File;
begin
if (InFileName <> OutFileName) then begin
  buffer := Nil;
  fileMode:=0;
  AssignFile(infile, InFileName);
  System.Reset(infile, 1);
  fileMode:=2;
  try
    AssignFile(outfile, OutFileName);
    System.Rewrite(outfile, 1);
    try
      New(Buffer);

      repeat
         BlockRead(infile, Buffer^, BufSize, Size);
         BlockWrite(outfile,Buffer^, Size)
      until Size < BufSize;

      FileSetDate(TFileRec(outfile).Handle, FileGetDate(TFileRec(infile).Handle));

    finally
      if Buffer <> Nil then Dispose(Buffer);
      System.close(outfile)
    end;

  finally
    System.close(infile);
  end;
end else
Raise EInOutError.Create('File cannot be copied into itself');
end;

function IsDriveRemovable(const fileName: str): bool;
begin
result:=GetDriveType(PChar(ExtractFileDrive(fileName))) = DRIVE_REMOVABLE
end;

procedure log(const s:str; time:bool=false); overLoad; // запись строки s в конец файла
var t:string;
begin
if time then DateTimeToString(t, 'nn:ss.zzz', tDateTime(now)) else t:='';
writeE(pExe+logFile, t+' '+s+#13,conFirst); conFirst:=true
end;
procedure log(const title:str; const a:taos); overLoad; // запись массива a по строкам в конец файла
var i: int; ai:str;
begin
  log(title);
  for i:=0 to high(a) do begin ai:=trim(a[i]); if ai<>'' then log('  '+i2s(i)+'. '+ai) end;
end;

function ExeAndWait(CmdLine, params: ShortString; const WinState: Word=SW_NORMAL; wait:bool=true): bool; export;
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  pathFileName: String;
  exeName: string;
begin
  if CmdLine=''      then begin result:=false; exit end;
  if CmdLine[1]='"'  then exeName:=tmt(CmdLine,'"','"') else
  if ps(' ',CmdLine) then exeName:=tmt(CmdLine,'',' ') else
                          exeName:=CmdLine;
  pathFileName:=ExtractFilePath(repl2(exeName,'/','\', '"',''));
  if pathFileName='' then pathFileName:=cd+'\'; 
  if params    <>''  then CmdLine:=CmdLine+' '+params;
  FillChar(StartInfo, SizeOf(StartInfo), #0);
  with StartInfo do
  begin
    cb := SizeOf(StartInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := WinState;
  end;
  sss:=CmdLine+'------'+pathFileName;
  Result := CreateProcess(nil, PChar( String( CmdLine ) ), nil, nil, false,
                          CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil,
                          PChar(pathFileName),StartInfo,ProcInfo);

  if wait and Result then { Ожидаем завершения приложения }
  begin
    WaitForSingleObject(ProcInfo.hProcess, INFINITE);
  end;
  if result then begin { Free the Handles }
     CloseHandle(ProcInfo.hProcess);
     CloseHandle(ProcInfo.hThread);
  end
//  else message('Не удалось запустить'#13+cmdLine);
end;

function extractFiles(run:bool=true):taos; // извлечение файлов из exe программы, собранной exe_plus
var
  FullPath: string;
  p,n,k:int; name,c,name1,r,exe,path,markFiles:str; a:taos;  pack:bool;
begin
  r:='--------';
  setLength(result,1);
  exe:=read(paramStr(0));
  //exe:=read('run_browser.exe'); // для отладки
  n:=posEx('<'+r,exe);
  if n<1 then begin result[0]:='not found files in exe'; exit; end;
  k:=posEx(r+'>',exe);
  path:=copy(exe,n+9,k-n-9); // путь для распаковки | первый файл с параметрами, чтобы не распаковывать повторно
  a:=split(path,'|');
  if length(a)>1 then name1:=a[1] else name1:='';
  path:=a[0];
  path:=repl(path,'{temp}',   GetEnvironmentVariable('TEMP'));
  path:=repl(path,'{appdata}',GetEnvironmentVariable('APPDATA'));
  if not directoryExists(path) or (name1='') then begin // уже есть - не переписывать
  ForceDirectories(path);   // Создаем директорий
  exe:=copy(exe, k+9,maxInt);
  pack:=(length(exe)<12) or (copy(exe,1,12)<>'<!--fileName');
  if pack then exe:=zip2str(exe);
  n:=1; name1:='';
  markFiles:='<!--';
  markFiles:=markFiles+'fileName=';
  p:=posEx('<!--fileName=',exe,n);
  while p>0 do begin
      k:=posEx('-->'#13,exe,p);
      name:=copy(exe,p+13,k-p-13);
      if name1='' then begin name1:=name; name:=split(name)[0] end;
      n:=k+4;
      p:=posEx('<!--fileName=',exe,n);
      if p<1 then k:=length(exe)+1 else k:=p;
      c:=copy(exe,n,k-n);
      fullPath := path+ '\' + extractFileName(name);
      if c<>'' then write(FullPath,c);
  end;
  end;

  chDir(path);
// Запускаем первый файл с параметрами из текущей команды + после имени файла  'browser.exe index.html'
  if run then WinExec(pAnsiChar(path+'\'+name1), SW_SHOWNORMAL);
  result[0]:=path;
  a:=split(name1);
  for n:=1 to high(a) do push(result,a[n]);
end;

procedure killSelf; begin WinExec(PANsiChar('TASKKILL /F /IM '+efn(application.exeName)), SW_HIDE) end;
(*
function ExeAndWait_(const CmdLine: ShortString; const WinState: Word; wait:bool=true): bool; export;
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
//  CmdLine: ShortString;
  fileName:  ShortString;
begin
  fileName:=ifs(CmdLine[1]='"', tmt(CmdLine,'"','"'), tmt(CmdLine,'',' '));
//if not fileExists(fileName) then begin message('ExeAndWait: Нет файла '#13+filename); result:=false; exit end;

  { Помещаем имя файла между кавычками, с соблюдением всех пробелов в именах Win9x }
//  CmdLine := '"' + Filename + '" ' + Params;
  FillChar(StartInfo, SizeOf(StartInfo), #0);
  with StartInfo do
  begin
    cb := SizeOf(StartInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := WinState;
  end;
  Result := CreateProcess(nil, PChar( String( CmdLine ) ), nil, nil, false,
                          CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil,
                          PChar(ExtractFilePath(Filename)),StartInfo,ProcInfo);

  if wait and Result then begin { Ожидаем завершения приложения }
    WaitForSingleObject(ProcInfo.hProcess, INFINITE);
    CloseHandle(ProcInfo.hProcess);
    CloseHandle(ProcInfo.hThread);

  end;
  {if result then begin // Free the Handles
  CloseHandle(ProcInfo.hProcess);
  CloseHandle(ProcInfo.hThread);
  end
  else
  message('Не удалось запустить'#13+cmdLine);}
end;
*)
{function ExeAndWait2(const FileName, Params: ShortString; const WinState: Word; wait:bool=true): bool;
begin
result:=ExeAndWait(FileName+' '+Params,WinState,wait);
end;}

function ExeAndWait_old(const ExeNameAndParams: string; ncmdShow: Integer = SW_SHOWNORMAL): Integer;
var
    StartupInfo: TStartupInfo;
    ProcessInformation: TProcessInformation;
    lpExitCode: DWORD;
begin
    with StartupInfo do //you can play with this structure
    begin
        cb := SizeOf(TStartupInfo);
        lpReserved := nil;
        lpDesktop := nil;
        lpTitle := nil;
        dwFlags := STARTF_USESHOWWINDOW;
        wShowWindow := ncmdShow;
        cbReserved2 := 0;
        lpReserved2 := nil;
    end;
    CreateProcess(nil, PChar(ExeNameAndParams), nil, nil, True, CREATE_DEFAULT_ERROR_MODE or NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInformation);
    while True do
    begin
        GetExitCodeProcess(ProcessInformation.hProcess, lpExitCode);
        if lpExitCode <> STILL_ACTIVE then Break;
        Application.ProcessMessages;
    end;
    Result := Integer(lpExitCode);
end;

function getVar(const par,s: str): str;    begin result:=tmt(s,' '+par+':',';')    end;
function getF  (const par,s: str): single; begin result:=strToFloat(getVar(par,s)) end;
function getI  (const par,s: str): int;    begin result:=strToInt(getVar(par,s))   end;

function tg(const c:int; size:int=0; font:str=''):str; begin
   result:='<#'+i2h(c);
   if size >0  then result:=result+' '+i2s(size);
   if font<>'' then result:=result+' '+font;
   result:=result+'>'
end;

function ConvertHtmlHexToTColor(Col: str): graphics.TColor; // <#цвет размер шрифт>
var p:int; s:str;
begin
  if rchHTML<>nil then with rchHTML.SelAttributes do begin
    p:=pos(' ',col);
    colI:=color;
//    sizI:=Size;
    nameI:=name;
    if p>0 then begin
       s:=copy(col,p+1,maxInt);
       col:=copy(col,1,p-1);
       p:=pos(' ',s);
       if p>0 then begin name:=copy(s,p+1,maxInt); s:=copy(s,1,p-1) end;
       //sizI:=Size;
       size:=s2i(s);
    end
    else size:=fontS;
    if col[2]<'0' then begin result:=ic(color,s2i(copy(col,2,maxInt))); exit end; // корекция яркости
  end;
  if length(col)=4 then col:='#'+col[2]+col[2]+col[3]+col[3]+col[4]+col[4];
  result:=StrToInt('$'+copy(col,2,maxInt));
end;

function amp2bm(s:str):str;
begin
result:=stringreplace(stringreplace(s,  '&gt;','>', [rfReplaceAll]), '&lt;', '<', [rfReplaceAll])
end;
function bm2amp(s:str):str;
begin
result:=stringreplace(stringreplace(s,  '>','&gt;', [rfReplaceAll]), '<','&lt;', [rfReplaceAll])
end;


procedure DisplayText(Tag: str; Buf:str);
begin
//There is a problem where if buf = '' the richedit attributes didn't get set
//so I included this shoddy fix.
//If you know why this bug happens please let me know.

//if (Buf='') and not br then Buf := #12;
(*
{$if CompilerVersion<19} //https://gist.github.com/jpluimers/b8c6b3bf29dbbf98a801f01beb8284a5
  if (Buf='') and not br then Buf := #12;
{$ifEnd}
*)
//in case we want to actually show a tag or the markers used for < and >
//Buf:=sc(buf);
//br:=false;
//if it's a font tag then send it to font handling
//go through all known tags, formatting richedit as appropriate
with rchHTML.SelAttributes do
if tag<>'' then
//if copy(tag, 0, 5) = 'font ' then FontTags(Tag, Buf) else
if tag[1]='#' then Color := ConvertHtmlHexToTColor(tag) else
if tag[1]='0'           then begin {size:=sizI;} color:=colI; name:=nameI end else
if tag[1] in ['1'..'9'] then begin {sizI:=size;} colI:=color; nameI:=name; size:=s2i(Tag) end else
//if copy(tag, 0, 6)='color='  then Color := ConvertHtmlHexToTColor(copy(tag,7,7)) else
if tag='b'  then style := style + [fsBold]   else
if tag='/b' then style := style - [fsBold]   else
//if tag='i'  then style := style + [fsItalic] else
//if tag='/i' then style := style - [fsItalic] else
//if tag='u'  then style := style + [fsUnderline] else
//if tag='/u' then style := style - [fsUnderline] else
   Buf:='<'+Tag+'>'+Buf;
end;

procedure html2rich(const txtHTML: str; var rchHTML_: TRichEdit);//<#цвет размер шрифт>
var
   Bumf ,t,s: str;
   i,j,k,p: int;
begin
rchHTML:=rchHTML_;
with rchHTML, rchHTML.SelAttributes do begin
  if clearRich then Clear else selStart:=length(text);
  style := [];
  Size := fontS;
  name := fontT;
  color:=$AAAAAA;
end;
Bumf := stringreplace(txtHTML, #13#10, '', [rfReplaceAll]);
p:=1;
while True do begin
   i:=posEx('<',bumf,p);
   if i=0 then begin if p=1 then rchHTML.SelText:=amp2bm(bumf); break end;
   if (p=1) and (i>1) then rchHTML.SelText:=amp2bm(copy(bumf,1,i-1));
   j:=posEx('>',bumf,i); if j=0 then break;
   k:=posEx('<',bumf,j); if k=0 then k:=length(bumf)+1;
   t:=lowerCase(copy(bumf,i+1,j-i-1));
   s:=copy(bumf,j+1,k-j-1);
   if t='br' then with rchHTML.SelAttributes do begin rchHTML.SelText := #13#10+s; {size:=sizI;} color:=colI; name:=nameI end
   else begin
     DisplayText(t, s);
     if s<>''  then rchHTML.SelText := amp2bm(s);
   end;
   p:=k;
end;
end;

function EncodeBase64(const inStr: str): str;
  const  Base64Code: str = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  function Encode_Byte(b: Byte): ansichar; begin Result := Base64Code[(b and $3F)+1] end;
  var i,q: int;
begin
  i:=1;  setLength(result,Length(inStr)*2);  q:=1;

  while i <=Length(InStr) do begin
    result[q]:=Encode_Byte (Byte(inStr[i]) shr 2); inc(q);
    result[q]:=Encode_Byte((Byte(inStr[i]) shl 4) or (Byte(inStr[i+1]) shr 4)); inc(q);
    if i+1 <=Length(inStr) then result[q]:=Encode_Byte((Byte(inStr[i+1]) shl 2) or (Byte(inStr[i+2]) shr 6))
                           else result[q]:='=';
    inc(q);
    if i+2 <=Length(inStr) then result[q]:=Encode_Byte(Byte(inStr[i+2]))
                           else result[q]:='=';
    inc(q);
    inc(i, 3);
  end;
  setLength(result,q-1);
end;

function EncodeBase64_old(const inStr: str): str;
  const  Base64Code: str = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  function Encode_Byte(b: Byte): ansichar; begin Result := Base64Code[(b and $3F)+1] end;
var i: int;
begin
  i := 1;
  Result := '';
  while i <=Length(InStr) do
  begin
    Result := Result + Encode_Byte(Byte(inStr[i]) shr 2);
    Result := Result + Encode_Byte((Byte(inStr[i]) shl 4) or (Byte(inStr[i+1]) shr 4));
    if i+1 <=Length(inStr) then
      Result := Result + Encode_Byte((Byte(inStr[i+1]) shl 2) or (Byte(inStr[i+2]) shr 6))
    else
      Result := Result + '=';
    if i+2 <=Length(inStr) then
      Result := Result + Encode_Byte(Byte(inStr[i+2]))
    else
      Result := Result + '=';
    Inc(i, 3);
  end;
end;

// Base64 decoding
function DecodeBase64(const CinLine: str): str;
const
  RESULT_ERROR = -2;
var
  inLineIndex: int;
  c: ansiChar;
  x: SmallInt;
  c4: Word;
  StoredC4: array[0..3] of SmallInt;
  InLineLength: int;
begin
  Result := '';
  inLineIndex := 1;
  c4 := 0;
  InLineLength := Length(CinLine);

  while inLineIndex <=InLineLength do  begin
    while (inLineIndex <=InLineLength) and (c4 < 4) do begin
      c := CinLine[inLineIndex];
      case c of
        '0'..'9': x := Ord(c) - (Ord('0')-52);
        'A'..'Z': x := Ord(c) -  Ord('A');
        'a'..'z': x := Ord(c) - (Ord('a')-26);
        '+'     : x := 62;
        '/'     : x := 63;
        '='     : x := -1;
      else
        x := RESULT_ERROR;
      end;
      if x <> RESULT_ERROR then begin
        StoredC4[c4] := x;
        Inc(c4);
      end;
      Inc(inLineIndex);
    end;

    if c4 = 4 then begin
      c4 := 0;
      Result := Result + ansiChar((StoredC4[0] shl 2) or (StoredC4[1] shr 4));
      if StoredC4[2] = -1 then Exit;
      Result := Result + ansiChar((StoredC4[1] shl 4) or (StoredC4[2] shr 2));
      if StoredC4[3] = -1 then Exit;
      Result := Result + ansiChar((StoredC4[2] shl 6) or (StoredC4[3]));
    end;
  end;
end;

function enCodeUrl(const source:str):str;// кодирование в %16
var i:int;
begin
  result := '';
  for i := 1 to length(source) do
      if not (source[i] in ['A'..'Z','a'..'z','0','1'..'9','-','_','~','.'])
         then result := result + '%'+inttohex(ord(source[i]),2)
         else result := result + source[i];
end;

function str2zip(var s:str; filein:str=''):str; // упаковка строки или файла в строку
var
  ms:TMemoryStream; //вспомогательный поток, куда будет загружен входной filein
  om:TMemoryStream;
  a: TCustomZLibStream; //поток архивации (взял абстрактный)
begin
 try
   ms:=TMemoryStream.Create;
   om:=TMemoryStream.Create;
   setLength(result,0);
   if fileIn<>'' then begin
      if not fileExists(filein) then begin showMessage('File not found "'+filein+'"'); exit; end;
      ms.LoadFromFile(filein); // входной файл в поток
   end
   else ms.write(s[1],length(s));
   try //создание архивирующего потока, запись данных будет идти в OutFile
       a:=TCompressionStream.Create(clMax,om);  // поток приёма сжатых данных
       try
          a.CopyFrom(ms,0);
       finally
          a.Free;
       end;
     finally
       ms.free;
       setLength(result, om.size);
       om.Position := 0;
       om.Read(result[1] ,om.Size);
       om.Free;
    end;
 except ;
 end;
end;

function zip2str(b: str): str; // распаковка из строки в строку
Const cBufferSize = 65536;
var
   Count: Integer;
   os: TMemoryStream; //выходной поток
   ZStream: TCustomZLibStream; //поток деархивации (взял абстрактный)
   Buffer: array[0..cBufferSize-1] of Byte; //временной буфер
   ms: TMemoryStream;
begin
 try
   result:='';
   ms:=TMemoryStream.Create();
   ms.write(b[1],length(b));
   ms.Seek(0,0);
   try
     os:= TMemoryStream.Create; //создадим выходной поток
     try
       ZStream:=TDecompressionStream.Create(ms); //поток распаковки файла, представленного массивом b или потоком ms
       try
         while True do begin
             Count:=ZStream.Read(Buffer,cBufferSize); //читаем распакованные данные в Buffer
             if Count <> 0 then os.WriteBuffer(Buffer, Count) //запись в выходной поток
             else Break;
         end;
        finally ZStream.Free;
        end;
      finally
      end;
   finally
     try
        setLength(result, os.size);
        os.Position := 0;
        os.Read(result[1] ,os.Size);
     finally
        os.Free;
     end;
  end;
 except ;
 end;
end;

function ToAnotherCodePage(const Source: String; FromCodePage, ToCodePage: LongWord) : string;
{https://www.sql.ru/forum/218841-2/dos866-windows-1251-i-naoborot
для поиска номера кодовой страницы пр названию HKEY_CLASSES_ROOT\MIME\Database\Charset
для поиска названия по номеру: HKEY_CLASSES_ROOT\MIME\Database\Codepage
для DOS866 - 866, для Windows 1251 - 1251}
type byte_arr = array of byte;
var byte_buffer_wide : pbyte; byte_buffer : pbyte;  l :int;

begin
   l := Length(Source);
   GetMem(byte_buffer_wide, l*2);
   fillchar(byte_buffer_wide^, l*2, 0);

   MultiByteToWideChar(FromCodePage, 0,
   PAnsiChar(Source), l,
   PWideChar(byte_buffer_wide), l*2);

   GetMem(byte_buffer, l);
   WideCharToMultiByte(ToCodePage, 0,  PWideChar(byte_buffer_wide), l, PAnsiChar(byte_buffer), l, nil, nil);

   while (l>0) and (string(byte_buffer)[l]=#0) do dec(l);
   Result := copy(string(byte_buffer), 1, l);

   FreeMem(byte_buffer_wide, l*2);
   FreeMem(byte_buffer, l);
end;

function ConvertDfm(strOld: string): string;
const
strUni : string = '#1072#1073#1074#1075#1076#1077#1108#1078#1079#1080#1110#1111#1081#1082#1083'+
'#1084#1085#1086#1087#1088#1089#1090#1091#1092#1093#1094#1095#1096#1097#1102#1103#1100'+
'#1040#1041#1042#1043#1044#1045#1028#1046#1047#1048#1030#1031#1049#1050#1051#1052#1053#1054#1055#1056#1057#1058#1059#1060#1061#1062#1063#1064#1065#1070#1071#1068#8470#1099#1067#1105#1025#1101#1069#1098#1066';
strWin : string = 'абвгде¦жзи¬©йклмнопрстуфхцчшщюяьАБВГДЕLЖЗИ¦¦ЙКЛМНОПРСТУФХЦЧШЩЮЯЬ¦ыЫёЁэЭъЪ';
var
letCount, i: int;
strNew: string;
begin
if pos('#',strOld) = 0 then
Result := strOld
else
begin
strNew := strOld;
letCount := length(strWin);
for i:=1 to letCount do
strNew := stringReplace(strNew, copy(strUni, (i-1)*5+1, 5), ''''+copy(strWin, i, 1)+'''', [rfReplaceAll]);
strNew := stringReplace(strNew, '''''', '', [rfReplaceAll]);
Result := strNew;
end;
end;

//function Utf8ToAnsi(const s:string):str; begin result:=System.UTF8ToString(s) end;
const
Utf2WinTable : array [0..65, 0..1] of string = (
   (#208#144,#192), (#208#145,#193), (#208#146,#194), (#208#147,#195), (#208#148,#196), (#208#149,#197),
   (#208#129,#168), (#208#150,#198), (#208#151,#199), (#208#152,#200), (#208#153,#201), (#208#154,#202),
   (#208#155,#203), (#208#156,#204), (#208#157,#205), (#208#158,#206), (#208#159,#207), (#208#160,#208),
   (#208#161,#209), (#208#162,#210), (#208#163,#211), (#208#164,#212), (#208#165,#213), (#208#166,#214),
   (#208#167,#215), (#208#168,#216), (#208#169,#217), (#208#170,#218), (#208#171,#219), (#208#172,#220),
   (#208#173,#221), (#208#174,#222), (#208#175,#223), (#208#176,#224), (#208#177,#225), (#208#178,#226),
   (#208#179,#227), (#208#180,#228), (#208#181,#229), (#209#145,#184), (#208#182,#230), (#208#183,#231),
   (#208#184,#232), (#208#185,#233), (#208#186,#234), (#208#187,#235), (#208#188,#236), (#208#189,#237),
   (#208#190,#238), (#208#191,#239), (#209#128,#240), (#209#129,#241), (#209#130,#242), (#209#131,#243),
   (#209#132,#244), (#209#133,#245), (#209#134,#246), (#209#135,#247), (#209#136,#248), (#209#137,#249),
   (#209#138,#250), (#209#139,#251), (#209#140,#252), (#209#141,#253), (#209#142,#254), (#209#143,#255) );
function Utf8ToWin(s : string) : string;
var i : integer;
   res  :string;
begin
  res:=s;
  for I := 0 to 65 do
      if pos(Utf2WinTable[i,0],res)>0
         then res := StringReplace(res, Utf2WinTable[i,0], Utf2WinTable[i,1], [rfReplaceAll]);
  Result:=res;
end;

function i2s(i:int):str; begin i2s:=intToStr(i)   end; // укорочение
function i2h(i:int):str; begin i2h:=IntToHex(i,6) end; // укорочение
function s2i(const s:str; d:int=-1):int;  begin s2i:=strToIntDef(s,d) end;  // укорочение
function s2f(const s:str; d:real=0):real; begin s2f:=strToFloatDef(setSep(s),d) end; // укорочение
function f2s(f:real):str; begin f2s:=floatToStr(f) end;      // укорочение
function b2s(b:bool):str; begin if b then b2s:='true' else b2s:='false' end;      // укорочение

function psl(s:str):str; // первое слово до пробела
begin
   s:=trim(s);
   result:=ifs(ps(' ',s), tmt(s,'',' '), s);
end;

function findWin(const w:str):bool; overload; begin result:=FindWindow(nil, pChar(w))>0 end;
function findWin(title:str; var wnd:hwnd; var s:str; t:bool=true):bool; overload; // поиск окна по заголовку или части - t=false
var buff: array [0..4096] of char;
begin
if t then begin wnd:=FindWindow(nil, pChar(title)); result:=wnd>0; exit end;
wnd:=GetWindow(Application.Handle, gw_hwndfirst);
title:=ansiLowerCase(title);
while wnd<>0 do begin
  if (wnd <> Application.Handle) // Собственное окно
     and IsWindowVisible(wnd)    // Невидимые окна
     and (GetWindow(wnd, gw_owner) = 0) // Дочерние окна
     and (GetWindowText(wnd, buff, SizeOf(buff)) <> 0) then begin
         s:=ansiLowerCase(StrPas(buff));
         if ps(title,s) then begin result:=true; exit end;
  end;
  wnd:=GetWindow(wnd, gw_hwndnext);
end;
result:=false;
end;

function findWin(title:str; var s:str):bool; overload;// поиск окна по части и возврат в s полного названия
var wnd:hwnd;
begin
  result:=findWin('server', wnd, s, false);
end;

function listWin():str; overload; // вывод списка окон
var buff: array [0..4096] of char; wnd:hwnd;
begin
result:='';
wnd:=GetWindow(Application.Handle, gw_hwndfirst);
while wnd<>0 do begin
  if (wnd <> Application.Handle) // Собственное окно
     and IsWindowVisible(wnd)    // Невидимые окна
     and  (GetWindowText(wnd, buff, SizeOf(buff)) <> 0) then begin
         result:=result+ansiLowerCase(StrPas(buff))+#13;
  end;
  wnd:=GetWindow(wnd, gw_hwndnext);
end;
write('windows-list.txt',result);
end;

const CMD_SETLABELTEXT = 1; //Задаем ID команды
function send(const s,frame: str):bool; // посылка сообщение окну frame
var
  CDS: TCopyDataStruct;
  h:hwnd;
  t:str;
begin
  if not findWin(frame,h,t) then begin result:=false; exit end else result:=true;
//Устанавливаем тип команды
  CDS.dwData := CMD_SETLABELTEXT;
//Устанавливаем длину передаваемых данных
  CDS.cbData := Length(s) + 1;
//Выделяем память буфера для передачи данных
  GetMem(CDS.lpData, CDS.cbData);
  try
    //Копируем данные в буфер
      StrPCopy(CDS.lpData, AnsiString(s));
    //Отсылаем сообщение в окно с заголовком
//      log('Utils.send послала "'+s+'" в "'+frame+'"');
      SendMessage(h, WM_COPYDATA, 0, Integer(@CDS))
  finally
    //Высвобождаем буфер
      FreeMem(CDS.lpData, CDS.cbData);
  end;
end;

procedure setFocusApl; // установка приложения в фокус https://forum.sources.ru/index.php?showtopic=276831
var
  hWnd, hCurWnd, dwThreadID, dwCurThreadID: THandle;
  OldTimeOut: Cardinal;
  AResult: bool;
begin
  if GetActiveWindow=Application.MainForm.Handle then Exit;
  Application.Restore;
  hWnd := Application.Handle;
  SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @OldTimeOut, 0);
  SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, Pointer(0), 0);
  SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
  hCurWnd := GetForegroundWindow;
  AResult := False;
  while not AResult do begin
     dwThreadID := GetCurrentThreadId;
     dwCurThreadID := GetWindowThreadProcessId(hCurWnd);
     AttachThreadInput(dwThreadID, dwCurThreadID, True);
     AResult := SetForegroundWindow(hWnd);
     AttachThreadInput(dwThreadID, dwCurThreadID, False);
  end;
  SetWindowPos(hWnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
  SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, Pointer(OldTimeOut), 0);
end;

procedure ForceForegroundWindow(hwnd: THandle); // окно на передний план
// https://delphisources.ru/pages/faq/base/form_bring_to_front.html
var hlp: TForm;
begin
   hlp := TForm.Create(nil);
   try
     hlp.BorderStyle := bsNone;
     hlp.SetBounds(0, 0, 1, 1);
     hlp.FormStyle := fsStayOnTop;
     hlp.Show;
     mouse_event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
     mouse_event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
     SetForegroundWindow(hwnd);
   finally
     hlp.Free;
   end;
end;

procedure clickMouse(x,y:int);// нажатие мыши в координатах //https://delphisources.ru/pages/faq/base/sim_mouse_click.html
begin
   SetCursorPos(x,y);
   mouse_event(MOUSEEVENTF_LEFTDOWN, 0,0,0,0);
   mouse_event(MOUSEEVENTF_LEFTUP,   0,0,0,0);
end;

function findImage(const f:str; var xi,yi:int):bool;// поиск картнки из файла на экране и возврат координат её середины
var b,i:tBitmap; e,k:taoi; c:tCanvas; w,h,ws,hs,x,y,xk,yk,u,v:int; line: ^integer; s:bool;
begin
   ws:=screen.width;
   hs:=screen.Height;
   b:=Graphics.tBitMap.create; b.pixelformat:=pf32bit; b.width:=ws; b.height:=hs;
   c:=tCanvas.create;
   c.Handle:=GetDC(0);
   b.canvas.copyRect(rect(0,0,ws,hs),c,rect(0,0,ws,hs));
   bmp2a(b,e);
   c.Destroy;

   i:=Graphics.tBitMap.create; i.pixelformat:=pf32bit;
   i.loadFromFile(f);
   w:=i.Width;
   h:=i.Height;
   bmp2a(i,k);
   s:=false;
   for y:=0 to hs-1 do begin
       line :=@e[y*ws];
       for x:=0 to ws-1 do begin
           if Line^=k[0] then begin
              s:=true;
              u:=y;
              for yk:=0 to h-1 do begin
                  v:=x;
                  for xk:=0 to w-1 do begin
                      if (u>=hs) or (v>=ws) or (k[yk*w+xk]<>e[u*ws+v]) then begin s:=false; break end;
                      inc(v);
                  end;
                  if not s then break;
                  inc(u);
              end;
              if s then begin xi:=x+w div 2; yi:=hs-y-h-1+h div 2; break end
           end;
           inc(line);
       end;
       if s then break;
   end;
   result:=s;
end;

function findM(const s:str; m:taos):bool; // поиск строки s в массиве m
var i: int;
begin
  for i:=0 to high(m) do if m[i]=s then begin result:=true; exit end;
  result:=false;
end;

function glueForm(f:tForm):bool; // прилипание формы к краям экрана
var r,t:tRect;
begin
with f do begin
   r:=BoundsRect;
   if width >sWidth  then begin left:=0; width :=sWidth end;
   if height>sHeight then begin top :=0; height:=sHeight end;
   if width <320 then width :=320;
   if height<320 then height:=320;
   if (left<>0) and (abs(left) <10) then begin width:=width+left-1; left:=0 end;
   if abs(sWidth -(left+width))<10 then left:=sWidth-width;
   if (top<>0) and (abs(top )  <10) then begin height:=height+top-1; top:=0 end;
   if abs(sHeight-(top+height))<10 then height:=sHeight;
   t:=BoundsRect;
   result:=(r.left<>t.left) or (r.top<>t.top) or (r.right<>t.right) or (r.bottom<>t.bottom)
end;
end;
procedure centr(f:tForm); begin f.Left:=(screen.width-f.width) div 2; f.top:=(screen.height-f.height) div 2-100 end;

function b4ToBin32(var Value): string;// 4 байта в строку битов 01
var i: int; c: cardinal absolute value;
begin
  SetLength(Result, 32);
  for i := 1 to 32 do
    if (c shl (i-1)) shr 31=0 then Result[33-i]:='0'
                              else Result[33-i]:='1';
end;

function form2s(f:tForm; name:str='form'): str;  // размеры формы в строку
begin result:=name+'=x='+i2s(f.left)+' y='+i2s(f.top)+' w='+i2s(f.width)+' h='+i2s(f.height) end;

procedure s2form(s:str; var form);  // строка в размеры формы
var a:taos; f: tForm absolute form;
begin
a:=split(s);
if length(a)<>4 then exit;
f.left:=s2i(tmt(a[0],'=')); f.top:=s2i(tmt(a[1],'=')); f.width:=s2i(tmt(a[2],'='));  f.height:=s2i(tmt(a[3],'='));
end;

procedure wav2a(const wav:str; var a:taob); // данные wav в массив
var d:str; l: longword;
begin
  d:=read(wav);
  if length(d)<45 then begin message('Неправильный файл '+wav); setLength(a,0); exit end;
  move(d[41],l,sizeOf(l));
  setLength(a,l);
  move(d[45],a[0],l);
end;

function  THash.getValue(const key: str): str;
var j:int;
begin
  i:=ord(key[1]);
  p:=@k[i];
  for j:=High(p^) downTo 0 do if p^[j]=key then begin result:=v[i][j]; nFind:=j; exit end;
  Result:='';
  nFind:=-1;
end;

function  THash.find(key:str):bool; begin val:=getValue(key); result:=nFind>=0 end;

procedure THash.putValue(const key: str; val:str);
begin
  i:=ord(key[1]);
  if find(key) then begin v[i][nFind]:=val; exit end;
  l:=length(k[i]);
  setLength(v[i],l+1);
  setLength(k[i],l+1);
  k[i][l]:=key;
  v[i][l]:=val;
end;

begin
iniUtils
end.
