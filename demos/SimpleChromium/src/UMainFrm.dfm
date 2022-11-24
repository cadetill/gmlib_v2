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
  TextHeight = 15
  object CEFWindowParent1: TCEFWindowParent
    Left = 0
    Top = 81
    Width = 1009
    Height = 506
    Align = alClient
    TabStop = True
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1009
    Height = 81
    Align = alTop
    Caption = ' '
    TabOrder = 1
    object lAPIKey: TLabel
      Left = 144
      Top = 8
      Width = 37
      Height = 15
      Caption = 'APIKey'
    end
    object cbActivate: TCheckBox
      Left = 32
      Top = 35
      Width = 97
      Height = 17
      Caption = 'Activate'
      TabOrder = 0
      OnClick = cbActivateClick
    end
    object eAPIKey: TEdit
      Left = 144
      Top = 32
      Width = 377
      Height = 23
      TabOrder = 1
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
    Markers.Markers = <>
    Markers.AutoUpdate = False
    APILang = lSpanish
    APIRegion = rSpain
    TrafficLayer.Show = False
    TrafficLayer.TrafficLayerOptions.AutoRefresh = True
    TransitLayer.Show = False
    ByciclingLayer.Show = False
    KmlLayer.Show = False
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
