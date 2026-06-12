{$R-,S-}
program h2exe;
uses Windows;
 {$SETPEFLAGS IMAGE_FILE_RELOCS_STRIPPED or IMAGE_FILE_LINE_NUMS_STRIPPED or IMAGE_FILE_DEBUG_STRIPPED or IMAGE_FILE_LOCAL_SYMS_STRIPPED}
type TReplaceFlags = set of (rfReplaceAll, rfIgnoreCase);

var
  n,id,exe,h,t: string;
  extract: string;
  extract_: string=
'var f=(new ActiveXObject("Scripting.FileSystemObject")).OpenTextFile("exe",1),c="",w=document;'+
'while (!f.AtEndOfStream) c+=f.Read(1000);'+
'w.open();'+
'w.write(cod(c.substring(c.indexOf("=scr"+"ipt=")+8)));'+
'w.close();'+
'w.oncontextmenu=function(){return false};'+
'function cod(s){for (var c,i=0,k=(s.length/2)|0,j=k,m=s.split(""); i<k; i+=2,j+=2) {c=m[i];m[i]=m[j];m[j]=c;} return m.join("")}';
(*
procedure run(p:string);
//var
//  StartUpInfo: TStartUpInfo;
//  ProcessInfo: TProcessInformation;
begin
//FillChar(StartUpInfo, SizeOf(TStartUpInfo), 0);
//FillChar(ProcessInfo, SizeOf(TProcessInformation), 0);
CreateProcess(PChar(p),'', // pointer to command line string
            nil, // pointer to process security attributes
            nil, // pointer to thread security attributes
            False, // handle inheritance flag
            NORMAL_PRIORITY_CLASS,// creation flags
            nil, // pointer to new environment block
            nil, // pointer to current directory name
            StartupInfo, // pointer to STARTUPINFO
            ProcessInfo) // pointer to PROCESS_INF
end;

function LoCase(ch: char): char;
begin
  if (ch in ['A'..'Z', 'А'..'Я']) then
    result := chr(ord(ch) + 32)
  else
    result := ch;
end;

function LowerCase(s: string): string;
var
  i: integer;
begin
  result := s;
  for i := 1 to length(result) do
    if (result[i] in ['A'..'Z', 'А'..'Я']) then
      result[i] := chr(ord(result[i]) + 32);
end;
*)
(*
function UpCase(ch: char): char; begin if (ch in ['a'..'z', 'а'..'я']) then result:=chr(ord(ch)-32) else result:=ch; end;
function UpperCase(s: string): string;
var
  i: integer;
begin
  result := s;
  for i := 1 to length(result) do
    if (result[i] in ['a'..'z', 'а'..'я']) then result[i]:=chr(ord(result[i])-32);
end;
*)

function cod(s:string):string;
var
  c: char;
  i,j,k:integer;
begin
  i:=0;
  k:=length(s);
  k:=k div 2;
  j:=k;
  while (i<k) do begin
    inc(i);  inc(j);
    c:=s[i];
    s[i]:=s[j];
    s[j]:=c;
    inc(i);  inc(j);
 end;
 result:=s;
end;

function AnsiUpperCase(const S: string): string;
var Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PChar(S), Len);
  if Len>0 then CharUpperBuff(Pointer(Result), Len);
end;

function repl(const S, OldPattern, NewPattern: string; Flags: TReplaceFlags): string;
var
  SearchStr, Patt, NewStr: string;
  Offset: Integer;
begin
  if rfIgnoreCase in Flags then
  begin
    SearchStr := AnsiUpperCase(S);
    Patt := AnsiUpperCase(OldPattern);
  end else
  begin
    SearchStr := S;
    Patt := OldPattern;
  end;
  NewStr := S;
  Result := '';
  while SearchStr <> '' do
  begin
    Offset := pos(Patt, SearchStr);
    if Offset = 0 then
    begin
      Result := Result + NewStr;
      Break;
    end;
    Result := Result + Copy(NewStr, 1, Offset - 1) + NewPattern;
    NewStr := Copy(NewStr, Offset + Length(OldPattern), MaxInt);
    if not (rfReplaceAll in Flags) then
    begin
      Result := Result + NewStr;
      Break;
    end;
    SearchStr := Copy(SearchStr, Offset + Length(Patt), MaxInt);
  end;
