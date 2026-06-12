(**********************************************************
*                                                         *
*     Perl Regular Expressions                            *
*                                                         *
*     Delphi wrapper around PCRE  -  http://www.pcre.org  *
*                                                         *
*     Copyright (C) 1999-2006 Jan Goyvaerts               *
*                                                         *
*     Design & implementation Jan Goyvaerts 1999-2006     *
*                                                         *
**********************************************************)

unit PerlRegEx;

interface

{$DEFINE NO_PCRE_DLL}

uses
  Windows, Messages, SysUtils, Classes,utils;

type
  TPerlRegExOptions = set of (
    preCaseLess,       // /i -> Case insensitive
    preMultiLine,      // /m -> ^ and $ also match before/after a newline, not just at the beginning and the end of the string
    preSingleLine,     // /s -> Dot matches any character, including \n (newline). Otherwise, it matches anything except \n
    preExtended,       // /x -> Allow regex to contain extra whitespace, newlines and Perl-style comments, all of which will be filtered out
    preAnchored,       // /A -> Successful match can only occur at the start of the subject or right after the previous match
    preDollarEndOnly,  // /E
    preExtra,          // /X
    preUnGreedy        // Repeat operators (+, *, ?) are not greedy by default
  );                   //   (i.e. they try to match the minimum number of characters instead of the maximum)

type
  TPerlRegExState = set of (
    preNotBOL,         // Not Beginning Of Line: ^ does not match at the start of Subject
    preNotEOL,         // Not End Of Line: $ does not match at the end of Subject
    preNotEmpty        // Empty matches not allowed
  );

const
  // Maximum number of subexpressions (backreferences)
  // Subexpressions are created by placing round brackets in the regex, and are referenced by \1, \2, ...
  // In Perl, they are available as $1, $2, ... after the regex matched; with TPerlRegEx, use the Subexpressions property
  // You can also insert \1, \2, ... in the Replacement string; \0 is the complete matched expression
  MAX_SUBEXPRESSIONS = 99;

type
  str=ansiString;
  chr =ansiChar;

  TPerlRegExReplaceEvent = procedure(Sender: TObject; var ReplaceWith: str) of object;

type
  TPerlRegEx = class(TComponent)
  private    // *** Property storage, getters and setters
    FCompiled, FStudied: Boolean;
    FOptions: TPerlRegExOptions;
    FState: TPerlRegExState;
    FRegEx, FReplacement, FSubject: str;
    FStart, FStop: Integer;
    FOnMatch: TNotifyEvent;
    FOnReplace: TPerlRegExReplaceEvent;
    function GetMatchedExpression: str;
    function GetMatchedExpressionLength: Integer;
    function GetMatchedExpressionOffset: Integer;
    procedure SetOptions(Value: TPerlRegExOptions);
    procedure SetRegEx(const Value: str);
    function GetSubExpressions(Index: Integer): str;
    function GetSubExpressionLengths(Index: Integer): Integer;
    function GetSubExpressionOffsets(Index: Integer): Integer;
    procedure SetSubject(const Value: str);
    procedure SetStart(const Value: Integer);
    procedure SetStop(const Value: Integer);
    function GetFoundMatch: Boolean;
  private    // *** Variables used by pcrelib.dll
    Offsets: array[0..(MAX_SUBEXPRESSIONS+1)*3] of Integer;
    OffsetCount: Integer;
    pcreOptions: Integer;
    pattern, hints, chartable: Pointer;
    FSubjectPChar: PChar;
    FHasStoredSubExpressions: Boolean;
    FStoredSubExpressions: array of str;
  protected
    procedure CleanUp;
        // Dispose off whatever we created, so we can start over. Called automatically when needed, so it is not made public
    procedure ClearStoredSubExpressions;
  public
    constructor Create(AOwner: TComponent); override;
        // Come to life
    destructor Destroy; override;
        // Clean up after ourselves
    class function EscapeRegExChars(const S: str): str;
        // Escapes regex characters in S so that the regex engine can be used to match S as plain text
    procedure Compile;
        // Compile the regex. Called automatically by Match
    procedure Study;
        // Study the regex. Studying takes time, but will make the execution of the regex a lot faster.
        // Call study if you will be using the same regex many times
    function GetSubExpressionCount: Integer;
    function Match: Boolean;
        // Attempt to match the regex
    function MatchAgain: Boolean;
        // Attempt to match the regex to the remainder of the string after the previous match
        // To avoid problems (when using ^ in the regex), call MatchAgain only after a succesful Match()
    function Replace: str;
        // Replace matched expression in Subject with ComputeReplacement.  Returns the actual replacement text from ComputeReplacement
    function ReplaceAll: Boolean;
        // Repeat MatchAgain and Replace until you drop.  Returns True if anything was replaced at all.

    function repl(const s,r:str; n:str=''):str;// Replace with parameters OAN
    function delCom(s:str):str;                // удаление комментариев OAN
    function find(const s,r:str): Boolean;     // match с параметрами OAN
    function ComputeReplacement: str;
        // Returns Replacement with backreferences filled in
    procedure StoreSubExpressions;
        // Stores duplicates of SubExpressions[] so they and ComputeReplacement will still return the proper strings
        // even if FSubject is changed or cleared
    function NamedSubExpression(const SEName: str): Integer;
        // Returns the index of the named group SEName
    procedure SplitS(Strings: TStrings; Limit: Integer);
        // Split Subject along regex matches.  Items are appended to Strings.
    function Split(s: string; r:str; Limit: Integer=-1):taos; // как функция с параметрами OAN
