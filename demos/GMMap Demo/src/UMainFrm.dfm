object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'MainFrm'
  ClientHeight = 505
  ClientWidth = 997
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 15
  object Panel1: TPanel
    Left = 696
    Top = 0
    Width = 301
    Height = 505
    Align = alRight
    Caption = ' '
    TabOrder = 0
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
  object EdgeBrowser1: TEdgeBrowser
    Left = 0
    Top = 0
    Width = 696
    Height = 505
    Align = alClient
    TabOrder = 1
  end
  object GMMapEdge1: TGMMapEdge
    Browser = EdgeBrowser1
    MapOptions.ClickableIcons = True
    MapOptions.GestureHandling = ghAuto
    MapOptions.IsFractionalZoomEnabled = True
    MapOptions.Restriction.StrictBounds = False
    MapOptions.Restriction.Enabled = False
    APIRegion = rUnited_States
    Left = 184
    Top = 216
  end
end
