object Form1: TForm1
  Left = 226
  Top = 329
  Width = 673
  Height = 521
  Caption = 'fani_Server'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Label18: TLabel
    Left = 13
    Top = 249
    Width = 36
    Height = 19
    Caption = #1043#1086#1083#1086#1089
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clBlack
    Font.Height = -16
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
  end
  object Label10: TLabel
    Left = 20
    Top = 303
    Width = 58
    Height = 15
    Caption = #1043#1088#1086#1084#1082#1086#1089#1090#1100
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
  end
  object Label11: TLabel
    Left = 141
    Top = 303
    Width = 51
    Height = 15
    Caption = #1057#1082#1086#1088#1086#1089#1090#1100
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
  end
  object Label30: TLabel
    Left = 264
    Top = 303
    Width = 41
    Height = 15
    Caption = #1042#1099#1089#1086#1090#1072
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
  end
  object Label1: TLabel
    Left = 242
    Top = 267
    Width = 217
    Height = 15
    Caption = #1059#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1080#1079' https://rhvoice.su/voices/'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 242
    Top = 281
    Width = 323
    Height = 15
    Caption = 'https://github.com/snakers4/silero-models/releases/tag/v5.2'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 657
    Height = 188
    TabStop = False
    Align = alTop
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Consolas'
    Font.Style = []
    Lines.Strings = (
      #1069#1090#1072' '#1087#1088#1086#1075#1088#1072#1084#1084#1072' '#1076#1083#1103' '#1073#1086#1088#1100#1073#1099' '#1089' '#1079#1072#1087#1088#1077#1090#1072#1084#1080' '#1073#1088#1072#1091#1079#1077#1088#1072'.'
      #1057' '#1085#1077#1081' javascript '#1084#1086#1078#1077#1090' '#1074#1089#1105'.'
      '')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Button1: TButton
    Left = 281
    Top = 195
    Width = 131
    Height = 25
    Caption = 'Extract from exe'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = Button1Click
  end
  object lstEngine: TComboBox
    Left = 15
    Top = 271
    Width = 220
    Height = 22
    DropDownCount = 16
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = []
    ItemHeight = 14
    ParentFont = False
    TabOrder = 2
    TabStop = False
    Text = 'Select Voice'
    OnDropDown = lstEngineDropDown
    OnSelect = lstEngineSelect
  end
  object TrackBar10: TTrackBar
    Left = 11
    Top = 315
    Width = 121
    Height = 25
    Ctl3D = True
    Max = 100
    ParentCtl3D = False
    PageSize = 1
    Frequency = 10
    Position = 50
    TabOrder = 3
    TabStop = False
    ThumbLength = 25
    TickMarks = tmBoth
    OnChange = TrackBar10Change
  end
  object TrackBar11: TTrackBar
    Left = 133
    Top = 315
    Width = 121
    Height = 27
    Max = 5
    Min = -5
    PageSize = 1
    TabOrder = 4
    TabStop = False
    ThumbLength = 25
    TickMarks = tmBoth
    OnChange = TrackBar11Change
  end
  object TrackBar30: TTrackBar
    Left = 258
    Top = 315
    Width = 122
    Height = 27
    Min = -10
    PageSize = 1
    TabOrder = 5
    TabStop = False
    ThumbLength = 25
    TickMarks = tmBoth
    OnChange = TrackBar30Change
  end
  object Button3: TButton
    Left = 11
    Top = 352
    Width = 131
    Height = 25
    Caption = #1057#1082#1072#1079#1072#1090#1100' '#1101#1090#1086#1090' '#1090#1077#1082#1089#1090': F9'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    TabStop = False
    OnClick = Button3Click
  end
  object wav8: TButton
    Left = 283
    Top = 352
    Width = 133
    Height = 25
    Hint = #1047#1072#1087#1080#1089#1072#1090#1100' '#1101#1090#1086#1090' '#1090#1077#1082#1089#1090' '#1074' wav '#1092#1072#1081#1083' '#1087#1086' '#1087#1088#1077#1076#1083#1086#1078#1077#1085#1080#1103#1084
    Caption = #1042' '#1092#1072#1081#1083' 22 '#1082#1075#1094' 16 '#1073#1080#1090
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
    TabStop = False
    OnClick = wav8Click
  end
  object Button4: TButton
    Left = 148
    Top = 352
    Width = 131
    Height = 25
    Hint = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1090#1077#1082#1089#1090' '#1076#1083#1103' '#1075#1086#1074#1086#1088#1077#1085#1080#1103' '#1080#1079' '#1092#1072#1081#1083#1072
    Caption = #1048#1079' '#1092#1072#1081#1083#1072
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
    TabStop = False
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 11
    Top = 195
    Width = 131
    Height = 25
    Hint = #1057#1086#1079#1076#1072#1085#1080#1077' EXE '#1080#1079' '#1080#1079#1087#1086#1083#1100#1079#1086#1074#1072#1085#1085#1099#1093' '#1092#1072#1081#1083#1086#1074
    Caption = #1057#1086#1079#1076#1072#1090#1100' EXE'
    TabOrder = 9
    OnClick = Button5Click
  end
  object txt: TMemo
    Left = 0
    Top = 384
    Width = 657
    Height = 98
    Align = alBottom
    Lines.Strings = (
      'txt')
    TabOrder = 10
  end
  object Button2: TButton
    Left = 145
    Top = 195
    Width = 131
    Height = 25
    Caption = 'Clean'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 11
    OnClick = Button2Click
  end
  object Button6: TButton
    Left = 420
    Top = 320
    Width = 114
    Height = 25
    Hint = #1047#1072#1087#1080#1089#1072#1090#1100' '#1101#1090#1086#1090' '#1090#1077#1082#1089#1090' '#1074' wav '#1092#1072#1081#1083' '#1087#1086' '#1087#1088#1077#1076#1083#1086#1078#1077#1085#1080#1103#1084
    Caption = #1047#1072#1087#1086#1084#1085#1080#1090#1100' '#1075#1086#1083#1086#1089
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 12
    TabStop = False
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 536
    Top = 320
    Width = 114
    Height = 25
    Hint = #1047#1072#1087#1080#1089#1072#1090#1100' '#1101#1090#1086#1090' '#1090#1077#1082#1089#1090' '#1074' wav '#1092#1072#1081#1083' '#1087#1086' '#1087#1088#1077#1076#1083#1086#1078#1077#1085#1080#1103#1084
    Caption = #1059#1076#1072#1083#1080#1090#1100
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 13
    TabStop = False
    OnClick = Button7Click
  end
  object CheckBox1: TCheckBox
    Left = 422
    Top = 356
    Width = 97
    Height = 17
    Caption = #1052#1077#1085#1103#1090#1100' '#1075#1086#1083#1086#1089
    TabOrder = 14
  end
  object Timer1: TTimer
    Interval = 20
    OnTimer = Timer1Timer
    Left = 8
    Top = 44
  end
  object IdHTTPServer1: TIdHTTPServer
    Bindings = <>
    CommandHandlers = <>
    DefaultPort = 8080
    Greeting.NumericCode = 0
    MaxConnectionReply.NumericCode = 0
    ReplyExceptionCode = 0
    ReplyTexts = <>
    ReplyUnknownCommand.NumericCode = 0
    OnCommandGet = IdHTTPServer1CommandGet
    Left = 48
    Top = 44
  end
  object OpenDialog1: TOpenDialog
    Left = 96
    Top = 44
  end
  object SaveDialog1: TSaveDialog
    Left = 128
    Top = 44
  end
  object IdHTTP1: TIdHTTP
    MaxLineAction = maException
    ReadTimeout = 0
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = 0
    Request.ContentRangeStart = 0
    Request.ContentType = 'text/html'
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoForceEncodeParams]
    Left = 164
    Top = 44
  end
  object OpenPicture: TOpenPictureDialog
    Left = 212
    Top = 44
  end
end