//    function Split(s: str; r:str; Limit: Integer=-1):tStringList;
    property Compiled: Boolean read FCompiled;
        // True if the RegEx has already been compiled.
    property FoundMatch: Boolean read GetFoundMatch;
        // Returns True when MatchedExpression* and SubExpression* indicate a match
    property Studied: Boolean read FStudied;
        // True if the RegEx has already been studied
    property MatchedExpression: str read GetMatchedExpression;
        // The matched string
    property MatchedExpressionLength: Integer read GetMatchedExpressionLength;
    property el: Integer read GetMatchedExpressionLength; //исправлено для краткости
        // Length of the matched string
    property MatchedExpressionOffset: Integer read GetMatchedExpressionOffset;
    property eo: Integer read GetMatchedExpressionOffset; //исправлено для краткости
        // Character offset in the Subject string at which the matched substring starts
    property Start: Integer read FStart write SetStart;
        // Starting position in Subject from which MatchAgain begins
    property Stop: Integer read FStop write SetStop;
        // Last character in Subject that Match and MatchAgain search through
    property State: TPerlRegExState read FState write FState;
        // State of Subject
    property SubExpressionCount: Integer read GetSubExpressionCount;
        // Number of matched subexpressions
    property SubExpressions[Index: Integer]: str read GetSubExpressions;
    property se[Index: Integer]: str read GetSubExpressions; //исправлено для краткости
        // Matched subexpressions after a regex has been matched
    property SubExpressionLengths[Index: Integer]: Integer read GetSubExpressionLengths;
        // Lengths of the subexpressions
    property SubExpressionOffsets[Index: Integer]: Integer read GetSubExpressionOffsets;
        // Character offsets in the Subject string of the subexpressions
    property Subject: str read FSubject write SetSubject;
        // The string on which Match() will try to match RegEx
  published
    property Options: TPerlRegExOptions read FOptions write SetOptions;
        // Options
    property RegEx: str read FRegEx write SetRegEx;
        // The regular expression to be matched
    property Replacement: str read FReplacement write FReplacement;
        // String to replace matched expression with. \number backreferences will be substituted with SubExpressions
    property OnMatch: TNotifyEvent read FOnMatch write FOnMatch;
        // Triggered by Match and MatchAgain after a successful match
    property OnReplace: TPerlRegExReplaceEvent read FOnReplace write FOnReplace;
        // Triggered by Replace and ReplaceAll just before the replacement is done, allowing you to determine the new string
  end;

{
  You can add TPerlRegEx components to a TPerlRegExList to match them all together on the same subject,
  as if they were one regex regex1|regex2|regex3|...
  TPerlRegExList does not own the TPerlRegEx components, just like a TList
  If a TPerlRegEx has been added to a TPerlRegExList, it should not be used in any other situation
  until it is removed from the list
}

type
  TPerlRegExList = class
  private
    FList: TList;
    FSubject: str;
    FMatchedRegEx: TPerlRegEx;
    FStart, FStop: Integer;
    function GetRegEx(Index: Integer): TPerlRegEx;
    procedure SetRegEx(Index: Integer; Value: TPerlRegEx);
    procedure SetSubject(const Value: str);
    procedure SetStart(const Value: Integer);
    procedure SetStop(const Value: Integer);
    function GetCount: Integer;
  protected
    procedure UpdateRegEx(ARegEx: TPerlRegEx);
  public
    constructor Create;
    destructor Destroy; override;
  public
    function Add(ARegEx: TPerlRegEx): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    function IndexOf(ARegEx: TPerlRegEx): Integer;
    procedure Insert(Index: Integer; ARegEx: TPerlRegEx);
  public
    function Match: Boolean;
    function MatchAgain: Boolean;
    property RegEx[Index: Integer]: TPerlRegEx read GetRegEx write SetRegEx;
    property Count: Integer read GetCount;
    property Subject: str read FSubject write SetSubject;
    property Start: Integer read FStart write SetStart;
    property Stop: Integer read FStop write SetStop;
    property MatchedRegEx: TPerlRegEx read FMatchedRegEx;
  end;

