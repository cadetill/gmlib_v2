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
    Top = 0
    Width = 708
    Height = 464
    Align = alClient
    TabStop = True
    TabOrder = 0
  end
  object Panel2: TPanel
    Left = 708
    Top = 0
    Width = 301
    Height = 464
    Align = alRight
    Caption = ' '
    TabOrder = 1
    object cbActive: TCheckBox
      AlignWithMargins = True
      Left = 16
      Top = 21
      Width = 281
      Height = 42
      Margins.Left = 15
      Margins.Top = 20
      Align = alTop
      Caption = 'Active'
      TabOrder = 0
      OnClick = cbActiveClick
    end
    object pcPages: TPageControl
      Left = 1
      Top = 66
      Width = 299
      Height = 397
      ActivePage = tsGeneral
      Align = alClient
      TabOrder = 1
      object tsGeneral: TTabSheet
        Caption = 'General'
        object lIntervalEvents: TLabel
          Left = 16
          Top = 178
          Width = 76
          Height = 15
          Caption = 'Interval Events'
        end
        object lAPIVersion: TLabel
          Left = 16
          Top = 120
          Width = 56
          Height = 15
          Caption = 'APIVersion'
        end
        object lAPILang: TLabel
          Left = 16
          Top = 72
          Width = 44
          Height = 15
          Caption = 'APILang'
        end
        object lAPIKey: TLabel
          Left = 16
          Top = 24
          Width = 37
          Height = 15
          Caption = 'APIKey'
        end
        object lAPIRegion: TLabel
          Left = 127
          Top = 72
          Width = 55
          Height = 15
          Caption = 'APIRegion'
        end
        object lLanguage: TLabel
          Left = 16
          Top = 280
          Width = 52
          Height = 15
          Caption = 'Language'
        end
        object eIntervalEvents: TSpinEdit
          Left = 16
          Top = 194
          Width = 81
          Height = 24
          MaxValue = 1000
          MinValue = 1
          TabOrder = 0
          Value = 200
          OnChange = eIntervalEventsChange
        end
        object cbAPIVersion: TComboBox
          Left = 16
          Top = 136
          Width = 105
          Height = 22
          Style = csOwnerDrawFixed
          TabOrder = 1
          OnChange = cbAPIVersionChange
        end
        object cbAPILang: TComboBox
          Left = 16
          Top = 88
          Width = 105
          Height = 22
          Style = csOwnerDrawFixed
          TabOrder = 2
          OnChange = cbAPILangChange
        end
        object eAPIKey: TEdit
          Left = 16
          Top = 40
          Width = 273
          Height = 23
          TabOrder = 3
          OnChange = eAPIKeyChange
        end
        object cbAPIRegion: TComboBox
          Left = 127
          Top = 88
          Width = 162
          Height = 22
          Style = csOwnerDrawFixed
          TabOrder = 4
          OnChange = cbAPIRegionChange
        end
        object cbLanguage: TComboBox
          Left = 16
          Top = 296
          Width = 105
          Height = 22
          Style = csOwnerDrawFixed
          TabOrder = 5
          OnChange = cbLanguageChange
        end
      end
      object tsMapOptions: TTabSheet
        Caption = 'MapOptions'
        ImageIndex = 1
      end
    end
  end
  object mEvents: TMemo
    Left = 0
    Top = 464
    Width = 1009
    Height = 123
    Align = alBottom
    ScrollBars = ssVertical
    TabOrder = 2
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
    OnActiveChange = GMMapChrm1ActiveChange
    OnIntervalEventsChange = GMMapChrm1IntervalEventsChange
    OnPrecisionChange = GMMapChrm1PrecisionChange
    OnPropertyChanges = GMMapChrm1PropertyChanges
    OnBoundsChanged = GMMapChrm1BoundsChanged
    OnCenterChanged = GMMapChrm1CenterChanged
    OnClick = GMMapChrm1Click
    OnDblClick = GMMapChrm1DblClick
    OnMouseMove = GMMapChrm1MouseMove
    OnMouseOut = GMMapChrm1MouseOut
    OnMouseOver = GMMapChrm1MouseOver
    OnContextmenu = GMMapChrm1Contextmenu
    OnDrag = GMMapChrm1Drag
    OnDragEnd = GMMapChrm1DragEnd
    OnDragStart = GMMapChrm1DragStart
    OnMapTypeIdChanged = GMMapChrm1MapTypeIdChanged
    OnZoomChanged = GMMapChrm1ZoomChanged
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