end;
function ds:string;
begin
//result:='"аbout:<script>';
result:='';
//randSeed:=1; while length(result)<10 do result:=result+chr(ord('#')+random(90));
while length(result)<1000 do result:=result+' ';
end;
procedure js   (s:string); begin WinExec(PChar('mshta.exe '+ds+'"about:<script>'+s+'</script>"'), SW_HIDE); end;
//procedure alert(s:string); begin js('alert('''+s+'''); parent.parent.close()'); Halt; end;
procedure vb   (s:string); begin WinExec(PChar('mshta.exe "about:<script language=''VBScript''>'+s+'</script>"'), SW_HIDE); end;
procedure alert(s:string); begin vb('MsgBox "'+repl(s,' ','"&Chr(32)&"',[rfReplaceAll])+'", vbCritical, "h2exe"&Chr(32)&"Error" '); Halt; end;

function read(n:string): string;
  var f: file; fs: integer;
  begin
  assignFile(f,n);
  fileMode:=0;
  {$i-} reset(f,1); {$i+}
  if ioresult<>0 then alert('File not found: '''+n+'''');
  fs:=fileSize(f);
  setLength(result,fs);
  blockRead(f,result[1],fs);
  closeFile(f);
end;

procedure write(n:string; s:string);
var f: file;
begin
  fileMode:=2;
  assignFile(f, n);
  rewrite(f,1);
  blockWrite(f,s[1],length(s));
  closeFile(f);
end;

function add(s:string):boolean;
var n:integer;
begin
    n:=length(h);
    h:=repl(h,s,s+'<hta:application/>',[rfIgnoreCase]);
    result:=length(h)>n;
end;

begin
exe:=paramstr(0);
if (pos('\h2exe.exe',exe)<1) { or true} then begin
// запуск
   extract:=';ai d=wndwcAmtnv.Xlbse(t;"ocuiettno.cineeyttemubfentt)o.(e{Felu(nefel)eO;euAcTixnScrdas({)oR avArlc)iv0rki(c.iedgxhf2"|s,r=p,==).8pcic(d"c;sibkt i+g2ij)=w)n{o=.[o]umeit=o[e](m;ji=d;w decumnnm.jrit((")vwrnco(.eo uceitecOojec)'+
   '(dScrmpni.gnFoltSxsmenO=jucc"i)nG)triter" xa"s.}pfnnsteot toe(m)1f.re(dal (,;=a, ==s.lnnetO/()=0cjiktm"s+s;l=to"(). u<s;rin=(,)+;2i dcwmdic;m[n].mpjn;)[w]nco}.roture t.woine"c)}';
// js(repl(cod(extract), 'exe', repl(exe,'\','\\',[rfReplaceAll]),[]));
   js(repl(extract_, 'exe', repl(exe,'\','\\',[rfReplaceAll]),[]));
   exit;
end;

// создание exe
if paramCount<1 then alert('Specify a file of type html, hta to create exe');
id:='script';
n:=paramStr(1);
//fileMode:=2;
//assignFile(f, copy(n,1,pos('.',n))+'exe');
//rewrite(f,1);
//n:=cod('HTA:APPLICATION ID="none" '); //'OT :DP"LoCeT HNAIA=PnInA"I'
//n:=cod('HTA:APPLICATION');            //'LTC:TPOHIAAAIPN'


h:=repl(read(paramStr(1)), cod('LTC:TPOHIAAAIPN'), cod('OT :DP"LoCeT HNAIA=PnInA"I'),[rfIgnoreCase]);

t:=Utf8ToAnsi(h);
if t<>'' then h:=t;

if pos(cod('LTC:TPOHIAAAIPN'),AnsiUpperCase(h))<1 then begin
   if not add('<head>') then
   if not add('<html>') then h:='<hta:application/>'+h;
end;

write(copy(n,1,pos('.',n))+'exe',  read(exe) + '='+id+'=' +  cod(h));
//write(copy(n,1,pos('.',n))+'exe', h);
//blockWrite(f,h[1],length(h));
//closeFile(f);
end.