//procedure Register;
//var rep: tPerlRegEx; wr:boolean=false; rex2: string=''; z2: string;  // добавка для второго преобразования от ОАН

implementation

         { ********* Unit support routines ********* }
(* исправлено
procedure Register;
begin
  RegisterComponents('JGsoft', [TPerlRegEx]);
end;
*)
function AnsiFirstCap(const S: AnsiString): AnsiString;
begin
  Result := AnsiLowerCase(S);
  if (Result <> '') and not (Result[1] in LeadBytes) then begin
  {$IFDEF MSWINDOWS}
    CharUpperBuff(@Result[1], 1);
  {$ENDIF}
  {$IFDEF LINUX}
    Result[1] := UpperCase(Result[1])[1];
  {$ENDIF}
  end
end;

function AnsiInitialCaps(const S: AnsiString): AnsiString;
var
  I: Integer;
  Up: Boolean;
begin
  Result := AnsiLowerCase(S);
  Up := True;
  if SysLocale.FarEast then begin
    I := 1;
    while I <= Length(Result) do begin
      if Result[I] in LeadBytes then begin
        Inc(I, 2)
      end
      else begin
        if Result[I] in [#0..'&', '('..'.', '?', '<', '[', '{', '·'] then Up := True
        else if Up and (Result[I] <> '''') then begin
        {$IFDEF MSWINDOWS}
          CharUpperBuff(@Result[I], 1);
        {$ENDIF}
        {$IFDEF LINUX}
          Result[I] := UpperCase(Result[I])[1];
        {$ENDIF}
          Up := False
        end;
        Inc(I)
      end
    end
  end
  else
    for I := 1 to Length(Result) do begin
      if Result[I] in [#0..'&', '('..'.', '?', '<', '[', '{', '·'] then Up := True
      else if Up and (Result[I] <> '''') then begin
      {$IFDEF MSWINDOWS}
        CharUpperBuff(@Result[I], 1);
      {$ENDIF}
      {$IFDEF LINUX}
        Result[I] := AnsiUpperCase(Result[I])[1];
      {$ENDIF}
        Up := False
      end
    end;
end;


         { ********* pcrelib.dll imports ********* }

const
  PCRE_CASELESS        = $0001;
  PCRE_MULTILINE       = $0002;
  PCRE_SINGLELINE      = $0004;
  PCRE_EXTENDED        = $0008;
  PCRE_ANCHORED        = $0010;
  PCRE_DOLLAR_ENDONLY  = $0020;
  PCRE_EXTRA           = $0040;
  PCRE_NOTBOL          = $0080;
  PCRE_NOTEOL          = $0100;
  PCRE_UNGREEDY        = $0200;
  PCRE_NOTEMPTY        = $0400;

  // Exec error codes
  PCRE_ERROR_NOMATCH        = -1;
  PCRE_ERROR_NULL           = -2;
  PCRE_ERROR_BADOPTION      = -3;
  PCRE_ERROR_BADMAGIC       = -4;
  PCRE_ERROR_UNKNOWN_NODE   = -5;
  PCRE_ERROR_NOMEMORY       = -6;

type
  PPChar = ^PChar;
  PInt = ^Integer;

{$IFDEF NO_PCRE_DLL}

// If we are not allowed to use a DLL, we will link the OBJ files C++Builder 3.0 generates while building the DLL
// directly into our Pascal unit.

{$L pcre\maketables.obj}
{$L pcre\study.obj}
{$L pcre\pcre.obj}
{$L pcre\get.obj}
function  _pcre_maketables: PAnsiChar; cdecl; external;
function  _pcre_compile(const pattern: PChar; options: Integer; errorptr: PPChar; erroroffset: PInt;
                        const tables: PChar): Pointer; cdecl; external;
function  _pcre_exec(const pattern: Pointer; const hints: Pointer; const subject: PChar;
                     length, startoffset, options: Integer; offsets: PInt; offsetcount: Integer): Integer; cdecl; external;
function  _pcre_get_stringnumber(const pattern: Pointer; const Name: PChar): Integer; cdecl; external;
function  _pcre_study(const pattern: Pointer; options: Integer; errorptr: PPChar): Pointer; cdecl; external;
function  _pcre_fullinfo(const pattern: Pointer; const hints: Pointer; what: Integer; where: Pointer): Integer; cdecl; external;
function  _pcre_version: pchar; cdecl; external;
procedure _pcre_dispose(pattern, hints, chartable: Pointer); cdecl; external;

// These functions are required by pcre.obj and study.obj
// Unlike the DLL, this unit is not being linked agains the standard C libraries, so we have to provide them ourselves
{$I CHELPERS.PAS}

{$ELSE}

// Functions we import from the PCRE library DLL
// Leading underscores gratuitously added by Borland C++Builder 6.0
function  _pcre_maketables: PAnsiChar; cdecl; external 'pcrelib.dll';
function  _pcre_compile(const pattern: PChar; options: Integer; errorptr: PPChar; erroroffset: PInt;
                        const tables: PChar): Pointer; cdecl; external 'pcrelib.dll';
function  _pcre_exec(const pattern: Pointer; const hints: Pointer; const subject: PChar; length, startoffset: Integer;
                     options: Integer; offsets: PInt; offsetcount: Integer): Integer; cdecl; external 'pcrelib.dll';
function  _pcre_get_stringnumber(const pattern: Pointer; const Name: PChar): Integer; cdecl; external 'pcrelib.dll';
function  _pcre_study(const pattern: Pointer; options: Integer; errorptr: PPChar): Pointer; cdecl; external 'pcrelib.dll';
function  _pcre_fullinfo(const pattern: Pointer; const hints: Pointer; what: Integer; where: Pointer): Integer; cdecl; external 'pcrelib.dll';
function  _pcre_version: pchar; cdecl; external 'pcrelib.dll';
procedure _pcre_dispose(pattern, hints, chartable: Pointer); cdecl; external 'pcrelib.dll';

{$ENDIF}


         { ********* TPerlRegEx component ********* }

procedure TPerlRegEx.CleanUp;
begin
  FCompiled := False; FStudied := False;
  _pcre_dispose(pattern, hints, nil);
  pattern := nil; hints := nil;
  ClearStoredSubExpressions;
  OffsetCount := 0;
end;

procedure TPerlRegEx.ClearStoredSubExpressions;
begin
  FHasStoredSubExpressions := False;
  FStoredSubExpressions := nil;
end;

procedure TPerlRegEx.Compile;
var
  Error: PChar;
  ErrorOffset: Integer;
begin
  if FRegEx = '' then raise Exception.Create('TPerlRegEx.Compile() - Please specify a regular expression in RegEx first');
  CleanUp;
  Pattern := _pcre_compile(PChar(FRegEx), pcreOptions, @Error, @ErrorOffset, chartable);
  if Pattern = nil then
    raise Exception.Create(Format('TPerlRegEx.Compile() - Error in regex at offset %d: %s', [ErrorOffset, AnsiString(Error)]));
  FCompiled := True
end;

(* Backreference overview:

Assume there are 13 backreferences:

Text        TPerlRegex    .NET      Java       ECMAScript
$17         $1 + "7"      "$17"     $1 + "7"   $1 + "7"
$017        $1 + "7"      "$017"    $1 + "7"   $1 + "7"
$12         $12           $12       $12        $12
$012        $1 + "2"      $12       $12        $1 + "2"
${1}2       $1 + "2"      $1 + "2"  error      "${1}2"
$$          "$"           "$"       error      "$"
\$          "$"           "\$"      "$"        "\$"
*)

function TPerlRegEx.ComputeReplacement: str;
var
  Mode: Chr;
  S: str;
  I, J, N: Integer;

  procedure ReplaceBackreference(Number: Integer);
  var
    Backreference: str;
  begin
    Delete(S, I, J-I);
    if Number <= SubExpressionCount then begin
      Backreference := SubExpressions[Number];
      if Backreference <> '' then begin
        case Mode of
          'L': Backreference := AnsiLowerCase(Backreference);
          'U': Backreference := AnsiUpperCase(Backreference);
          'F': Backreference := AnsiFirstCap(Backreference);
          'I': Backreference := AnsiInitialCaps(Backreference);
        end;
        if S <> '' then begin
          Insert(Backreference, S, I);
          I := I + Length(Backreference);
        end
        else begin
          S := Backreference;
          I := MaxInt;
        end
      end;
    end
  end;

  procedure ProcessBackreference(AllowBrace: Boolean);
  var
    Number, Number2: Integer;
    Group: str;
  begin
    Number := -1;
    if (J <= Length(S)) and (S[J] in ['0'..'9']) then begin
      // Get the number of the backreference
      Number := Ord(S[J]) - Ord('0');
      Inc(J);
      if (J <= Length(S)) and (S[J] in ['0'..'9']) then begin
        // Expand it to two digits only if that would lead to a valid backreference
        Number2 := Number*10 + Ord(S[J]) - Ord('0');
        if Number2 <= SubExpressionCount then begin
          Number := Number2;
          Inc(J)
        end;
      end;
    end
    else if AllowBrace and (J < Length(S)) and (S[J] = '{') then begin
      // Number or name in curly braces
      Inc(J);
      if S[J] in ['0'..'9'] then begin
        Number := Ord(S[J]) - Ord('0');
        Inc(J);
        while (J <= Length(S)) and (S[J] in ['0'..'9']) do begin
          Number := Number*10 + Ord(S[J]) - Ord('0');
          Inc(J)
        end;
      end
      else if S[J] in ['A'..'Z', 'a'..'z', '_'] then begin
        Inc(J);
        while (J <= Length(S)) and (S[J] in ['A'..'Z', 'a'..'z', '0'..'9', '_']) do Inc(J);
        if (J <= Length(S)) and (S[J] = '}') then begin
          Group := Copy(S, I+2, J-I-2);
          Number := NamedSubExpression(Group);
        end
      end;
      if (J > Length(S)) or (S[J] <> '}') then Number := -1
        else Inc(J)
    end;
    if Number >= 0 then ReplaceBackreference(Number)
      else Inc(I)
  end;

begin
  S := FReplacement;
  I := 1;
  while I < Length(S) do begin
    if S[I] = '\' then begin
      J := I + 1;
      Assert(J <= Length(S), 'CHECK: We let I stop one character before the end, so J cannot point beyond the end of the string here');
      if S[J] in ['$', '\'] then begin
        Delete(S, I, 1);
        Inc(I);
      end
      else if UpCase(S[J]) = 'G' then begin
        if (J < Length(S)-1) and (S[J+1] = '<') and (S[J+2] in ['A'..'Z', 'a'..'z', '_']) then begin
          // Python-style named group reference \g<name>
          J := J+3;
          while (J <= Length(S)) and (S[J] in ['0'..'9', 'A'..'Z', 'a'..'z', '_']) do Inc(J);
          if (J <= Length(S)) and (S[J] = '>') then begin
            N := NamedSubExpression(Copy(S, I+3, J-I-3));
            Inc(J);
            Mode := #0;
            if N > 0 then ReplaceBackreference(N)
              else Delete(S, I, J-I)
          end
          else I := J
        end
        else I := I+2;
      end
      else begin
        if UpCase(S[J]) in ['L', 'U', 'F', 'I'] then begin
          Mode := UpCase(S[J]);
          Inc(J);
        end
        else Mode := #0;
        ProcessBackreference(False);
      end
    end
    else if S[I] = '$' then begin
      J := I + 1;
      Assert(J <= Length(S), 'CHECK: We let I stop one character before the end, so J cannot point beyond the end of the string here');
      if S[J] = '$' then begin
        Delete(S, J, 1);
        Inc(I);
      end
      else begin
        Mode := #0;
        ProcessBackreference(True);
      end
    end
    else Inc(I)
  end;
  Result := S
end;

constructor TPerlRegEx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FState := [preNotEmpty];
  chartable := _pcre_maketables;
end;

destructor TPerlRegEx.Destroy;
begin
  CleanUp;
  _pcre_dispose(nil, nil, chartable);
  inherited Destroy;
end;

class function TPerlRegEx.EscapeRegExChars(const S: str): str;
var
  I: Integer;
begin
  Result := S;
  I := Length(Result);
  while I > 0 do begin
    if Result[I] in ['.', '[', ']', '(', ')', '?', '*', '+', '{', '}', '^', '$', '|', '\'] then
      Insert('\', Result, I)
    else if Result[I] = #0 then begin
      Result[I] := '0';
      Insert('\', Result, I);
    end;
    Dec(I);
  end;
end;

function TPerlRegEx.GetFoundMatch: Boolean;
begin
  Result := OffsetCount > 0;
end;

function TPerlRegEx.GetMatchedExpression: str;
begin
  Assert(FoundMatch, 'REQUIRE: There must be a successful match first');
  Result := GetSubExpressions(0);
end;

function TPerlRegEx.GetMatchedExpressionLength: Integer;
begin
  Assert(FoundMatch, 'REQUIRE: There must be a successful match first');
  Result := GetSubExpressionLengths(0)
end;

function TPerlRegEx.GetMatchedExpressionOffset: Integer;
begin
  Assert(FoundMatch, 'REQUIRE: There must be a successful match first');
  Result := GetSubExpressionOffsets(0)
end;

function TPerlRegEx.GetSubExpressionCount: Integer;
begin
  Assert(FoundMatch, 'REQUIRE: There must be a successful match first');
  Result := OffsetCount-1
end;

function TPerlRegEx.GetSubExpressionLengths(Index: Integer): Integer;
begin
  Assert(FoundMatch, 'REQUIRE: There must be a successful match first');
  Assert((Index >= 0) and (Index <= SubExpressionCount), 'REQUIRE: Index <= SubExpressionCount');
  Result := Offsets[Index*2+1]-Offsets[Index*2]
end;

function TPerlRegEx.GetSubExpressionOffsets(Index: Integer): Integer;
begin
  Assert(FoundMatch, 'REQUIRE: There must be a successful match first');
  Assert((Index >= 0) and (Index <= SubExpressionCount), 'REQUIRE: Index <= SubExpressionCount');
  Result := Offsets[Index*2]
end;

function TPerlRegEx.GetSubExpressions(Index: Integer): str;
begin
  Assert(FoundMatch, 'REQUIRE: There must be a successful match first');
  if Index > SubExpressionCount then Result := ''
    else if FHasStoredSubExpressions then Result := FStoredSubExpressions[Index]
    else Result := Copy(FSubject, Offsets[Index*2], Offsets[Index*2+1]-Offsets[Index*2]);
end;

function TPerlRegEx.Match: Boolean;
var
  I, Opts: Integer;
begin
  ClearStoredSubExpressions;
  if not Compiled then Compile;
  if preNotBOL in State then Opts := PCRE_NOTBOL else Opts := 0;
  if preNotEOL in State then Opts := Opts or PCRE_NOTEOL;
  if preNotEmpty in State then Opts := Opts or PCRE_NOTEMPTY;
  if FStart > FStop then OffsetCount := -1
    else OffsetCount := _pcre_exec(Pattern, Hints, FSubjectPChar, FStop, 0, Opts, @Offsets[0], High(Offsets));
  Result := OffsetCount > 0;
  // Convert offsets into str indices
  if Result then begin
    for I := 0 to OffsetCount*2-1 do
      Inc(Offsets[I]);
    FStart := Offsets[1];
    if Offsets[0] = Offsets[1] then Inc(FStart); // Make sure we don't get stuck at the same position
    if Assigned(OnMatch) then OnMatch(Self)
  end;
end;

function TPerlRegEx.MatchAgain: Boolean;
var
  I, Opts: Integer;
begin
  ClearStoredSubExpressions;
  if not Compiled then Compile;
  if preNotBOL in State then Opts := PCRE_NOTBOL else Opts := 0;
  if preNotEOL in State then Opts := Opts or PCRE_NOTEOL;
// исправление - закоментированы 2 строки, чтобы сравнивались пустые :
//  if preNotEmpty in State then Opts := Opts or PCRE_NOTEMPTY;
//  if FStart > FStop then OffsetCount := -1  else
    OffsetCount := _pcre_exec(Pattern, Hints, FSubjectPChar, FStop, FStart-1, Opts, @Offsets[0], High(Offsets));
  Result := OffsetCount > 0;
  // Convert offsets into str indices
  if Result then begin
    for I := 0 to OffsetCount*2-1 do
      Inc(Offsets[I]);
    FStart := Offsets[1];
    if Offsets[0] = Offsets[1] then Inc(FStart); // Make sure we don't get stuck at the same position
    if Assigned(OnMatch) then OnMatch(Self)
  end;
end;

function TPerlRegEx.NamedSubExpression(const SEName: str): Integer;
begin
  Result := _pcre_get_stringnumber(Pattern, PChar(SEName));
end;

function TPerlRegEx.Replace: str;
begin
  Assert(FoundMatch, 'REQUIRE: There must be a successful match first');
  // Substitute backreferences
  Result := ComputeReplacement;
  // Allow for just-in-time substitution determination
  if Assigned(OnReplace) then OnReplace(Self, Result);
  // Perform substitution
  Delete(FSubject, MatchedExpressionOffset, MatchedExpressionLength);
  if Result <> '' then Insert(Result, FSubject, MatchedExpressionOffset);
  FSubjectPChar := PChar(FSubject);
  // Position to continue search
  FStart := FStart - MatchedExpressionLength + Length(Result);
  FStop := FStop - MatchedExpressionLength + Length(Result);
  // Replacement no longer matches regex, we assume
  ClearStoredSubExpressions;
  OffsetCount := 0;
end;

function TPerlRegEx.ReplaceAll: Boolean;
begin
  if Match then begin
    Result := True;
    repeat
      Replace
    until not MatchAgain;
  end
  else Result := False;
end;

function TPerlRegEx.Repl(const s,r:str; n:str=''):str; // с параметрами
begin
Subject := s; if r<>'' then RegEx:=r; Replacement:=n;
ReplaceAll;
result:=Subject;
end;

function TPerlRegEx.delCom(s:str):str; // удаление комментариев
begin
//  result:=repl(s,'//[^\r\n]+[\r\n]*');
  result:=repl(s,'//[^\r\n]*');
end;

function TPerlRegEx.find(const s,r:str): Boolean; // с параметрами
begin
  Subject:=s;  if r<>'' then RegEx:=r;  result:=match;
end;

procedure TPerlRegEx.SetOptions(Value: TPerlRegExOptions);
begin
  if (FOptions <> Value) then begin
    FOptions := Value;
    pcreOptions := 0;
    if (preCaseLess in Value) then pcreOptions := pcreOptions or PCRE_CASELESS;
    if (preMultiLine in Value) then pcreOptions := pcreOptions or PCRE_MULTILINE;
    if (preSingleLine in Value) then pcreOptions := pcreOptions or PCRE_SINGLELINE;
    if (preExtended in Value) then pcreOptions := pcreOptions or PCRE_EXTENDED;
    if (preAnchored in Value) then pcreOptions := pcreOptions or PCRE_ANCHORED;
    if (preDollarEndOnly in Value) then pcreOptions := pcreOptions or PCRE_DOLLAR_ENDONLY;
    if (preExtra in Value) then pcreOptions := pcreOptions or PCRE_EXTRA;
    if (preUnGreedy in Value) then pcreOptions := pcreOptions or PCRE_UNGREEDY;
    CleanUp
  end
end;

procedure TPerlRegEx.SetRegEx(const Value: str);
begin
  if FRegEx <> Value then begin
    FRegEx := Value;
    CleanUp
  end
end;

procedure TPerlRegEx.SetStart(const Value: Integer);
begin
  if Value < 1 then FStart := 1
  else FStart := Value;
  // If FStart > Length(Subject), MatchAgain() will simply return False
end;

procedure TPerlRegEx.SetStop(const Value: Integer);
begin
  if Value > Length(Subject) then FStop := Length(Subject)
    else FStop := Value;
end;

procedure TPerlRegEx.SetSubject(const Value: str);
begin
  FSubject := Value;
  FSubjectPChar := PChar(Value);
  FStart := 1;
  FStop := Length(Subject);
  if not FHasStoredSubExpressions then OffsetCount := 0;
end;

procedure TPerlRegEx.SplitS(Strings: TStrings; Limit: Integer);
var
  Offset, Count: Integer;
begin
  Assert(Strings <> nil, 'REQUIRE: Strings');
  if (Limit = 1) or not Match then Strings.Add(Subject)
  else begin
    Offset := 1;
    Count := 1;
    repeat
      Strings.Add(Copy(Subject, Offset, MatchedExpressionOffset - Offset));
      Inc(Count);
      Offset := MatchedExpressionOffset + MatchedExpressionLength;
    until ((Limit > 1) and (Count >= Limit)) or not MatchAgain;
    Strings.Add(Copy(Subject, Offset, MaxInt));
  end
end;

function TPerlRegEx.Split(s: string; r:str; Limit: Integer=-1):taos;
var
  Offset, Count: Integer;
begin
  if limit<0 then limit:=maxInt; RegEx:=r; Subject:=s;
  if not Match then begin setLength(result,1); result[0]:=Subject end
  else begin
    Offset := 1;
    Count := 0;
    repeat
      if length(result)<=count then setLength(result,length(result)+10);
      result[count]:=Copy(Subject, Offset, MatchedExpressionOffset - Offset);
      Inc(Count);
      Offset := MatchedExpressionOffset + MatchedExpressionLength;
      if (limit>0) and (Count>=Limit) then begin setLength(result,count); exit end;
    until not MatchAgain;
    setLength(result,count+1);
    result[count]:=Copy(Subject, Offset, maxInt);
  end
end;

{function TPerlRegEx.Split(s: string; r:str; Limit: Integer=-1): tStringList;
begin
if limit<0 then limit:=maxInt; RegEx:=r; Subject:=s;
result:=tStringList.create;
splitS(result, Limit);
end;}

procedure TPerlRegEx.StoreSubExpressions;
var
  I: Integer;
begin
  if OffsetCount > 0 then begin
    ClearStoredSubExpressions;
    SetLength(FStoredSubExpressions, SubExpressionCount+1);
    for I := SubExpressionCount downto 0 do
      FStoredSubExpressions[I] := SubExpressions[I];
    FHasStoredSubExpressions := True;
  end
end;

procedure TPerlRegEx.Study;
var
  Error: PChar;
begin
  if not FCompiled then Compile;
  Hints := _pcre_study(Pattern, 0, @Error);
  if Error <> nil then raise Exception.Create('TPerlRegEx.Study() - Error studying the regex: ' + AnsiString(Error));
  FStudied := True
end;

{ TPerlRegExList }

function TPerlRegExList.Add(ARegEx: TPerlRegEx): Integer;
begin
  Result := FList.Add(ARegEx);
  UpdateRegEx(ARegEx);
end;

procedure TPerlRegExList.Clear;
begin
  FList.Clear;
end;

constructor TPerlRegExList.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

procedure TPerlRegExList.Delete(Index: Integer);
begin
  FList.Delete(Index);
end;

destructor TPerlRegExList.Destroy;
begin
  FList.Free;
  inherited
end;

function TPerlRegExList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPerlRegExList.GetRegEx(Index: Integer): TPerlRegEx;
begin
  Result := TPerlRegEx(Pointer(FList[Index]));
end;

function TPerlRegExList.IndexOf(ARegEx: TPerlRegEx): Integer;
begin
  Result := FList.IndexOf(ARegEx);
end;

procedure TPerlRegExList.Insert(Index: Integer; ARegEx: TPerlRegEx);
begin
  FList.Insert(Index, ARegEx);
  UpdateRegEx(ARegEx);
end;

function TPerlRegExList.Match: Boolean;
begin
  SetStart(1);
  FMatchedRegEx := nil;
  Result := MatchAgain;
end;

function TPerlRegExList.MatchAgain: Boolean;
var
  I, MatchStart, MatchPos: Integer;
  ARegEx: TPerlRegEx;
begin
  if FMatchedRegEx <> nil then
    MatchStart := FMatchedRegEx.MatchedExpressionOffset + FMatchedRegEx.MatchedExpressionLength
  else
    MatchStart := FStart;
  FMatchedRegEx := nil;
  MatchPos := MaxInt;
  for I := 0 to Count-1 do begin
    ARegEx := RegEx[I];
    if (not ARegEx.FoundMatch) or (ARegEx.MatchedExpressionOffset < MatchStart) then begin
      ARegEx.Start := MatchStart;
      ARegEx.MatchAgain;
    end;
    if ARegEx.FoundMatch and (ARegEx.MatchedExpressionOffset < MatchPos) then begin
      MatchPos := ARegEx.MatchedExpressionOffset;
      FMatchedRegEx := ARegEx;
    end;
    if MatchPos = MatchStart then Break;
  end;
  Result := MatchPos < MaxInt;
end;

procedure TPerlRegExList.SetRegEx(Index: Integer; Value: TPerlRegEx);
begin
  FList[Index] := Value;
  UpdateRegEx(Value);
end;

procedure TPerlRegExList.SetStart(const Value: Integer);
var
  I: Integer;
begin
  if FStart <> Value then begin
    FStart := Value;
    for I := Count-1 downto 0 do
      RegEx[I].Start := Value;
    FMatchedRegEx := nil;
  end;
end;

procedure TPerlRegExList.SetStop(const Value: Integer);
var
  I: Integer;
begin
  if FStop <> Value then begin
    FStop := Value;
    for I := Count-1 downto 0 do
      RegEx[I].Stop := Value;
    FMatchedRegEx := nil;
  end;
end;

procedure TPerlRegExList.SetSubject(const Value: str);
var
  I: Integer;
begin
  if FSubject <> Value then begin
    FSubject := Value;
    for I := Count-1 downto 0 do
      RegEx[I].Subject := Value;
    FMatchedRegEx := nil;
  end;
end;

procedure TPerlRegExList.UpdateRegEx(ARegEx: TPerlRegEx);
begin
  ARegEx.Subject := FSubject;
  ARegEx.Start := FStart;
end;

end.
