object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'MainFrm'
  ClientHeight = 587
  ClientWidth = 1009
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 15
  object CEFWindowParent1: TCEFWindowParent
    Left = 0
    Top = 0
    Width = 708
    Height = 587
    Align = alClient
    TabStop = True
    TabOrder = 0
    ExplicitTop = 81
    ExplicitWidth = 1009
    ExplicitHeight = 506
  end
  object Panel2: TPanel
    Left = 708
    Top = 0
    Width = 301
    Height = 587
    Align = alRight
    Caption = ' '
    TabOrder = 1
    ExplicitLeft = 696
    ExplicitHeight = 505
    object lAPIKey: TLabel
      Left = 16
      Top = 48
      Width = 37
      Height = 15
      Caption = 'APIKey'
    end
    object lAPILang: TLabel
      Left = 16
      Top = 96
      Width = 44
      Height = 15
      Caption = 'APILang'
    end
    object lAPIRegion: TLabel
      Left = 127
      Top = 96
      Width = 55
      Height = 15
      Caption = 'APIRegion'
    end
    object lAPIVersion: TLabel
      Left = 16
      Top = 144
      Width = 56
      Height = 15
      Caption = 'APIVersion'
    end
    object lIntervalEvents: TLabel
      Left = 16
      Top = 202
      Width = 76
      Height = 15
      Caption = 'Interval Events'
    end
    object cbActive: TCheckBox
      Left = 16
      Top = 19
      Width = 97
      Height = 17
      Caption = 'Active'
      TabOrder = 0
      OnClick = cbActiveClick
    end
    object eAPIKey: TEdit
      Left = 16
      Top = 64
      Width = 273
      Height = 23
      TabOrder = 1
      OnChange = eAPIKeyChange
    end
    object cbAPILang: TComboBox
      Left = 16
      Top = 112
      Width = 105
      Height = 22
      Style = csOwnerDrawFixed
      TabOrder = 2
      OnChange = cbAPILangChange
    end
    object cbAPIRegion: TComboBox
      Left = 127
      Top = 112
      Width = 162
      Height = 22
      Style = csOwnerDrawFixed
      TabOrder = 3
    end
    object cbAPIVersion: TComboBox
      Left = 16
      Top = 160
      Width = 105
      Height = 22
      Style = csOwnerDrawFixed
      TabOrder = 4
    end
    object eIntervalEvents: TSpinEdit
      Left = 16
      Top = 218
      Width = 81
      Height = 24
      MaxValue = 1000
      MinValue = 1
      TabOrder = 5
      Value = 200
      OnChange = eAPIKeyChange
    end
  end
  object GMMapChrm1: TGMMapChrm
    Browser = Chromium1
    MapOptions.ClickableIcons = True
    MapOptions.GestureHandling = ghAuto
    MapOptions.IsFractionalZoomEnabled = True
    MapOptions.Restriction.StrictBounds = False
    MapOptions.Restriction.Enabled = False
    APILang = lSpanish
    APIRegion = rSpain
    Left = 304
    Top = 224
  end
  object Chromium1: TChromium
    OnAfterCreated = Chromium1AfterCreated
    OnBeforeClose = Chromium1BeforeClose
    OnClose = Chromium1Close
    Left = 50
    Top = 302
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 300
    OnTimer = Timer1Timer
    Left = 49
    Top = 225
  end
end
