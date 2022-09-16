object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'MainFrm'
  ClientHeight = 614
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
    Height = 491
    Align = alClient
    TabStop = True
    TabOrder = 0
  end
  object Panel2: TPanel
    Left = 708
    Top = 0
    Width = 301
    Height = 491
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
      Height = 424
      ActivePage = tsMapOptions
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
          Value = 50
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
        object lBackgroundColor: TLabel
          Left = 16
          Top = 16
          Width = 93
          Height = 15
          Caption = 'BackgroundColor'
        end
        object cbBackgroundColor: TColorBox
          Left = 115
          Top = 13
          Width = 105
          Height = 22
          TabOrder = 0
          OnChange = cbBackgroundColorChange
        end
        object gbCenter: TGroupBox
          Left = 3
          Top = 41
          Width = 285
          Height = 64
          Caption = 'Center'
          TabOrder = 1
          object lLat: TLabel
            Left = 16
            Top = 32
            Width = 16
            Height = 15
            Caption = 'Lat'
          end
          object lLng: TLabel
            Left = 149
            Top = 32
            Width = 20
            Height = 15
            Caption = 'Lng'
          end
          object eLat: TEdit
            Left = 43
            Top = 29
            Width = 94
            Height = 23
            TabOrder = 0
            OnChange = eLatChange
          end
          object eLng: TEdit
            Left = 176
            Top = 29
            Width = 94
            Height = 23
            TabOrder = 1
            OnChange = eLngChange
          end
        end
        object cbClickableIcons: TCheckBox
          Left = 8
          Top = 120
          Width = 97
          Height = 17
          Caption = 'ClickableIcons'
          TabOrder = 2
          OnClick = cbClickableIconsClick
        end
        object cbDisableDoubleClickZoom: TCheckBox
          Left = 120
          Top = 120
          Width = 168
          Height = 17
          Caption = 'DisableDoubleClickZoom'
          TabOrder = 3
          OnClick = cbDisableDoubleClickZoomClick
        end
        object pcObjects: TPageControl
          Left = 0
          Top = 195
          Width = 291
          Height = 199
          ActivePage = tsMapTypeControl
          Align = alBottom
          TabOrder = 4
          object tsFullScreenControl: TTabSheet
            Caption = 'FullScreen'
            object lFSPosition: TLabel
              Left = 16
              Top = 48
              Width = 43
              Height = 15
              Caption = 'Position'
            end
            object cbFullScreenControl: TCheckBox
              Left = 16
              Top = 16
              Width = 129
              Height = 17
              Caption = 'FullScreenControl'
              TabOrder = 0
              OnClick = cbFullScreenControlClick
            end
            object cbFSPosition: TComboBox
              Left = 73
              Top = 45
              Width = 105
              Height = 22
              Style = csOwnerDrawFixed
              TabOrder = 1
              OnChange = cbFSPositionChange
            end
          end
          object tsMapTypeControl: TTabSheet
            Caption = 'MapType'
            ImageIndex = 1
            object lMTPosition: TLabel
              Left = 8
              Top = 104
              Width = 43
              Height = 15
              Caption = 'Position'
            end
            object lMTStyle: TLabel
              Left = 8
              Top = 132
              Width = 25
              Height = 15
              Caption = 'Style'
            end
            object lMTIds: TLabel
              Left = 176
              Top = 72
              Width = 15
              Height = 15
              Caption = 'Ids'
            end
            object lMapTypeId: TLabel
              Left = 8
              Top = 24
              Width = 58
              Height = 15
              Caption = 'MapTypeId'
            end
            object cbMTPosition: TComboBox
              Left = 65
              Top = 101
              Width = 105
              Height = 22
              Style = csOwnerDrawFixed
              TabOrder = 0
              OnChange = cbMTPositionChange
            end
            object clbMTIds: TCheckListBox
              Left = 176
              Top = 88
              Width = 104
              Height = 65
              ItemHeight = 15
              TabOrder = 1
              OnClickCheck = clbMTIdsClickCheck
            end
            object cbMapTypeControl: TCheckBox
              Left = 8
              Top = 72
              Width = 129
              Height = 17
              Caption = 'MapTypeControl'
              TabOrder = 2
              OnClick = cbMapTypeControlClick
            end
            object cbMTStyle: TComboBox
              Left = 65
              Top = 129
              Width = 105
              Height = 22
              Style = csOwnerDrawFixed
              TabOrder = 3
              OnChange = cbMTStyleChange
            end
            object cbMapTypeId: TComboBox
              Left = 81
              Top = 21
              Width = 105
              Height = 22
              Style = csOwnerDrawFixed
              TabOrder = 4
              OnChange = cbMapTypeIdChange
            end
          end
          object tsRestriction: TTabSheet
            Caption = 'Restriction'
            ImageIndex = 2
            object cbREnabled: TCheckBox
              Left = 20
              Top = 16
              Width = 97
              Height = 17
              Caption = 'Enabled'
              TabOrder = 0
              OnClick = cbREnabledClick
            end
            object cbRStrictBounds: TCheckBox
              Left = 123
              Top = 16
              Width = 130
              Height = 17
              Caption = 'StrictBounds'
              TabOrder = 1
              OnClick = cbRStrictBoundsClick
            end
            object gbRNE: TGroupBox
              Left = 4
              Top = 37
              Width = 275
              Height = 64
              Caption = 'NE'
              TabOrder = 2
              object lRNELat: TLabel
                Left = 16
                Top = 32
                Width = 16
                Height = 15
                Caption = 'Lat'
              end
              object lRNELng: TLabel
                Left = 146
                Top = 32
                Width = 20
                Height = 15
                Caption = 'Lng'
              end
              object eRNELat: TEdit
                Left = 40
                Top = 29
                Width = 94
                Height = 23
                TabOrder = 0
                OnChange = eRNELatChange
              end
              object eRNELng: TEdit
                Left = 173
                Top = 29
                Width = 94
                Height = 23
                TabOrder = 1
                OnChange = eRNELngChange
              end
            end
            object gbRSW: TGroupBox
              Left = 4
              Top = 103
              Width = 275
              Height = 64
              Caption = 'SW'
              TabOrder = 3
              object lRSWLat: TLabel
                Left = 16
                Top = 32
                Width = 16
                Height = 15
                Caption = 'Lat'
              end
              object lRSWLng: TLabel
                Left = 146
                Top = 32
                Width = 20
                Height = 15
                Caption = 'Lng'
              end
              object eRSWLat: TEdit
                Left = 40
                Top = 29
                Width = 94
                Height = 23
                TabOrder = 0
                OnChange = eRSWLatChange
              end
              object eRSWLng: TEdit
                Left = 173
                Top = 29
                Width = 94
                Height = 23
                TabOrder = 1
                OnChange = eRSWLngChange
              end
            end
          end
          object tsRotateControl: TTabSheet
            Caption = 'Rotate'
            ImageIndex = 3
            object lRotPosition: TLabel
              Left = 24
              Top = 56
              Width = 43
              Height = 15
              Caption = 'Position'
            end
            object cbRotateControl: TCheckBox
              Left = 24
              Top = 24
              Width = 129
              Height = 17
              Caption = 'RotateControl'
              TabOrder = 0
              OnClick = cbRotateControlClick
            end
            object cbRotPosition: TComboBox
              Left = 81
              Top = 53
              Width = 105
              Height = 22
              Style = csOwnerDrawFixed
              TabOrder = 1
              OnChange = cbRotPositionChange
            end
          end
          object tsScaleControl: TTabSheet
            Caption = 'Scale'
            ImageIndex = 4
            object lSStyle: TLabel
              Left = 24
              Top = 60
              Width = 25
              Height = 15
              Caption = 'Style'
            end
            object cbScaleControl: TCheckBox
              Left = 24
              Top = 24
              Width = 129
              Height = 17
              Caption = 'ScaleControl'
              TabOrder = 0
              OnClick = cbScaleControlClick
            end
            object cbSStyle: TComboBox
              Left = 81
              Top = 57
              Width = 105
              Height = 22
              Style = csOwnerDrawFixed
              TabOrder = 1
              OnChange = cbSStyleChange
            end
          end
          object tsStreetViewControl: TTabSheet
            Caption = 'StreetView'
            ImageIndex = 5
            object lSVPosition: TLabel
              Left = 32
              Top = 64
              Width = 43
              Height = 15
              Caption = 'Position'
            end
            object cbStreetViewControl: TCheckBox
              Left = 32
              Top = 32
              Width = 129
              Height = 17
              Caption = 'StreetViewControl'
              TabOrder = 0
              OnClick = cbStreetViewControlClick
            end
            object cbSVPosition: TComboBox
              Left = 89
              Top = 61
              Width = 105
              Height = 22
              Style = csOwnerDrawFixed
              TabOrder = 1
              OnChange = cbSVPositionChange
            end
          end
          object tsZoomControl: TTabSheet
            Caption = 'Zoom'
            ImageIndex = 6
            object lZPosition: TLabel
              Left = 32
              Top = 80
              Width = 43
              Height = 15
              Caption = 'Position'
            end
            object lZoom: TLabel
              Left = 32
              Top = 24
              Width = 32
              Height = 15
              Caption = 'Zoom'
            end
            object lMaxZoom: TLabel
              Left = 8
              Top = 136
              Width = 55
              Height = 15
              Caption = 'MaxZoom'
            end
            object lMinZoom: TLabel
              Left = 143
              Top = 136
              Width = 53
              Height = 15
              Caption = 'MinZoom'
            end
            object cbZoomControl: TCheckBox
              Left = 32
              Top = 56
              Width = 129
              Height = 17
              Caption = 'ZoomControl'
              TabOrder = 0
              OnClick = cbZoomControlClick
            end
            object cbZPosition: TComboBox
              Left = 89
              Top = 77
              Width = 105
              Height = 22
              Style = csOwnerDrawFixed
              TabOrder = 1
              OnChange = cbZPositionChange
            end
            object eZoom: TEdit
              Left = 75
              Top = 21
              Width = 94
              Height = 23
              TabOrder = 2
              OnChange = eZoomChange
            end
            object eMaxZoom: TEdit
              Left = 75
              Top = 133
              Width = 54
              Height = 23
              TabOrder = 3
              OnChange = eMaxZoomChange
            end
            object eMinZoom: TEdit
              Left = 210
              Top = 133
              Width = 55
              Height = 23
              TabOrder = 4
              OnChange = eMinZoomChange
            end
          end
        end
        object cbNoClear: TCheckBox
          Left = 8
          Top = 143
          Width = 97
          Height = 17
          Caption = 'NoClear'
          TabOrder = 5
          OnClick = cbNoClearClick
        end
        object cbKeyboardShortcuts: TCheckBox
          Left = 120
          Top = 143
          Width = 137
          Height = 17
          Caption = 'KeyboardShortcuts'
          TabOrder = 6
          OnClick = cbKeyboardShortcutsClick
        end
        object cbIsFractionalZoomEnabled: TCheckBox
          Left = 8
          Top = 166
          Width = 161
          Height = 17
          Caption = 'IsFractionalZoomEnabled'
          TabOrder = 7
          OnClick = cbIsFractionalZoomEnabledClick
        end
      end
    end
  end
  object mEvents: TMemo
    Left = 0
    Top = 491
    Width = 1009
    Height = 123
    Align = alBottom
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object GMMapChrm1: TGMMapChrm
    Browser = Chromium1
    MapOptions.BackgroundColor = clLime
    MapOptions.Center.Lat = 42.539899000000000000
    MapOptions.Center.Lng = 1.578505000000000000
    MapOptions.ClickableIcons = True
    MapOptions.FullScreenControl = False
    MapOptions.GestureHandling = ghAuto
    MapOptions.IsFractionalZoomEnabled = True
    MapOptions.MapTypeControlOptions.MapTypeIds = [mtHYBRID, mtROADMAP, mtTERRAIN]
    MapOptions.MapTypeControlOptions.Style = mtcDROPDOWN_MENU
    MapOptions.Restriction.StrictBounds = False
    MapOptions.Restriction.Enabled = False
    MapOptions.Zoom = 10
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
