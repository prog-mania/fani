unit serverForm;
{$R+}
interface

uses
  Windows, Messages, Classes, Controls, Forms, sysUtils, utils,
  ExtCtrls, IdBaseComponent, IdComponent, IdTCPServer, ActiveX,
  IdCustomHTTPServer, IdHTTPServer, StdCtrls, Dialogs, ComCtrls,
  IdURI, SpeechLib_TLB, mmSystem, PerlRegEx, IdTCPConnection, IdTCPClient,
  IdHTTP, ExtDlgs;

var port: str='8887';
var urlServer: str='http://127.0.0.1';

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    IdHTTPServer1: TIdHTTPServer;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Button1: TButton;
    Label18: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label30: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    lstEngine: TComboBox;
    TrackBar10: TTrackBar;
    TrackBar11: TTrackBar;
    TrackBar30: TTrackBar;
    Button3: TButton;
    wav8: TButton;
    Button4: TButton;
    Button5: TButton;
    txt: TMemo;
    IdHTTP1: TIdHTTP;
    Button2: TButton;
    Button6: TButton;
    Button7: TButton;
    CheckBox1: TCheckBox;
    OpenPicture: TOpenPictureDialog;
    procedure Timer1Timer(Sender: TObject);
    procedure IdHTTPServer1CommandGet(AThread: TIdPeerThread;
              ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lstEngineDropDown(Sender: TObject);
    procedure lstEngineSelect(Sender: TObject);
    procedure TrackBar10Change(Sender: TObject);
    procedure TrackBar11Change(Sender: TObject);
    procedure TrackBar30Change(Sender: TObject);
    procedure wav8Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

  tThreadChrome=class(TThread) request:str; procedure execute; override; end;

var
  Form1: TForm1;
  html:  str; // страница отдаваемая сервером по адресу без параметров
  spVoice: TSpVoice;

implementation

var
files: str='';
exe:   str='';
main:  str=''; // где всё
threadChrome:tThreadChrome;
isCloseQuery: bool=false;
f1:           bool=true; // загружается 1-ый файл основной - добавка script.js
base: str='';
project: str='/editor.html';
index:   str;   // что запускать в редакторе указывается в команде запуска editor.exe
profile: str='';
exeProject: bool; // проект в exe
noExe: bool=true; // не выдавать кнопку createExe
exeName: str='';  // имя формируемого exe
xywh: str='';     // позиции
chrome: str='C:/Program Files/Google/Chrome/Application/chrome.exe'; // путь к chrome
rx:tPerlRegEx;
dirWav:str='';  // директорий для записи файлов с голосом
params: str; // параметры запуска этой программы
screenSaver:bool=true; // запущено windows как screenSaver

{$R *.dfm}
{$R WindowsXP.res}

procedure delete_chrome_url_fetcher;
var SR: TSearchRec; p,m:str;
begin
p:='c:\Program Files\';
m:='chrome_url_fetcher*.*';
if FindFirst(p+m, faAnyFile, sr)=0 then begin
     repeat
        if (sr.Attr and faDirectory)>0 then
           RemoveDir(p+sr.name);
     until FindNext(sr)<>0;
     FindClose(sr);
end;
end;

procedure kill(p:str); begin WinExec(PANsiChar('TASKKILL /F /IM '+p), SW_HIDE) end;

procedure tThreadChrome.execute;
var x,y,w,h,c,chromeReg:str; a:tAos; state:word;
begin
chromeReg:=tmt(reg(HKEY_CLASSES_ROOT,'ChromeHTML\shell\open\command'),'"','"');
if chromeReg='' then chrome:='C:/Program Files/Google/Chrome/Application/chrome.exe'
                else chrome:=chromeReg;
if not fileExists(chrome) then begin showMessage('Установите Chrome'); halt; end;

x:='0'; y:='0'; w:=i2s(screen.width div 3); h:=i2s(screen.height);
if exeProject and (xywh<>'') then begin
   a:=split(fromScreen(xywh),' ');
   if length(a)=4 then begin x:=a[0]; y:=a[1]; w:=a[2]; h:=a[3] end;
   x:='0';
end;
if screenSaver then begin x:='0'; y:='0'; w:=i2s(screen.width); h:=i2s(screen.height) end;
if screenSaver then begin x:='0'; y:='0'; w:=i2s(screen.width); h:=i2s(screen.height) end;
c:='--window-size='+w+','+h+' --window-position='+x+','+y+
' --disable-http-cache'+
' --disable-web-security --user-data-dir'+
' --profile-directory="'+profile+'"'+
' --app='+urlServer+project;
//if screenSaver then begin end;
//state:={SHOW_FULLSCREEN}SW_SHOWMAXIMIZED else
state:=SW_NORMAL;
form1.memo1.Lines.Add('run '+chrome+#13+c);
application.ProcessMessages;

ExeAndWait(chrome, c, state);

if isCloseQuery then exit;
form1.IdHTTPServer1.Active:=false;
delete_chrome_url_fetcher;
kill(efn(application.exeName));
end;

function delParams(s:str):str;
begin
if ps('?',s) then result:=copy(s,1,pos('?',s)-1) else result:=s;
end;

procedure TForm1.Button1Click(Sender: TObject);
var p,p1,p2: int; s,fileName, dir:str; f1:bool;
begin
//exe:=read('c:\delphi\html2exe\model.exe');
p:=1; left:=0; memo1.Lines.Clear; memo1.Lines.Add('Extracted files:'); f1:=true;

while true do begin
   p1:=posEx('<!--fileName=',exe,p);
   if f1 then begin
      f1:=false; write(repl(efn(application.ExeName),'.exe','_clean.exe'),copy(exe,1,p1-1));
   end;
   if p1=0 then break;
   inc(p1,13);
   p2:=posEx('-->',exe,p1);
   if p2<1 then break;
   s:=repl(copy(exe,p1,p2-p1),'/','\');
   fileName:=extractFileName(s);
   dir     :=extractFileDir(s);
   dir:=repl(cd,'/','\')+copyK(dir,3);
   if ForceDirectories(dir) then begin
      p1:=p2+4;
      p2:=posEx('<!--fileName=',exe,p1);
      if p2<1 then p2:=length(exe)+2;
      s:=copy(exe,p1,p2-p1-1);
      fileName:=dir+'\'+fileName;
      write(fileName,s);
      memo1.Lines.Add(fileName);
    end;
    p:=p2;
end;
end;


// voice --------------- https://habr.com/ru/articles/981992/

var freq:int=22050; // частота звука
var
   SpMemoryStream: TSpMemoryStream;
   nameVoice: str=''; nv:int; // название выбранного голоса и его номер
   formS: str=''; // размеры формы
   waveHeader:record
     idRiff:  array [0..3] of chr; // 4
     RiffLen: longint;             // 8
     idWave:  array [0..3] of chr; // 12
     idFmt:   array [0..3] of chr; // 16
     InfoLen: longint;             // 20
     WaveType: smallint;           // 22
     Ch: smallint;                 // 24
     Freq: longint;                // 28
     BytesPerSec: longint;         // 32
     align: smallint;              // 34
     Bits: smallint;               // 36
     idData: array [0..3] of chr;  // 40
     DataLen: longint;             // 44
  end;
  ini:bool=false;
  stop:bool=false; // остановить запись в файл
  hide:bool=false; // в скрытом виде
  readI: bool=false;
  mStream: tMemoryStream;
  strReadIni: str=''; // прочитано из ini
  textSay_text:str='';
  voices: ISpeechObjectTokens;
  voicesBest: taos; // лучшие голоса: "имя",скорость,высота
  b: taob;
  fileList:taos; // список файлов wav

// параметры голоса:
  vol : int=50; // громкость 0..100
  rate: int=0;  // скорость -5..+5
  pitch:int=0;  // высота -10..+10
  rand: bool=false; // случайное отклонение для разнообразия

procedure iniS; // создание голосов
begin
  if ini then exit;
  ini:=true;
  spVoice:=TSpVoice.Create(nil);
end;

procedure getPar(const par,s: str; var r:int);
var v:str;
begin v:=tmt(s,' '+par+'=',' '); if v<>'' then r:=s2i(v) end;

procedure var2trackBar;
begin
with form1 do begin
  trackBar10.Position:=vol;
  trackBar11.Position:=rate;
  trackBar30.Position:=pitch;
  txt.text:=textSay_text;
end;
end;
procedure readIni; // чтение настроек
var
s: str; a:taos; i:int;
begin
chDir(cd);
setLength(voicesBest,0);
a:=split(prs(strReadIni,read('voice.ini')),#13#10);

for i:=0 to length(a)-1 do begin
  s:=a[i];
  if s<>'' then
  if s[1]='"' then push(voicesBest,s) else
  if posEx('name voice=',s)=1 then begin
     nameVoice:=tmt(s,'=');
     form1.lstEngine.text:=nameVoice;
  end else
  if posEx('text=' ,s)=1 then textSay_text:=repl(copyK(s,6),'<br>',#13#10) else
  if posEx('form=' ,s)=1 then formS:=val(s) else
  if posEx('Параметры голоса ',s)=1 then begin
     getPar('vol',  s,vol);
     getPar('rate', s,rate);
     getPar('pitch',s,pitch);
  end
end;
var2trackBar;
end;

procedure trackBar2par;
begin
  vol:=  form1.trackBar10.Position;
  rate :=form1.trackBar11.position;
  pitch:=form1.trackBar30.Position;
end;

procedure saveIni; //сохранение настроек
var s:str;
begin
//if strReadIni='' then exit;
trackBar2par;
s:='Программа для произнесения текста голосом.'#13#10;
s:=s+'name voice=' +nameVoice+#13#10;
s:=s+'Параметры голоса vol='+i2s(vol)+' '+'rate='+i2s(rate)+' '+'pitch='+i2s(pitch)+' ';
s:=s+#13#10+'text='+repl(form1.txt.text,#13#10,'<br>')+#13#10+form2s(form1);
s:=s+#13#10+join(voicesBest,#13#10);

if s<>strReadIni then write('voice.ini',s);
end;

function findVoice(n:str):str; // найти полное имя голоса по короткому из команды
var i,q:int;
begin
result:='';
q:=length(voicesBest);
n:=lowerCase(n);
if (n='rand') and (q>0) then begin result:=voicesBest[random(q)]; exit end;
for i:=0 to q-1 do if ps(n,lowerCase(voicesBest[i])) then begin result:=voicesBest[i]; exit end;
with form1.lstEngine do begin
  for i:=0 to items.count-1 do if ps(n,items[i]) then begin result:=items[i]; exit end;
  result:=items[0];
  nv:=0;
end;
end;

procedure getVoices; // получение номера установленного голоса nv по названию nameVoice
var i,q:int; s,n:str; empty:bool; a: taos;
begin
with form1.lstEngine do begin
  nv:=-1;
  empty:=items.Count=0;
  if (length(nameVoice)>0) and (nameVoice[1]='"') then begin
     a:=split(nameVoice,',');
     n:=tmt(a[0],'"','"'); rate:=s2i(a[1]); pitch:=s2i(a[2]); var2trackBar;
  end
  else n:=nameVoice;
  if empty then for i:=0 to high(voicesBest) do items.add(voicesBest[i]);
  if voices=nil then voices :=spVoice.GetVoices('','');
  for i:=0 to Voices.Count-1 do begin
      s:=voices.item(i).GetDescription(0);
      if empty then if not ps('(',s) or ps('Russian',s) then items.add(s);
      if s=n then nv:=i;
  end;

  if (nv<0) and (Voices.Count>0) then begin nv:=0; nameVoice:=items[0] end;
  text:=nameVoice;
end;
end;

function addPitch(txt:str):str;
var p:int;
begin
  p:=og(pitch + ifi(rand, random(3)-1), -5,+5);
  result:=ifs(p<>0,'<PITCH MIDDLE="'+i2s(p)+'">')+txt
end;

function setVoice(var v: TSpVoice; lenText:int=-1):bool;
begin
  if nv<0 then begin message('Установите голос'); result:=false end
  else begin
       v.voice:=voices.item(nv);
       v.volume:=og(vol,0,100);
//      v.volume:=100;//og(vol  * (100+ifi(rand, random(30)-10)) div 100, 0,100);
// чем длинее текст, тем быстрее и тише
{       if lenText>150 then begin iRate:=2; v.volume:=60 end else
       if lenText> 70 then begin iRate:=1; v.volume:=80 end else
                           begin iRate:=ifi(rand, random(3)-1); v.volume:=100; end;}
       v.rate  :=og(rate{ + iRate}, -5,+5);
       result  :=true;
  end;
end;

function s2b(txt:str=''):taob;   // речь в байты звука
var i: int;
begin
  CoInitialize(nil);
  SetLength(result,0); 
  for i:=1 to 4 do begin
// иногда возникает ошибка  EVariantBadIndexError  Variant or safe array index out of bounds
  try
  if SpMemoryStream=nil then begin
     SpMemoryStream := TSpMemoryStream.Create(nil);
//   SpMemoryStream.Format.type_:=SAFT11kHz8BitMono;
     SpMemoryStream.Format.type_:=SAFT22kHz16BitMono;
  end
  else SpMemoryStream.CleanupInstance;
  spVoice.AudioOutputStream:=SPMemoryStream.DefaultInterface;
  if txt='' then txt:='Не знаю что сказать';
  if not setVoice(spVoice, length(txt)) then exit;
  spVoice.Speak(addPitch(trim(txt)), SVSFDefault);
  SpMemoryStream.seek(0,0);
  result:=SpMemoryStream.GetData;
  if length(result)>0 then exit;
  except on E: Exception do form1.memo1.lines.add('exception: '+E.Message); end;
    sleep(200);
  end;
end;

procedure setWaveHeader(f,len:int);
begin
with WaveHeader do begin
    idRiff := 'RIFF';
    RiffLen := len + 38;
    idWave := 'WAVE';
    idFmt := 'fmt ';
    InfoLen := 16;
    WaveType := 1;
    Ch := 1;
    freq := f;
    bytesPerSec := freq * 16 div 8 * 1;
    align := 1 * 16 div 8;
    Bits := 16;
    idData := 'data';
    DataLen := len;
end;
end;

procedure b2stream; // из массива байт в wav в mStream
var len: integer;
begin
len := length(b) div 2 * 16 div 8 * 1;  //len:=SampleCount * BitsPerSample div 8 * Channeles;
setWaveHeader(freq,len);
mStream.Clear;
mStream.Write(WaveHeader, sizeof(WaveHeader));
mStream.Write(b[0],length(b));
end;

procedure playA(f:str=''); // проигрывание массива b или файла f
begin
if f<>'' then wav2a(dcd(f),b);
if length(b)=0 then exit;
b2stream;
playSound(mStream.Memory, 0, SND_MEMORY or SND_ASYNC);//}SND_ASYNC);
end;

procedure MemoryStreamToByteArray(AMemoryStream: TMemoryStream; out AByteArray: taob);
begin
  // Set the stream position to the beginning to ensure all data is read.
  AMemoryStream.Position := 0;
  // Set the length of the byte array to match the size of the memory stream.
  SetLength(AByteArray, AMemoryStream.Size);
  // Read the entire content of the memory stream into the byte array.
  // The Read method automatically advances the stream's position.
  if AMemoryStream.Size > 0 then
    AMemoryStream.Read(AByteArray[0], AMemoryStream.Size);
end;

function txt2base64(txt:str):str;   // выдаёт звук текста в формате JS wav=base64 wav
var s:str;i:int;
begin
  b:=s2b(txt);
  s:='';
  if length(b)>0 then begin
     b2stream;
     MemoryStreamToByteArray(mStream,b);
     for i:=0 to high(b) do s:=s+chr(b[i]);
  end;
  result:='fani({wav:"'+EncodeBase64(s)+'"});';
end;

procedure say(txt:str=''); // сказать txt
begin
  b:=s2b(txt);
  playA;
end;



function delC(s:str):str; // удаление числа в конце
var p: int;
begin
  for p:=1 to length(s) do
      if (s[p]>='0') and (s[p]<='9') or (s[p]='-') then begin
         result:=trim(copy(s,1,p-1)); exit
      end;
  result:=s;
end;

procedure li(l:tLabel;v:int); begin l.caption:=delC(l.caption)+' '+i2s(v) end;
procedure ur(t:tTrackBar);    begin SetWindowRgn(t.Handle,CreateRectRgn(1,1,t.Width-1,t.Height-1),true) end;

procedure voiceChange;
begin
with form1 do begin
  nameVoice:=lstEngine.Text;
  getVoices;
end;
end;

function clearTxt(s:str):str; begin result:=trim(rx.repl(rx.delCom(s),'[\r\n]',' ')) end;
(*
procedure wavFile_(txt:str; q8: boolean; n:int);
//http://www.webdelphi.ru/2010/05/sapi-5-4-dlya-windows-7-realizaciya-texnologii-text-to-speech-v-delphi-2010/
var SpFileStream: TSpFileStream; f:str;
begin
    f:=dirWav+'\speech '+i2s(n)+'.wav';
    SpFileStream := TSpFilestream.Create(nil);

  try
    if q8 then SpFileStream.Format.type_ := SAFT11kHz8BitMono;
    SpFileStream.Open(f, SSFMCreateForWrite, FALSE);
    if not setVoice(spVoice) then exit;
    spVoice.Volume:=100;
    spVoice.AudioOutputStream := SPFileStream.DefaultInterface;
    spVoice.SynchronousSpeakTimeout := 1000;
    spVoice.Speak(addPitch(txt), SVSFDefault); //SVSFlagsAsync);
    spVoice.WaitUntilDone(30007);
//    message('Голос записан в '+f);
  finally
    SpFileStream.Close;
    SpFileStream.Free;
  end;
end;
*)
function wavFile(txt:str; q8: boolean; var n:int):str;
var f:str;
begin
if form1.CheckBox1.Checked then begin nameVoice:=findVoice('rand'); getVoices end;
b:=s2b(txt);
if length(b)>0 then begin
   b2stream;

   while true do begin
      f:=dirWav+'\speech '+i2s(n)+'.wav';
      if not fileExists(f) then break;
      inc(n);
   end;

   mStream.SaveToFile(f);
   result:=f;
end;
end;

procedure TForm1.TrackBar10Change (Sender: TObject); begin vol  :=trackBar10.Position; li(label10,vol)   end;
procedure TForm1.TrackBar11Change (Sender: TObject); begin rate :=TrackBar11.position; li(label11,rate)  end;
procedure TForm1.TrackBar30Change (Sender: TObject); begin pitch:=trackBar30.Position; li(label30,pitch) end;

procedure TForm1.Button4Click(Sender: TObject);
begin
//openDialog1.InitialDir:=extractFileDir(edit1.Text);
if not openDialog1.Execute then exit;
txt.text:=read(openDialog1.FileName);
end;

procedure beginVoice;
begin
if ini then exit;
ini:=true;
mStream:=tMemoryStream.Create;
spVoice:=TSpVoice.Create(nil);
readIni;
getVoices;
if Voices.Count>0 then s2b('Начинаю говорить'); // в начале бывает задержка
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
   timer1.Enabled:=false;
   beginVoice;
   IdHTTPServer1.defaultPort:=s2i(port);
   urlServer:=urlServer+':'+port+'/';
   form1.Caption:='server '+urlServer;
   IdHTTPServer1.Active:=True;
   if project='' then exit;
   threadChrome:=tThreadChrome.Create(true);
   threadChrome.FreeOnTerminate:=true;
   threadChrome.resume;
   txt.setFocus;
   perf;
end;

procedure TForm1.FormCreate(Sender: TObject);
var i,p1,p2:int; p,f,v:str;

function e(k:str; var r:str):bool;
begin
  result:=false;
  p1:=posEx('<!--'+k+'=',exe);
  if p1<1 then exit;
  p2:=posEx('-->',exe,p1);
  if p2<1 then exit;
  inc(p1,length(k)+5);
  r:=copy(exe,p1,p2-p1);
  result:=true;
end;

begin
rx:=tPerlRegEx.Create(nil); rx .Options:=[preSingleLine];
ur(trackBar11);   ur(trackBar10);  ur(trackBar11); ur(trackBar30);
KeyPreview:=True; // для обработки кливишей keyDown фармы
project:=''; base:='';  index:=''; f:=''; perf; params:=paramStr(0);

for i:=1 to paramCount do begin
    p:=ansiLowerCase(paramStr(i));
    params:=params+' '+p;
    v:=tmt(p,'=');
    if pos('project=',p)=1 then project:=v else
    if pos('main=',   p)=1 then cd     :=v else
    if pos('index=',  p)=1 then index  :=v else
    if pos('base=',   p)=1 then base   :=v else
    if pos('port=',   p)=1 then port   :=v else
    if pos('profile=',p)=1 then profile:=v else
    if pos('debug',p)=1    then begin readIni; beginVoice; timer1.Enabled:=false; exit end;// для отладки
    if pos('exe',  p)=1    then begin noExe:=false; if length(p)>4 then exeName:=v end else
    if ps('.htm',p)        then f:=p else
    if ps('/p',p)          then application.Terminate else// screenSaver - показать вид?
    if ps('/s',p)          then screenSaver:=true else
    if pos('dirwav=',p)=1 then dirWav:=v;
end;
chdir(cd);
html:=AnsiToUTF8(read('fani_server.html'));
exe:=read(application.ExeName);
exeProject:=e('project',p);
e('xywh',xywh);
if exeProject then begin
   left:=sWidth;
   exe:=zip2str(copy(exe,p2+3,maxInt));
   if project='' then project:=p;
end
else
if project='' then project:=f;

button1.Visible:=exeProject;
project:=repl(project, '\','/');
if base=''  then base:=repl(extractFileDir(repl(project,'/','\')),'\','/')+'/';
if profile=''  then profile:=tmt(efn(project),'','.');
if exeProject and (f<>'') and (f[1]='?') then
   project:=project+f;
//beginVoice;   
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
isCloseQuery:=true;
kill('chrome.exe');
saveIni;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
if key=VK_F2     then application.Terminate;
if key=VK_F9     then Button3Click(nil);
if key=VK_ESCAPE then begin PlaySound(nil, 0, SND_ASYNC); stop:=true; end;
end;

procedure TForm1.lstEngineDropDown(Sender: TObject); begin iniS; end;
procedure TForm1.lstEngineSelect(Sender: TObject);   begin voiceChange; end;

procedure TForm1.wav8Click(Sender: TObject);
var t,s:str; a:taos; i,n,q,qf:int;
begin
s:=trim(txt.text);
if s='' then
if openDialog1.Execute then s:=openDialog1.FileName else exit;
if rx.find(s,'^(.+\.txt)$') then t:=read(rx.se[1]) else t:=s;
t:=rx.repl(t,'([-\r\n«»#*"]+)', ' '); // удаление непроизносимого
if dirWav='' then dirWav:=repl(cd,'/','\')+'\speech';
ForceDirectories(dirWav);

// разделение на части
if ps('Вопрос 1: ',t) then begin //   t:=rx.repl(t,'Ответ \d+:|Выводы \d+:');
   a:=rx.split(t,'Вопрос \d+:|Ответ \d+:|Выводы \d+:');
end
else begin // разбивка по предложениям
   t:=rx.repl(t,'([А-ЯЁ])','#\1');
   a:=split(t,'#');
end;

i:=0; n:=1; q:=high(a); qf:=0; stop:=false;  setLength(fileList,q);

while (i<=q) and not stop do begin
  t:=trim(a[i]);
  if length(t)<4 then begin inc(i); continue end;
  while (length(t)<20) and (i<high(a)) do begin  inc(i); t:=t+a[i] end;
  inc(i);
  t:=clearTxt(t);
  txt.text:='Запись: '+i2s(n)+'/'+i2s(q)+'. '+t;
  application.ProcessMessages;
  fileList[qf]:='file '''+wavFile(t,true,n)+'''';
  inc(qf);
  inc(n);
  //if qf>100 then break;
end;
form1.txt.text:=s;

// для ffmpeg -f concat -safe 0 -i filelist.txt -af "loudnorm=I=-16:TP=-1.5:LRA=11" -b:a 32k output.mp3
setLength(fileList,qf);
write('fileList.txt', join(fileList,#13));
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
trackBar2par;
say(txt.text);
end;

procedure TForm1.Button5Click(Sender: TObject); // в exe
var h:hwnd; n:str; r:tRect; a:taos; i:int; s:str;
begin
if project='' then begin
   showMessage('Надо было указать html, например:'#13+application.ExeName+' index.html exe=fani');
   exit;
end;
if ps('.',exeName) then exeName:=tmt(exeName,'','.');
findWin(exeName,h,n,false);
if h>0 then begin
  GetWindowRect(h, r);
  xywh:=i2s(r.left)+' '+i2s(r.top)+' '+i2s(r.right-r.Left+1)+' '+i2s(r.bottom-r.Top+1);
end
else xywh:='';

a:=split(files,#13);
s:='';
for i:=0 to high(a) do
    if (a[i]<>'') then s:=s+#13'<!--fileName='+a[i]+'-->'#13+read(a[i]);

project:=rx.repl(project,'[?&]clear=1');

if exeName='' then exeName:=profile+'.exe' else exeName:=changeFileExt(exeName,'.exe');
write(exeName, read(application.ExeName)+
  repl('<project='+project+'--><xywh='+toScreen(xywh)+'-->', '<','<!--')+str2zip(s));
showMessage('Создан файл '+exeName);
end;

procedure killWin(win:str);
var t:str; i:int;
begin
  if findWin(win, t) then begin
     WinExec(PANsiChar('TASKKILL /F /IM '+efn(t)), SW_HIDE);
     for i:=1 to 10 do begin
           sleep(200);
           if not findWin(t) then exit;
     end;
  end;
end;

// server ---------------
function MemoryStreamToString(MS: TMemoryStream): string;
var
  Len: Integer;
begin
  MS.Position := 0; // Important: reset stream position

  // Calculate length in characters (assuming 'string' is UnicodeString in modern Delphi)
  Len := MS.Size div SizeOf(Char);

  SetLength(Result, Len);
  if Len > 0 then
    // Read directly into the string's internal buffer
    MS.ReadBuffer(Result[1], MS.Size);
end;

procedure ClickInWindow(hWindow: HWND);
var rect:trect; x,y:int;
begin
  if not GetWindowRect(hWindow, rect) then exit;
  // Координаты:
    x:=(rect.Left+rect.right) div 2; y:=(rect.top+rect.Bottom) div 2;
    form1.memo1.Lines.Add('Mouse click x='+ i2s(x) +' y='+i2s(y));
//  https://www.cyberforum.ru/delphi-beginners/thread116037.html
    x := round(x * (65535 / Screen.Width));
    y := round(y * (65535 / Screen.Height));
  //Перемещаем указатель мыши на целевую точку.
    mouse_event(MOUSEEVENTF_MOVE or MOUSEEVENTF_ABSOLUTE, X, Y, 0, 0);
  //Эмуляция нажатия левой кнопки мыши.
    mouse_event(MOUSEEVENTF_LEFTDOWN or MOUSEEVENTF_ABSOLUTE, X, Y, 0, 0);
    sleep(100);
    mouse_event(MOUSEEVENTF_LEFTUP or MOUSEEVENTF_ABSOLUTE, X, Y, 0, 0);
end;

procedure press(t:str;k:int=-1);
var p:str; h:hwnd; i:int;
begin
  for i:=1 to 10 do begin findWin(t,h,p,false); if h>0 then break; sleep(200); end;
  if h<=0 then begin form1.memo1.Lines.Add('Not found window with title "'+t+'" Read windows-list.txt'); listWin; exit; end
          else begin SetForegroundWindow(h); sleep(100) end;
  form1.memo1.Lines.Add('Found window with title "'+t+'"');
  if k<0 then ClickInWindow(h)//GetForegroundWindow)
  else begin
      PostMessage(GetForegroundWindow, WM_KEYDOWN, k, 0);
      sleep(100);
      PostMessage(GetForegroundWindow, WM_KEYUP,   k, 0);
      form1.memo1.Lines.Add('Key '+i2s(k)+' press');
  end;
end;


var IdHTTP2: tIdHTTP;

function post(url:str; data:str; ContentType:str):str;
var AStringStream:TStringStream;
begin
  if IdHTTP2=nil then begin
     IdHTTP2:=TIdHTTP.Create(nil);
     IdHTTP2.Request.ContentType:=ContentType;
  end;

  try
      AStringStream:=TStringStream.Create('');
      IdHTTP2.Post(url, TStringStream.Create(Utf8Encode(data)),AStringStream);
  except on e:exception do begin
      form1.memo1.Lines.Add('Ошибка соединения с'#13+url+#13+e.Message);
      result:='';
      exit;
  end;
  end;
  result:=AStringStream.DataString;
  form1.memo1.Lines.Add('post => '+i2s(length(result))+' bytes');
end;

procedure TForm1.IdHTTPServer1CommandGet(AThread: TIdPeerThread; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var f,c,readFile,mark,s,p,t,v,url,rs:str; p1,p2,i,l,k:int;  selectFile:bool;  h:hwnd;
function par(n:str):bool;
var i:int;
begin // есть параметр с именем n ?n=...
   result:=false;
   for i:=0 to ARequestInfo.Params.count-1 do
       if ARequestInfo.Params.Names[i]=n then begin result:=true; break end;
   if result then p:=ARequestInfo.Params.Values[n] else p:=''
end;
function getMark:str; begin result:='<!--fileName='+f+'-->'#13 end;

function  short(s:str; d:int=80):string; begin if length(s)>d then result:=copy(s,1,d) else result:=s end;
procedure showServer; begin h:=getForegroundWindow; l:=left; left:=sWidth; ForceForegroundWindow(Handle) end;
procedure hideServer; begin left:=l; ForceForegroundWindow(h); chdir(cd) end;

begin
c:=ARequestInfo.RawHTTPCommand;
f:=ARequestInfo.Document;
//memo1.Lines.Add(ups(utf8ToWin(TIdURI.URLDecode(short(c,120))))+' => '+f);
memo1.Lines.Add(repl(short(utf8ToWin(TIdURI.URLDecode(c))),#$E2#$80#$94' '));
AResponseInfo.ResponseNo:=200;
AResponseInfo.CustomHeaders.SetText('Access-Control-Allow-Origin: *');
AResponseInfo.ContentType:='text/javascript';
AResponseInfo.ContentText:='"OK"';
if length(memo1.text)>6000 then while length(memo1.text)>4000 do memo1.lines.delete(0);

if par('server') then begin
   if p='hide'    then left:=screen.Width else
   if p='visible' then left:=0;
   memo1.Lines.Add(params);
   AResponseInfo.ContentText:=params;
   exit;
end;

if par('kill') then begin
   if p='' then kill('chrome.exe') else killWin(p);
   exit;
end;

if par('key') then begin // нажать клавишу в окне например чтобы был звук
  k:=s2i(p);
  if not par('title') then exit;
  press(p,k);
  exit;
end;
if par('mouse') then begin // нажать мышь в окне например чтобы был звук
  if not par('title') then exit;
  press(p);
  exit;
end;


if par('t')  then begin  // вернуть wav в base64 произнесения t
  s:=p;
  if par('voice') then begin nameVoice:=findVoice(p); getVoices; end;
  if par('rate' ) then rate:=s2i(p);
  if par('pitch') then pitch:=s2i(p);
  AResponseInfo.ContentText:=txt2base64(Utf8ToWin(s));
  exit;
end;
if par('say')  then begin  // сказать
  say(Utf8ToWin(p));
  exit;
end;


if par('info') then begin memo1.lines.add(TIdURI.URLDecode(c)); exit end;

readFile:=''; selectFile:=false;
if par('read') then begin
   if mSec<2000 then exit;// против повторного запуска
   readFile:=trim(p);
   if readFile='' then begin
     if par('ini')  then begin
        s:=dcd(p);
        openPicture.filename := s+'*.*';
        OpenPicture.initialDir:=s;   OpenDialog1.initialDir:=s
     end;

     if par('mask') then begin
     s:='('+p+')|'+p+'|Все файлы (*.*)|*.*'; OpenPicture.Filter:=s; OpenDialog1.Filter:=s
     end;
     showServer;
     //OpenPicture.initialDir:=dcd('poses');//'d:\delphi\Fani\poses\';
     if rx.find(p,'\.jpg|\.webp|\.png') then
     if OpenPicture.Execute then begin selectFile:=true; readFile:=OpenPicture.fileName end else
     if OpenDialog1.Execute then begin selectFile:=true; readFile:=OpenDialog1.fileName end;
     hideServer;
   end;
   perf;
   if readFile='' then begin AResponseInfo.ContentText:='undefined'; exit end;
   f:=readFile;
end;

if par('write') and (ARequestInfo.Command='POST') then begin
   f:=p;
   if f='' then begin
      showServer;
      if saveDialog1.execute then f:=saveDialog1.FileName;
      hideServer;
   end;
   if f<>'' then begin write(f, ARequestInfo.FormParams); AResponseInfo.ContentText:=getMark end
            else AResponseInfo.ContentText:='undefined';
   memo1.Lines.Add('write '+i2s(length(ARequestInfo.FormParams))+' bytes in '+f);
   AResponseInfo.ContentType:='text/plain';
   exit;
end;

if par('post') and (ARequestInfo.Command='POST') then begin
   url:=p;
   if not par('contenttype') then p:='application/json';
   AResponseInfo.ContentText:=post(url,ARequestInfo.FormParams,p);
   AResponseInfo.ContentType:='text/plain';
   exit;
end;
{
if par('exe') then begin
   AResponseInfo.ContentText:='Exe create: '+createExe(p);
   AResponseInfo.ContentType:='text/plain';
   exit;
end;
}
if par('run') then begin
   chDir(cd);
   CoInitialize(nil);
   c:=TIdURI.URLDecode(p);
   if rx.find(c,'(HKEY_CLASSES_ROOT.)(.+?)[" ]') then begin  // путь из реестра
      s:=rx.se[1]+rx.se[2];
      rs:=reg(HKEY_CLASSES_ROOT, rx.se[2]);
      rs:=tmt(rs,'"','"');
      c:=repl(c,s,rs);
   end;

   if ExeAndWait(c,'',SW_NORMAL,ifb(par('wait'),true))
      then AResponseInfo.ContentText:='Run OK'
      else AResponseInfo.ContentText:='Run Fail';
   memo1.Lines.Add(AResponseInfo.ContentText);
   exit;
end;

AResponseInfo.ContentType:=IdHTTPServer1.MIMETable.GetFileMIMEType(f);

if readFile<>'' then begin
   s:=read(Utf8ToWin(readFile));
   if par('base64') then s:=EncodeBase64(s);
   AResponseInfo.ContentText:=ifs(selectFile,'<!--fileName='+AnsiToUTF8(readFile)+'-->'#13)+s;
   memo1.Lines.Add('read '+i2s(length(s))+' bytes');
end
else
if f<>'' then begin
   s:='';
   if f[1]='/' then f:=u1(f);
   if (f<>project) and not ps(base,f) and (base<>'/') then f:=base+f;
   mark:=getMark;
   p1:=posEx(mark,exe);
   if p1>0 then begin // файл из  exe
      inc(p1,length(mark));
      p2:=posEx('<!--fileName=',exe,p1);
      if p2<1 then p2:=length(exe)+2;
      s:=copy(exe,p1,p2-p1-1);
   end
   else begin
     {if pos('http',f)=1 then  begin
        f:=rx.repl(f,'^(https?)/','\1://');
        try
        IdHttp1.Get (f, mStream); //https://www.google.com/search?q=delphi+memorystream+to+string
        s:=MemoryStreamToString(mStream);
        s:=rx.repl(s,'(https?)://','\1/');
        except on E: Exception do begin form1.memo1.lines.add('exception: '+E.Message); s:=''; end end;
     end else }
     s:=read(f);
     if par('base64') then s:=EncodeBase64(s);
   end;

   AResponseInfo.ContentText:=s;
   f1:=false;
   f:=#13+f+#13;
   if not ps(f,files) then files:=files+f // для сборки в exe
end;
end;

procedure TForm1.Button2Click(Sender: TObject); begin memo1.Text:='' end;
procedure TForm1.Button6Click(Sender: TObject); // запоминание голоса и его параметров
var s:str;
begin
  s:='"'+nameVoice+'",'+i2s(rate)+','+i2s(pitch);
  push(voicesBest,s);
  lstEngine.Items.Insert(0,s);
  lstEngine.text:=s;
end;

procedure TForm1.Button7Click(Sender: TObject);
var i,j:int;
begin  // удаление голоса из массива и списка
j:=0;
for i:=0 to high(voicesBest) do
    if voicesBest[i]<>nameVoice then begin voicesBest[j]:=voicesBest[i]; inc(j) end
    else lstEngine.Items.delete(i);
setLength(voicesBest,j);
end;

end.
