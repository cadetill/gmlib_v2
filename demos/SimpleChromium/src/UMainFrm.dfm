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
    ExplicitLeft = -557
    ExplicitTop = -219
    ExplicitWidth = 1179
    ExplicitHeight = 652
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1009
    Height = 81
    Align = alTop
    Caption = ' '
    TabOrder = 1
    ExplicitWidth = 622
    object cbActivate: TCheckBox
      Left = 32
      Top = 32
      Width = 97
      Height = 17
      Caption = 'cbActivate'
      TabOrder = 0
      OnClick = cbActivateClick
    end
  end
  object GMMapChrm1: TGMMapChrm
    Browser = Chromium1
    MapOptions.ClickableIcons = True
    MapOptions.GestureHandling = ghAuto
    MapOptions.IsFractionalZoomEnabled = True
    MapOptions.Restriction.StrictBounds = False
    MapOptions.Restriction.Enabled = False
    APILang = lEnglish
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
