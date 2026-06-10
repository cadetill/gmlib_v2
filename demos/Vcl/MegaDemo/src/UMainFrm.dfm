object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'GMLib VCL MegaDemo'
  ClientHeight = 713
  ClientWidth = 1235
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  WindowState = wsMaximized
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 953
    Top = 235
    Height = 478
    Align = alRight
    ExplicitLeft = 624
    ExplicitTop = 328
    ExplicitHeight = 100
  end
  object EdgeBrowser1: TEdgeBrowser
    Left = 0
    Top = 235
    Width = 953
    Height = 478
    Align = alClient
    TabOrder = 0
    AllowSingleSignOnUsingOSPrimaryAccount = False
    TargetCompatibleBrowserVersion = '137.0.3296.44'
    UserDataFolder = '%LOCALAPPDATA%\bds.exe.WebView2'
  end
  object pcSupplier: TPageControl
    Left = 0
    Top = 0
    Width = 1235
    Height = 235
    ActivePage = tsGM
    Align = alTop
    TabOrder = 1
    object tsGM: TTabSheet
      Caption = 'Google Maps'
      object pcGMOptions: TPageControl
        Left = 0
        Top = 0
        Width = 1227
        Height = 265
        ActivePage = tsOverlays
        Align = alTop
        TabOrder = 0
        object tsMap: TTabSheet
          Caption = 'Map'
          object pMapTop: TPanel
            Left = 0
            Top = 0
            Width = 1219
            Height = 37
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            object lAPIKey: TLabel
              Left = 20
              Top = 9
              Width = 43
              Height = 15
              Caption = 'API Key:'
            end
            object MapIdLabel: TLabel
              Left = 380
              Top = 9
              Width = 41
              Height = 15
              Caption = 'Map ID:'
            end
            object eAPIKey: TEdit
              Left = 80
              Top = 6
              Width = 280
              Height = 23
              TabOrder = 0
            end
            object eMapId: TEdit
              Left = 430
              Top = 6
              Width = 150
              Height = 23
              TabOrder = 1
              Text = 'DEMO_MAP_ID'
            end
            object bApplyOptions: TButton
              Left = 600
              Top = 4
              Width = 100
              Height = 25
              Caption = 'Apply Options'
              TabOrder = 2
              OnClick = bApplyOptionsClick
            end
            object bActivate: TButton
              Left = 712
              Top = 4
              Width = 100
              Height = 25
              Caption = 'Activate'
              TabOrder = 3
              OnClick = bActivateClick
            end
          end
          object pcMapOptions: TPageControl
            Left = 0
            Top = 37
            Width = 1219
            Height = 198
            ActivePage = tsGMGeneral
            Align = alClient
            TabOrder = 1
            object tsGMGeneral: TTabSheet
              Caption = 'General'
              object lMapTypeId: TLabel
                Left = 23
                Top = 6
                Width = 62
                Height = 15
                Caption = 'MapTypeId:'
              end
              object lColorScheme: TLabel
                Left = 133
                Top = 6
                Width = 74
                Height = 15
                Caption = 'ColorScheme:'
              end
              object lRenderType: TLabel
                Left = 243
                Top = 6
                Width = 65
                Height = 15
                Caption = 'RenderType:'
              end
              object lZoom: TLabel
                Left = 353
                Top = 6
                Width = 35
                Height = 15
                Caption = 'Zoom:'
              end
              object lCenter: TLabel
                Left = 453
                Top = 6
                Width = 38
                Height = 15
                Caption = 'Center:'
              end
              object lSep: TLabel
                Left = 475
                Top = 26
                Width = 5
                Height = 15
                Caption = '-'
              end
              object lGestureHandling: TLabel
                Left = 563
                Top = 54
                Width = 92
                Height = 15
                Caption = 'GestureHandling:'
              end
              object HeadingLabel: TLabel
                Left = 563
                Top = 6
                Width = 48
                Height = 15
                Caption = 'Heading:'
              end
              object TiltLabel: TLabel
                Left = 636
                Top = 6
                Width = 20
                Height = 15
                Caption = 'Tilt:'
              end
              object lBackGroundColor: TLabel
                Left = 23
                Top = 54
                Width = 94
                Height = 15
                Caption = 'BackGroundColor'
              end
              object lMaxZoom: TLabel
                Left = 353
                Top = 57
                Width = 54
                Height = 15
                Caption = 'MaxZoom'
              end
              object lMinZoom: TLabel
                Left = 418
                Top = 57
                Width = 53
                Height = 15
                Caption = 'MinZoom'
              end
              object lControlSize: TLabel
                Left = 692
                Top = 6
                Width = 60
                Height = 15
                Caption = 'ControlSize'
              end
              object cbMapTypeId: TComboBox
                Left = 23
                Top = 23
                Width = 100
                Height = 23
                Style = csDropDownList
                ItemIndex = 0
                TabOrder = 0
                Text = 'Roadmap'
                Items.Strings = (
                  'Roadmap'
                  'Satellite'
                  'Hybrid'
                  'Terrain')
              end
              object cbColorScheme: TComboBox
                Left = 133
                Top = 23
                Width = 100
                Height = 23
                Style = csDropDownList
                ItemIndex = 0
                TabOrder = 1
                Text = 'Light'
                Items.Strings = (
                  'Light'
                  'Dark'
                  'Follow')
              end
              object cbRenderType: TComboBox
                Left = 243
                Top = 23
                Width = 80
                Height = 23
                Style = csDropDownList
                ItemIndex = 0
                TabOrder = 2
                Text = 'Raster'
                Items.Strings = (
                  'Raster'
                  'Vector')
              end
              object eZoom: TEdit
                Left = 353
                Top = 23
                Width = 51
                Height = 23
                TabOrder = 3
                Text = '12'
              end
              object eLat: TEdit
                Left = 421
                Top = 23
                Width = 51
                Height = 23
                TabOrder = 4
                Text = '41.3874'
              end
              object eLng: TEdit
                Left = 483
                Top = 23
                Width = 51
                Height = 23
                TabOrder = 5
                Text = '2.1686'
              end
              object cbGestureHandling: TComboBox
                Left = 563
                Top = 74
                Width = 93
                Height = 23
                Style = csDropDownList
                ItemIndex = 0
                TabOrder = 6
                Text = 'ghAuto'
                Items.Strings = (
                  'ghAuto'
                  'ghCooperative'
                  'ghGreedy'
                  'ghNone')
              end
              object eHeading: TEdit
                Left = 563
                Top = 23
                Width = 51
                Height = 23
                TabOrder = 7
              end
              object eTilt: TEdit
                Left = 636
                Top = 23
                Width = 45
                Height = 23
                TabOrder = 8
              end
              object cbClickableIcons: TCheckBox
                Left = 763
                Top = 7
                Width = 161
                Height = 15
                Caption = 'ClickableIcons'
                TabOrder = 9
              end
              object cbDisableDefaultUI: TCheckBox
                Left = 763
                Top = 28
                Width = 161
                Height = 15
                Caption = 'DisableDefaultUI'
                TabOrder = 10
              end
              object cbDisableDoubleClickZoom: TCheckBox
                Left = 763
                Top = 49
                Width = 161
                Height = 15
                Caption = 'DisableDoubleClickZoom'
                TabOrder = 11
              end
              object cbHeadingInteractionEnabled: TCheckBox
                Left = 763
                Top = 70
                Width = 169
                Height = 15
                Caption = 'HeadingInteractionEnabled'
                TabOrder = 12
              end
              object cbKeyboardShortcuts: TCheckBox
                Left = 941
                Top = 28
                Width = 169
                Height = 15
                Caption = 'KeyboardShortcuts'
                TabOrder = 13
              end
              object cbIsFractionalZoomEnabled: TCheckBox
                Left = 941
                Top = 7
                Width = 169
                Height = 15
                Caption = 'IsFractionalZoomEnabled'
                TabOrder = 14
              end
              object cbBackGroundColor: TColorBox
                Left = 23
                Top = 74
                Width = 100
                Height = 22
                TabOrder = 15
              end
              object eMaxZoom: TEdit
                Left = 353
                Top = 74
                Width = 51
                Height = 23
                TabOrder = 16
              end
              object eMinZoom: TEdit
                Left = 418
                Top = 73
                Width = 51
                Height = 23
                TabOrder = 17
              end
              object eControlSize: TEdit
                Left = 692
                Top = 23
                Width = 45
                Height = 23
                TabOrder = 18
              end
              object cbNoClear: TCheckBox
                Left = 941
                Top = 49
                Width = 169
                Height = 15
                Caption = 'NoClear'
                TabOrder = 19
              end
              object cbScrollwheel: TCheckBox
                Left = 941
                Top = 70
                Width = 169
                Height = 15
                Caption = 'Scrollwheel'
                TabOrder = 20
              end
              object cbTiltInteractionEnabled: TCheckBox
                Left = 941
                Top = 88
                Width = 169
                Height = 15
                Caption = 'TiltInteractionEnabled'
                TabOrder = 21
              end
            end
            object tsControls: TTabSheet
              Caption = 'Controls'
              ImageIndex = 1
              object cbCameraControl: TCheckBox
                Left = 24
                Top = 14
                Width = 107
                Height = 15
                Caption = 'CameraControl'
                TabOrder = 0
              end
              object cbFullscreenControl: TCheckBox
                Left = 173
                Top = 14
                Width = 122
                Height = 15
                Caption = 'FullscreenControl'
                TabOrder = 1
              end
              object cbFullscreenPosition: TComboBox
                Left = 173
                Top = 33
                Width = 143
                Height = 23
                Style = csDropDownList
                ItemIndex = 20
                TabOrder = 2
                Text = 'cpRightTop'
                Items.Strings = (
                  'cpBlockEndInlineCenter'
                  'cpBlockEndInlineEnd'
                  'cpBlockEndInlineStart'
                  'cpBlockStartInlineCenter'
                  'cpBlockStartInlineEnd'
                  'cpBlockStartInlineStart'
                  'cpBottomCenter'
                  'cpBottomLeft'
                  'cpBottomRight'
                  'cpInlineEndBlockCenter'
                  'cpInlineEndBlockEnd'
                  'cpInlineEndBlockStart'
                  'cpInlineStartBlockCenter'
                  'cpInlineStartBlockEnd'
                  'cpInlineStartBlockStart'
                  'cpLeftBottom'
                  'cpLeftCenter'
                  'cpLeftTop'
                  'cpRightBottom'
                  'cpRightCenter'
                  'cpRightTop'
                  'cpTopCenter'
                  'cpTopLeft'
                  'cpTopRight')
              end
              object cbCameraPosition: TComboBox
                Left = 24
                Top = 34
                Width = 143
                Height = 23
                Style = csDropDownList
                ItemIndex = 9
                TabOrder = 3
                Text = 'cpInlineEndBlockCenter'
                Items.Strings = (
                  'cpBlockEndInlineCenter'
                  'cpBlockEndInlineEnd'
                  'cpBlockEndInlineStart'
                  'cpBlockStartInlineCenter'
                  'cpBlockStartInlineEnd'
                  'cpBlockStartInlineStart'
                  'cpBottomCenter'
                  'cpBottomLeft'
                  'cpBottomRight'
                  'cpInlineEndBlockCenter'
                  'cpInlineEndBlockEnd'
                  'cpInlineEndBlockStart'
                  'cpInlineStartBlockCenter'
                  'cpInlineStartBlockEnd'
                  'cpInlineStartBlockStart'
                  'cpLeftBottom'
                  'cpLeftCenter'
                  'cpLeftTop'
                  'cpRightBottom'
                  'cpRightCenter'
                  'cpRightTop'
                  'cpTopCenter'
                  'cpTopLeft'
                  'cpTopRight')
              end
              object cbMapTypeControl: TCheckBox
                Left = 322
                Top = 14
                Width = 122
                Height = 15
                Caption = 'MapTypeControl'
                TabOrder = 4
              end
              object cbMapTypePosition: TComboBox
                Left = 322
                Top = 33
                Width = 143
                Height = 23
                Style = csDropDownList
                ItemIndex = 20
                TabOrder = 5
                Text = 'cpRightTop'
                Items.Strings = (
                  'cpBlockEndInlineCenter'
                  'cpBlockEndInlineEnd'
                  'cpBlockEndInlineStart'
                  'cpBlockStartInlineCenter'
                  'cpBlockStartInlineEnd'
                  'cpBlockStartInlineStart'
                  'cpBottomCenter'
                  'cpBottomLeft'
                  'cpBottomRight'
                  'cpInlineEndBlockCenter'
                  'cpInlineEndBlockEnd'
                  'cpInlineEndBlockStart'
                  'cpInlineStartBlockCenter'
                  'cpInlineStartBlockEnd'
                  'cpInlineStartBlockStart'
                  'cpLeftBottom'
                  'cpLeftCenter'
                  'cpLeftTop'
                  'cpRightBottom'
                  'cpRightCenter'
                  'cpRightTop'
                  'cpTopCenter'
                  'cpTopLeft'
                  'cpTopRight')
              end
              object cbMapTypeStyle: TComboBox
                Left = 322
                Top = 62
                Width = 143
                Height = 23
                Style = csDropDownList
                ItemIndex = 0
                TabOrder = 6
                Text = 'mtcsDefault'
                Items.Strings = (
                  'mtcsDefault'
                  'mtcsDropdownMenu'
                  'mtcsHorizontalBar')
              end
              object clbMapTypeIds: TCheckListBox
                Left = 471
                Top = 12
                Width = 105
                Height = 73
                ItemHeight = 17
                Items.Strings = (
                  'mtRoadmap'
                  'mtSatellite'
                  'mtHybrid'
                  'mtTerrain')
                TabOrder = 7
              end
              object cbRotateControl: TCheckBox
                Left = 596
                Top = 14
                Width = 122
                Height = 15
                Caption = 'RotateControl'
                TabOrder = 8
              end
              object cbRotatePosition: TComboBox
                Left = 596
                Top = 33
                Width = 143
                Height = 23
                Style = csDropDownList
                ItemIndex = 22
                TabOrder = 9
                Text = 'cpTopLeft'
                Items.Strings = (
                  'cpBlockEndInlineCenter'
                  'cpBlockEndInlineEnd'
                  'cpBlockEndInlineStart'
                  'cpBlockStartInlineCenter'
                  'cpBlockStartInlineEnd'
                  'cpBlockStartInlineStart'
                  'cpBottomCenter'
                  'cpBottomLeft'
                  'cpBottomRight'
                  'cpInlineEndBlockCenter'
                  'cpInlineEndBlockEnd'
                  'cpInlineEndBlockStart'
                  'cpInlineStartBlockCenter'
                  'cpInlineStartBlockEnd'
                  'cpInlineStartBlockStart'
                  'cpLeftBottom'
                  'cpLeftCenter'
                  'cpLeftTop'
                  'cpRightBottom'
                  'cpRightCenter'
                  'cpRightTop'
                  'cpTopCenter'
                  'cpTopLeft'
                  'cpTopRight')
              end
              object cbScaleControl: TCheckBox
                Left = 745
                Top = 14
                Width = 122
                Height = 15
                Caption = 'ScaleControl'
                TabOrder = 10
              end
              object cbScaleStyle: TComboBox
                Left = 745
                Top = 33
                Width = 143
                Height = 23
                Style = csDropDownList
                ItemIndex = 0
                TabOrder = 11
                Text = 'scsDefault'
                Items.Strings = (
                  'scsDefault')
              end
              object cbStreetViewControl: TCheckBox
                Left = 894
                Top = 14
                Width = 122
                Height = 15
                Caption = 'StreetViewControl'
                TabOrder = 12
              end
              object cbStreetViewPosition: TComboBox
                Left = 894
                Top = 33
                Width = 143
                Height = 23
                Style = csDropDownList
                ItemIndex = 22
                TabOrder = 13
                Text = 'cpTopLeft'
                Items.Strings = (
                  'cpBlockEndInlineCenter'
                  'cpBlockEndInlineEnd'
                  'cpBlockEndInlineStart'
                  'cpBlockStartInlineCenter'
                  'cpBlockStartInlineEnd'
                  'cpBlockStartInlineStart'
                  'cpBottomCenter'
                  'cpBottomLeft'
                  'cpBottomRight'
                  'cpInlineEndBlockCenter'
                  'cpInlineEndBlockEnd'
                  'cpInlineEndBlockStart'
                  'cpInlineStartBlockCenter'
                  'cpInlineStartBlockEnd'
                  'cpInlineStartBlockStart'
                  'cpLeftBottom'
                  'cpLeftCenter'
                  'cpLeftTop'
                  'cpRightBottom'
                  'cpRightCenter'
                  'cpRightTop'
                  'cpTopCenter'
                  'cpTopLeft'
                  'cpTopRight')
              end
              object cbZoomControl: TCheckBox
                Left = 894
                Top = 62
                Width = 122
                Height = 15
                Caption = 'ZoomControl'
                TabOrder = 14
              end
              object cbZoomPosition: TComboBox
                Left = 894
                Top = 80
                Width = 143
                Height = 23
                Style = csDropDownList
                ItemIndex = 22
                TabOrder = 15
                Text = 'cpTopLeft'
                Items.Strings = (
                  'cpBlockEndInlineCenter'
                  'cpBlockEndInlineEnd'
                  'cpBlockEndInlineStart'
                  'cpBlockStartInlineCenter'
                  'cpBlockStartInlineEnd'
                  'cpBlockStartInlineStart'
                  'cpBottomCenter'
                  'cpBottomLeft'
                  'cpBottomRight'
                  'cpInlineEndBlockCenter'
                  'cpInlineEndBlockEnd'
                  'cpInlineEndBlockStart'
                  'cpInlineStartBlockCenter'
                  'cpInlineStartBlockEnd'
                  'cpInlineStartBlockStart'
                  'cpLeftBottom'
                  'cpLeftCenter'
                  'cpLeftTop'
                  'cpRightBottom'
                  'cpRightCenter'
                  'cpRightTop'
                  'cpTopCenter'
                  'cpTopLeft'
                  'cpTopRight')
              end
            end
          end
        end
        object tsMarkers: TTabSheet
          Caption = 'Markers'
          DesignSize = (
            1219
            235)
          object lMarkerLat: TLabel
            Left = 308
            Top = 8
            Width = 19
            Height = 15
            Caption = 'Lat:'
          end
          object lMarkerLng: TLabel
            Left = 394
            Top = 8
            Width = 23
            Height = 15
            Caption = 'Lng:'
          end
          object lMarkerTitle: TLabel
            Left = 494
            Top = 8
            Width = 26
            Height = 15
            Caption = 'Title:'
          end
          object lMarkerContentMode: TLabel
            Left = 494
            Top = 110
            Width = 77
            Height = 15
            Caption = 'ContentMode:'
          end
          object lMarkerCollision: TLabel
            Left = 494
            Top = 56
            Width = 49
            Height = 15
            Caption = 'Collision:'
          end
          object lbMarkers: TListBox
            Left = 8
            Top = 8
            Width = 200
            Height = 163
            ItemHeight = 15
            TabOrder = 0
            OnClick = lbMarkersClick
          end
          object bAddMarker: TButton
            Left = 214
            Top = 8
            Width = 75
            Height = 25
            Caption = 'Add'
            TabOrder = 1
            OnClick = bAddMarkerClick
          end
          object bDeleteMarker: TButton
            Left = 214
            Top = 39
            Width = 75
            Height = 25
            Caption = 'Delete'
            TabOrder = 2
            OnClick = bDeleteMarkerClick
          end
          object bClearMarkers: TButton
            Left = 214
            Top = 70
            Width = 75
            Height = 25
            Caption = 'Clear'
            TabOrder = 3
            OnClick = bClearMarkersClick
          end
          object bLoadMarkersCsv: TButton
            Left = 413
            Top = 84
            Width = 75
            Height = 25
            Caption = 'Load CSV'
            TabOrder = 4
            OnClick = bLoadMarkersCsvClick
          end
          object bLoadMarkersSample: TButton
            Left = 413
            Top = 115
            Width = 75
            Height = 25
            Caption = 'Sample CSV'
            TabOrder = 5
            OnClick = bLoadMarkersSampleClick
          end
          object eMarkerLat: TEdit
            Left = 308
            Top = 26
            Width = 80
            Height = 23
            TabOrder = 6
            Text = '41.3874'
          end
          object eMarkerLng: TEdit
            Left = 394
            Top = 26
            Width = 80
            Height = 23
            TabOrder = 7
            Text = '2.1686'
          end
          object eMarkerTitle: TEdit
            Left = 494
            Top = 26
            Width = 160
            Height = 23
            TabOrder = 8
          end
          object cbMarkerDraggable: TCheckBox
            Left = 308
            Top = 75
            Width = 80
            Height = 15
            Caption = 'Draggable'
            TabOrder = 9
          end
          object cbMarkerVisible: TCheckBox
            Left = 308
            Top = 96
            Width = 60
            Height = 15
            Caption = 'Visible'
            Checked = True
            State = cbChecked
            TabOrder = 10
          end
          object cbMarkerClickable: TCheckBox
            Left = 308
            Top = 117
            Width = 75
            Height = 15
            Caption = 'Clickable'
            Checked = True
            State = cbChecked
            TabOrder = 11
          end
          object cbMarkerContentMode: TComboBox
            Left = 494
            Top = 128
            Width = 123
            Height = 23
            Style = csDropDownList
            ItemIndex = 0
            TabOrder = 12
            Text = 'mcmDefault'
            Items.Strings = (
              'mcmDefault'
              'mcmPin'
              'mcmHtml'
              'mcmLabel')
          end
          object cbMarkerCollision: TComboBox
            Left = 494
            Top = 74
            Width = 160
            Height = 23
            Style = csDropDownList
            ItemIndex = 0
            TabOrder = 16
            Text = 'cbRequired'
            Items.Strings = (
              'cbRequired'
              'cbOptionalAndHidesLowerPriority'
              'cbRequiredAndHidesOptional')
          end
          object pcMakerContent: TPageControl
            Left = 664
            Top = 8
            Width = 552
            Height = 163
            ActivePage = tsPin
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 17
            object tsHTML: TTabSheet
              Caption = 'mcmHtml'
              DesignSize = (
                544
                133)
              object lMarkerHtml: TLabel
                Left = 32
                Top = 9
                Width = 36
                Height = 15
                Caption = 'HTML:'
              end
              object mMarkerHtml: TMemo
                Left = 32
                Top = 30
                Width = 509
                Height = 100
                Anchors = [akLeft, akTop, akRight]
                TabOrder = 0
              end
            end
            object tsLabel: TTabSheet
              Caption = 'mcmLabel'
              ImageIndex = 1
              object lMarkerLabelText: TLabel
                Left = 12
                Top = 9
                Width = 24
                Height = 15
                Caption = 'Text:'
              end
              object lMarkerLabelTextColor: TLabel
                Left = 12
                Top = 57
                Width = 53
                Height = 15
                Caption = 'TextColor:'
              end
              object lMarkerLabelBackgroundColor: TLabel
                Left = 170
                Top = 9
                Width = 96
                Height = 15
                Caption = 'BackgroundColor:'
              end
              object lMarkerLabelBorderColor: TLabel
                Left = 170
                Top = 57
                Width = 67
                Height = 15
                Caption = 'BorderColor:'
              end
              object lMarkerLabelCornerRadius: TLabel
                Left = 278
                Top = 9
                Width = 71
                Height = 15
                Caption = 'CornerRadius'
              end
              object lMarkerLabelFontSize: TLabel
                Left = 276
                Top = 57
                Width = 44
                Height = 15
                Caption = 'FontSize'
              end
              object lMarkerLabelPaddingHorizontal: TLabel
                Left = 358
                Top = 9
                Width = 99
                Height = 15
                Caption = 'PaddingHorizontal'
              end
              object lMarkerLabelPaddingVertical: TLabel
                Left = 358
                Top = 57
                Width = 82
                Height = 15
                Caption = 'PaddingVertical'
              end
              object eMarkerLabelText: TEdit
                Left = 12
                Top = 26
                Width = 150
                Height = 23
                TabOrder = 0
              end
              object cbMarkerLabelTextColor: TColorBox
                Left = 12
                Top = 74
                Width = 100
                Height = 22
                TabOrder = 1
              end
              object cbMarkerLabelBackgroundColor: TColorBox
                Left = 170
                Top = 26
                Width = 100
                Height = 22
                TabOrder = 2
              end
              object cbMarkerLabelBorderColor: TColorBox
                Left = 170
                Top = 74
                Width = 100
                Height = 22
                TabOrder = 3
              end
              object eMarkerLabelCornerRadius: TEdit
                Left = 278
                Top = 26
                Width = 51
                Height = 23
                TabOrder = 4
              end
              object eMarkerLabelFontSize: TEdit
                Left = 276
                Top = 74
                Width = 51
                Height = 23
                TabOrder = 5
              end
              object cbMarkerLabelFontBold: TCheckBox
                Left = 276
                Top = 110
                Width = 77
                Height = 15
                Caption = 'FontBold'
                Checked = True
                State = cbChecked
                TabOrder = 6
              end
              object eMarkerLabelPaddingHorizontal: TEdit
                Left = 358
                Top = 26
                Width = 51
                Height = 23
                TabOrder = 7
              end
              object eMarkerLabelPaddingVertical: TEdit
                Left = 358
                Top = 74
                Width = 51
                Height = 23
                TabOrder = 8
              end
            end
            object tsPin: TTabSheet
              Caption = 'mcmPin'
              ImageIndex = 2
              object lMarkerPinBackgroundColor: TLabel
                Left = 178
                Top = 17
                Width = 96
                Height = 15
                Caption = 'BackgroundColor:'
              end
              object lMarkerPinBorderColor: TLabel
                Left = 178
                Top = 65
                Width = 67
                Height = 15
                Caption = 'BorderColor:'
              end
              object lMarkerPinGlyphText: TLabel
                Left = 20
                Top = 17
                Width = 52
                Height = 15
                Caption = 'GlyphText'
              end
              object lMarkerPinGlyphColor: TLabel
                Left = 20
                Top = 65
                Width = 60
                Height = 15
                Caption = 'GlyphColor'
              end
              object lMarkerPinScale: TLabel
                Left = 300
                Top = 17
                Width = 27
                Height = 15
                Caption = 'Scale'
              end
              object cbMarkerPinBackgroundColor: TColorBox
                Left = 178
                Top = 34
                Width = 100
                Height = 22
                TabOrder = 0
              end
              object cbMarkerPinBorderColor: TColorBox
                Left = 178
                Top = 82
                Width = 100
                Height = 22
                TabOrder = 1
              end
              object eMarkerPinGlyphText: TEdit
                Left = 20
                Top = 34
                Width = 100
                Height = 23
                TabOrder = 2
              end
              object cbMarkerPinGlyphColor: TColorBox
                Left = 20
                Top = 82
                Width = 100
                Height = 22
                TabOrder = 3
              end
              object eMarkerPinScale: TEdit
                Left = 300
                Top = 34
                Width = 100
                Height = 23
                TabOrder = 4
              end
            end
          end
          object bUpdate: TButton
            Left = 214
            Top = 116
            Width = 75
            Height = 25
            Caption = 'Update'
            TabOrder = 13
            OnClick = bUpdateClick
          end
          object bZoomToMarker: TButton
            Left = 284
            Top = 147
            Width = 99
            Height = 25
            Caption = 'ZoomToMarker'
            TabOrder = 14
            OnClick = bZoomToMarkerClick
          end
          object bZoomToMarkers: TButton
            Left = 389
            Top = 146
            Width = 99
            Height = 25
            Caption = 'ZoomToMarkers'
            TabOrder = 15
            OnClick = bZoomToMarkersClick
          end
        end
        object tsOverlays: TTabSheet
          Caption = 'Overlays'
          object pcOverlays: TPageControl
            Left = 0
            Top = 0
            Width = 1219
            Height = 235
            ActivePage = tsPolyline
            Align = alClient
            TabOrder = 0
            object tsPolyline: TTabSheet
              Caption = 'Polyline'
              object lPolylinePath: TLabel
                Left = 272
                Top = 8
                Width = 27
                Height = 15
                Caption = 'Path:'
              end
              object lPolylineStrokeColor: TLabel
                Left = 482
                Top = 8
                Width = 65
                Height = 15
                Caption = 'StrokeColor:'
              end
              object lPolylineStrokeOpacity: TLabel
                Left = 578
                Top = 8
                Width = 77
                Height = 15
                Caption = 'StrokeOpacity:'
              end
              object lPolylineStrokeWeight: TLabel
                Left = 578
                Top = 55
                Width = 74
                Height = 15
                Caption = 'StrokeWeight:'
              end
              object lbPolylines: TListBox
                Left = 8
                Top = 8
                Width = 150
                Height = 130
                ItemHeight = 15
                TabOrder = 0
                OnClick = lbPolylinesClick
              end
              object bAddPolyline: TButton
                Left = 164
                Top = 8
                Width = 65
                Height = 25
                Caption = 'Add'
                TabOrder = 1
                OnClick = bAddPolylineClick
              end
              object bDeletePolyline: TButton
                Left = 164
                Top = 39
                Width = 65
                Height = 25
                Caption = 'Delete'
                TabOrder = 2
                OnClick = bDeletePolylineClick
              end
              object bClearPolylines: TButton
                Left = 164
                Top = 70
                Width = 65
                Height = 25
                Caption = 'Clear'
                TabOrder = 3
                OnClick = bClearPolylinesClick
              end
              object bUpdatePolyline: TButton
                Left = 164
                Top = 113
                Width = 65
                Height = 25
                Caption = 'Update'
                TabOrder = 4
                OnClick = bUpdatePolylineClick
              end
              object bLoadGpx: TButton
                Left = 862
                Top = 113
                Width = 65
                Height = 25
                Caption = 'Load GPX'
                TabOrder = 16
                OnClick = bLoadGpxClick
              end
              object mPolylinePath: TMemo
                Left = 272
                Top = 26
                Width = 200
                Height = 112
                TabOrder = 5
              end
              object cbPolylineStrokeColor: TColorBox
                Left = 482
                Top = 26
                Width = 80
                Height = 22
                TabOrder = 6
              end
              object ePolylineStrokeOpacity: TEdit
                Left = 578
                Top = 26
                Width = 60
                Height = 23
                TabOrder = 7
                Text = '1'
              end
              object ePolylineStrokeWeight: TEdit
                Left = 578
                Top = 73
                Width = 60
                Height = 23
                TabOrder = 8
                Text = '2'
              end
              object cbPolylineClickable: TCheckBox
                Left = 684
                Top = 8
                Width = 75
                Height = 15
                Caption = 'Clickable'
                Checked = True
                State = cbChecked
                TabOrder = 9
              end
              object cbPolylineDraggable: TCheckBox
                Left = 684
                Top = 30
                Width = 80
                Height = 15
                Caption = 'Draggable'
                TabOrder = 10
              end
              object cbPolylineEditable: TCheckBox
                Left = 684
                Top = 52
                Width = 70
                Height = 15
                Caption = 'Editable'
                TabOrder = 11
              end
              object cbPolylineGeodesic: TCheckBox
                Left = 684
                Top = 74
                Width = 65
                Height = 15
                Caption = 'Geodesic'
                TabOrder = 12
              end
              object cbPolylineVisible: TCheckBox
                Left = 684
                Top = 96
                Width = 60
                Height = 15
                Caption = 'Visible'
                Checked = True
                State = cbChecked
                TabOrder = 13
              end
              object bZoomToPolylines: TButton
                Left = 862
                Top = 47
                Width = 99
                Height = 25
                Caption = 'ZoomToPolylines'
                TabOrder = 14
                OnClick = bZoomToPolylinesClick
              end
              object bZoomToPolyline: TButton
                Left = 862
                Top = 4
                Width = 99
                Height = 25
                Caption = 'ZoomToPolyline'
                TabOrder = 15
                OnClick = bZoomToPolylineClick
              end
            end
            object tsPolygon: TTabSheet
              Caption = 'Polygon'
              ImageIndex = 1
              object lPolygonPath: TLabel
                Left = 280
                Top = 8
                Width = 27
                Height = 15
                Caption = 'Path:'
              end
              object lPolygonStrokeColor: TLabel
                Left = 506
                Top = 8
                Width = 65
                Height = 15
                Caption = 'StrokeColor:'
              end
              object lPolygonStrokeOpacity: TLabel
                Left = 506
                Top = 55
                Width = 77
                Height = 15
                Caption = 'StrokeOpacity:'
              end
              object lPolygonStrokeWeight: TLabel
                Left = 506
                Top = 102
                Width = 74
                Height = 15
                Caption = 'StrokeWeight:'
              end
              object lPolygonFillColor: TLabel
                Left = 596
                Top = 8
                Width = 47
                Height = 15
                Caption = 'FillColor:'
              end
              object lPolygonFillOpacity: TLabel
                Left = 596
                Top = 55
                Width = 59
                Height = 15
                Caption = 'FillOpacity:'
              end
              object lbPolygons: TListBox
                Left = 8
                Top = 8
                Width = 150
                Height = 130
                ItemHeight = 15
                TabOrder = 0
                OnClick = lbPolygonsClick
              end
              object bAddPolygon: TButton
                Left = 164
                Top = 8
                Width = 65
                Height = 25
                Caption = 'Add'
                TabOrder = 1
                OnClick = bAddPolygonClick
              end
              object bDeletePolygon: TButton
                Left = 164
                Top = 39
                Width = 65
                Height = 25
                Caption = 'Delete'
                TabOrder = 2
                OnClick = bDeletePolygonClick
              end
              object bClearPolygons: TButton
                Left = 164
                Top = 70
                Width = 65
                Height = 25
                Caption = 'Clear'
                TabOrder = 3
                OnClick = bClearPolygonsClick
              end
              object bUpdatePolygon: TButton
                Left = 164
                Top = 113
                Width = 65
                Height = 25
                Caption = 'Update'
                TabOrder = 4
                OnClick = bUpdatePolygonClick
              end
              object bZoomToPolygon: TButton
                Left = 892
                Top = 8
                Width = 101
                Height = 25
                Caption = 'ZoomToPolygon'
                TabOrder = 5
                OnClick = bZoomToPolygonClick
              end
              object mPolygonPath: TMemo
                Left = 280
                Top = 26
                Width = 200
                Height = 112
                TabOrder = 6
              end
              object cbPolygonStrokeColor: TColorBox
                Left = 506
                Top = 26
                Width = 80
                Height = 22
                TabOrder = 7
              end
              object ePolygonStrokeOpacity: TEdit
                Left = 506
                Top = 73
                Width = 60
                Height = 23
                TabOrder = 8
                Text = '1'
              end
              object ePolygonStrokeWeight: TEdit
                Left = 506
                Top = 120
                Width = 60
                Height = 23
                TabOrder = 9
                Text = '2'
              end
              object cbPolygonFillColor: TColorBox
                Left = 596
                Top = 26
                Width = 80
                Height = 22
                TabOrder = 10
              end
              object ePolygonFillOpacity: TEdit
                Left = 596
                Top = 73
                Width = 60
                Height = 23
                TabOrder = 11
                Text = '0.3'
              end
              object cbPolygonClickable: TCheckBox
                Left = 706
                Top = 73
                Width = 75
                Height = 15
                Caption = 'Clickable'
                Checked = True
                State = cbChecked
                TabOrder = 12
              end
              object cbPolygonDraggable: TCheckBox
                Left = 706
                Top = 95
                Width = 80
                Height = 15
                Caption = 'Draggable'
                TabOrder = 13
              end
              object cbPolygonEditable: TCheckBox
                Left = 706
                Top = 8
                Width = 70
                Height = 15
                Caption = 'Editable'
                TabOrder = 14
              end
              object cbPolygonGeodesic: TCheckBox
                Left = 706
                Top = 30
                Width = 65
                Height = 15
                Caption = 'Geodesic'
                TabOrder = 15
              end
              object cbPolygonVisible: TCheckBox
                Left = 706
                Top = 52
                Width = 60
                Height = 15
                Caption = 'Visible'
                Checked = True
                State = cbChecked
                TabOrder = 16
              end
              object bZoomToPolygons: TButton
                Left = 892
                Top = 47
                Width = 101
                Height = 25
                Caption = 'ZoomToPolygons'
                TabOrder = 17
                OnClick = bZoomToPolygonsClick
              end
            end
            object tsRectangle: TTabSheet
              Caption = 'Rectangle'
              ImageIndex = 2
              object lRectangleNorth: TLabel
                Left = 280
                Top = 8
                Width = 34
                Height = 15
                Caption = 'North:'
              end
              object lRectangleSouth: TLabel
                Left = 370
                Top = 8
                Width = 34
                Height = 15
                Caption = 'South:'
              end
              object lRectangleEast: TLabel
                Left = 280
                Top = 55
                Width = 24
                Height = 15
                Caption = 'East:'
              end
              object lRectangleWest: TLabel
                Left = 370
                Top = 55
                Width = 29
                Height = 15
                Caption = 'West:'
              end
              object lRectangleStrokeColor: TLabel
                Left = 484
                Top = 8
                Width = 65
                Height = 15
                Caption = 'StrokeColor:'
              end
              object lRectangleStrokeOpacity: TLabel
                Left = 484
                Top = 55
                Width = 77
                Height = 15
                Caption = 'StrokeOpacity:'
              end
              object lRectangleStrokeWeight: TLabel
                Left = 484
                Top = 102
                Width = 74
                Height = 15
                Caption = 'StrokeWeight:'
              end
              object lRectangleFillColor: TLabel
                Left = 574
                Top = 8
                Width = 47
                Height = 15
                Caption = 'FillColor:'
              end
              object lRectangleFillOpacity: TLabel
                Left = 574
                Top = 55
                Width = 59
                Height = 15
                Caption = 'FillOpacity:'
              end
              object lbRectangles: TListBox
                Left = 8
                Top = 8
                Width = 150
                Height = 130
                ItemHeight = 15
                TabOrder = 0
                OnClick = lbRectanglesClick
              end
              object bAddRectangle: TButton
                Left = 164
                Top = 8
                Width = 65
                Height = 25
                Caption = 'Add'
                TabOrder = 1
                OnClick = bAddRectangleClick
              end
              object bDeleteRectangle: TButton
                Left = 164
                Top = 39
                Width = 65
                Height = 25
                Caption = 'Delete'
                TabOrder = 2
                OnClick = bDeleteRectangleClick
              end
              object bClearRectangles: TButton
                Left = 164
                Top = 70
                Width = 65
                Height = 25
                Caption = 'Clear'
                TabOrder = 3
                OnClick = bClearRectanglesClick
              end
              object bUpdateRectangle: TButton
                Left = 164
                Top = 113
                Width = 65
                Height = 25
                Caption = 'Update'
                TabOrder = 4
                OnClick = bUpdateRectangleClick
              end
              object bZoomToRectangle: TButton
                Left = 868
                Top = 8
                Width = 117
                Height = 25
                Caption = 'ZoomToRectangle'
                TabOrder = 5
                OnClick = bZoomToRectangleClick
              end
              object eRectangleNorth: TEdit
                Left = 280
                Top = 26
                Width = 80
                Height = 23
                TabOrder = 6
                Text = '41.39'
              end
              object eRectangleSouth: TEdit
                Left = 370
                Top = 26
                Width = 80
                Height = 23
                TabOrder = 7
                Text = '41.38'
              end
              object eRectangleEast: TEdit
                Left = 280
                Top = 73
                Width = 80
                Height = 23
                TabOrder = 8
                Text = '2.17'
              end
              object eRectangleWest: TEdit
                Left = 370
                Top = 73
                Width = 80
                Height = 23
                TabOrder = 9
                Text = '2.16'
              end
              object cbRectangleStrokeColor: TColorBox
                Left = 484
                Top = 26
                Width = 80
                Height = 22
                TabOrder = 10
              end
              object eRectangleStrokeOpacity: TEdit
                Left = 484
                Top = 73
                Width = 60
                Height = 23
                TabOrder = 11
                Text = '1'
              end
              object eRectangleStrokeWeight: TEdit
                Left = 484
                Top = 120
                Width = 60
                Height = 23
                TabOrder = 12
                Text = '2'
              end
              object cbRectangleFillColor: TColorBox
                Left = 574
                Top = 26
                Width = 80
                Height = 22
                TabOrder = 13
              end
              object eRectangleFillOpacity: TEdit
                Left = 574
                Top = 73
                Width = 60
                Height = 23
                TabOrder = 14
                Text = '0.3'
              end
              object cbRectangleClickable: TCheckBox
                Left = 700
                Top = 51
                Width = 75
                Height = 15
                Caption = 'Clickable'
                Checked = True
                State = cbChecked
                TabOrder = 15
              end
              object cbRectangleDraggable: TCheckBox
                Left = 700
                Top = 73
                Width = 80
                Height = 15
                Caption = 'Draggable'
                TabOrder = 16
              end
              object cbRectangleEditable: TCheckBox
                Left = 700
                Top = 8
                Width = 70
                Height = 15
                Caption = 'Editable'
                TabOrder = 17
              end
              object cbRectangleVisible: TCheckBox
                Left = 700
                Top = 30
                Width = 60
                Height = 15
                Caption = 'Visible'
                Checked = True
                State = cbChecked
                TabOrder = 18
              end
              object bZoomToRectangles: TButton
                Left = 868
                Top = 46
                Width = 117
                Height = 25
                Caption = 'ZoomToRectangles'
                TabOrder = 19
                OnClick = bZoomToRectanglesClick
              end
            end
            object tsCircle: TTabSheet
              Caption = 'Circle'
              ImageIndex = 3
              object lCircleCenterLat: TLabel
                Left = 280
                Top = 8
                Width = 57
                Height = 15
                Caption = 'Center Lat:'
              end
              object lCircleCenterLng: TLabel
                Left = 370
                Top = 8
                Width = 61
                Height = 15
                Caption = 'Center Lng:'
              end
              object lCircleRadius: TLabel
                Left = 280
                Top = 55
                Width = 38
                Height = 15
                Caption = 'Radius:'
              end
              object lCircleStrokeColor: TLabel
                Left = 484
                Top = 8
                Width = 65
                Height = 15
                Caption = 'StrokeColor:'
              end
              object lCircleStrokeOpacity: TLabel
                Left = 484
                Top = 55
                Width = 77
                Height = 15
                Caption = 'StrokeOpacity:'
              end
              object lCircleStrokeWeight: TLabel
                Left = 484
                Top = 102
                Width = 74
                Height = 15
                Caption = 'StrokeWeight:'
              end
              object lCircleFillColor: TLabel
                Left = 574
                Top = 8
                Width = 47
                Height = 15
                Caption = 'FillColor:'
              end
              object lCircleFillOpacity: TLabel
                Left = 574
                Top = 55
                Width = 59
                Height = 15
                Caption = 'FillOpacity:'
              end
              object lbCircles: TListBox
                Left = 8
                Top = 8
                Width = 150
                Height = 130
                ItemHeight = 15
                TabOrder = 0
                OnClick = lbCirclesClick
              end
              object bAddCircle: TButton
                Left = 164
                Top = 8
                Width = 65
                Height = 25
                Caption = 'Add'
                TabOrder = 1
                OnClick = bAddCircleClick
              end
              object bDeleteCircle: TButton
                Left = 164
                Top = 39
                Width = 65
                Height = 25
                Caption = 'Delete'
                TabOrder = 2
                OnClick = bDeleteCircleClick
              end
              object bClearCircles: TButton
                Left = 164
                Top = 70
                Width = 65
                Height = 25
                Caption = 'Clear'
                TabOrder = 3
                OnClick = bClearCirclesClick
              end
              object bUpdateCircle: TButton
                Left = 164
                Top = 101
                Width = 65
                Height = 25
                Caption = 'Update'
                TabOrder = 4
                OnClick = bUpdateCircleClick
              end
              object bZoomToCircle: TButton
                Left = 868
                Top = 8
                Width = 125
                Height = 25
                Caption = 'ZoomToCircle'
                TabOrder = 5
                OnClick = bZoomToCircleClick
              end
              object eCircleCenterLat: TEdit
                Left = 280
                Top = 26
                Width = 80
                Height = 23
                TabOrder = 6
                Text = '41.3874'
              end
              object eCircleCenterLng: TEdit
                Left = 370
                Top = 26
                Width = 80
                Height = 23
                TabOrder = 7
                Text = '2.1686'
              end
              object eCircleRadius: TEdit
                Left = 280
                Top = 73
                Width = 100
                Height = 23
                TabOrder = 8
                Text = '1000'
              end
              object cbCircleStrokeColor: TColorBox
                Left = 484
                Top = 26
                Width = 80
                Height = 22
                TabOrder = 9
              end
              object eCircleStrokeOpacity: TEdit
                Left = 484
                Top = 73
                Width = 60
                Height = 23
                TabOrder = 10
                Text = '1'
              end
              object eCircleStrokeWeight: TEdit
                Left = 484
                Top = 120
                Width = 60
                Height = 23
                TabOrder = 11
                Text = '2'
              end
              object cbCircleFillColor: TColorBox
                Left = 574
                Top = 26
                Width = 80
                Height = 22
                TabOrder = 12
              end
              object eCircleFillOpacity: TEdit
                Left = 574
                Top = 73
                Width = 60
                Height = 23
                TabOrder = 13
                Text = '0.3'
              end
              object cbCircleClickable: TCheckBox
                Left = 692
                Top = 53
                Width = 75
                Height = 15
                Caption = 'Clickable'
                Checked = True
                State = cbChecked
                TabOrder = 14
              end
              object cbCircleDraggable: TCheckBox
                Left = 692
                Top = 75
                Width = 80
                Height = 15
                Caption = 'Draggable'
                TabOrder = 15
              end
              object cbCircleEditable: TCheckBox
                Left = 692
                Top = 8
                Width = 70
                Height = 15
                Caption = 'Editable'
                TabOrder = 16
              end
              object cbCircleVisible: TCheckBox
                Left = 692
                Top = 30
                Width = 60
                Height = 15
                Caption = 'Visible'
                Checked = True
                State = cbChecked
                TabOrder = 17
              end
              object bZoomToCircles: TButton
                Left = 868
                Top = 48
                Width = 125
                Height = 25
                Caption = 'ZoomToCircles'
                TabOrder = 18
                OnClick = bZoomToCirclesClick
              end
            end
            object tsGroundOverlay: TTabSheet
              Caption = 'Ground Overlay'
              ImageIndex = 4
              object lGroundOverlayUrl: TLabel
                Left = 276
                Top = 8
                Width = 18
                Height = 15
                Caption = 'Url:'
              end
              object lGroundOverlayNorth: TLabel
                Left = 276
                Top = 55
                Width = 34
                Height = 15
                Caption = 'North:'
              end
              object lGroundOverlaySouth: TLabel
                Left = 370
                Top = 55
                Width = 34
                Height = 15
                Caption = 'South:'
              end
              object lGroundOverlayEast: TLabel
                Left = 464
                Top = 55
                Width = 24
                Height = 15
                Caption = 'East:'
              end
              object lGroundOverlayWest: TLabel
                Left = 558
                Top = 55
                Width = 29
                Height = 15
                Caption = 'West:'
              end
              object lGroundOverlayOpacity: TLabel
                Left = 652
                Top = 55
                Width = 44
                Height = 15
                Caption = 'Opacity:'
              end
              object lbGroundOverlays: TListBox
                Left = 8
                Top = 8
                Width = 150
                Height = 130
                ItemHeight = 15
                TabOrder = 0
                OnClick = lbGroundOverlaysClick
              end
              object bAddGroundOverlay: TButton
                Left = 164
                Top = 8
                Width = 65
                Height = 25
                Caption = 'Add'
                TabOrder = 1
                OnClick = bAddGroundOverlayClick
              end
              object bDeleteGroundOverlay: TButton
                Left = 164
                Top = 39
                Width = 65
                Height = 25
                Caption = 'Delete'
                TabOrder = 2
                OnClick = bDeleteGroundOverlayClick
              end
              object bClearGroundOverlays: TButton
                Left = 164
                Top = 70
                Width = 65
                Height = 25
                Caption = 'Clear'
                TabOrder = 3
                OnClick = bClearGroundOverlaysClick
              end
              object bUpdateGroundOverlay: TButton
                Left = 164
                Top = 101
                Width = 65
                Height = 25
                Caption = 'Update'
                TabOrder = 4
                OnClick = bUpdateGroundOverlayClick
              end
              object eGroundOverlayUrl: TEdit
                Left = 276
                Top = 26
                Width = 530
                Height = 23
                TabOrder = 5
              end
              object eGroundOverlayNorth: TEdit
                Left = 276
                Top = 73
                Width = 80
                Height = 23
                TabOrder = 6
              end
              object eGroundOverlaySouth: TEdit
                Left = 370
                Top = 73
                Width = 80
                Height = 23
                TabOrder = 7
              end
              object eGroundOverlayEast: TEdit
                Left = 464
                Top = 73
                Width = 80
                Height = 23
                TabOrder = 8
              end
              object eGroundOverlayWest: TEdit
                Left = 558
                Top = 73
                Width = 80
                Height = 23
                TabOrder = 9
              end
              object eGroundOverlayOpacity: TEdit
                Left = 652
                Top = 73
                Width = 60
                Height = 23
                TabOrder = 10
              end
              object cbGroundOverlayClickable: TCheckBox
                Left = 734
                Top = 55
                Width = 75
                Height = 15
                Caption = 'Clickable'
                Checked = True
                State = cbChecked
                TabOrder = 11
              end
              object cbGroundOverlayVisible: TCheckBox
                Left = 734
                Top = 77
                Width = 60
                Height = 15
                Caption = 'Visible'
                Checked = True
                State = cbChecked
                TabOrder = 12
              end
              object bZoomToGroundOverlay: TButton
                Left = 868
                Top = 8
                Width = 141
                Height = 25
                Caption = 'ZoomToGroundOverlay'
                TabOrder = 13
                OnClick = bZoomToGroundOverlayClick
              end
              object bZoomToGroundOverlays: TButton
                Left = 868
                Top = 48
                Width = 141
                Height = 25
                Caption = 'ZoomToGroundOverlays'
                TabOrder = 14
                OnClick = bZoomToGroundOverlaysClick
              end
            end
          end
        end
        object tsLayers: TTabSheet
          Caption = 'Layers'
          ImageIndex = 5
          object lTrafficVisible: TLabel
            Left = 10
            Top = 10
            Width = 33
            Height = 15
            Caption = 'Traffic'
          end
          object lKmlUrl: TLabel
            Left = 180
            Top = 10
            Width = 45
            Height = 15
            Caption = 'KML Url:'
          end
          object lKmlZIndex: TLabel
            Left = 180
            Top = 55
            Width = 38
            Height = 15
            Caption = 'ZIndex:'
          end
          object cbTrafficVisible: TCheckBox
            Left = 10
            Top = 28
            Width = 75
            Height = 15
            Caption = 'Visible'
            TabOrder = 0
          end
          object cbTrafficAutoRefresh: TCheckBox
            Left = 10
            Top = 50
            Width = 90
            Height = 15
            Caption = 'AutoRefresh'
            Checked = True
            State = cbChecked
            TabOrder = 1
          end
          object cbTransitVisible: TCheckBox
            Left = 10
            Top = 82
            Width = 75
            Height = 15
            Caption = 'Transit'
            TabOrder = 2
          end
          object cbBicyclingVisible: TCheckBox
            Left = 10
            Top = 104
            Width = 90
            Height = 15
            Caption = 'Bicycling'
            TabOrder = 3
          end
          object eKmlUrl: TEdit
            Left = 180
            Top = 28
            Width = 620
            Height = 23
            TabOrder = 4
          end
          object eKmlZIndex: TEdit
            Left = 180
            Top = 73
            Width = 80
            Height = 23
            TabOrder = 5
          end
          object cbKmlVisible: TCheckBox
            Left = 290
            Top = 55
            Width = 60
            Height = 15
            Caption = 'Visible'
            TabOrder = 6
          end
          object cbKmlClickable: TCheckBox
            Left = 360
            Top = 55
            Width = 75
            Height = 15
            Caption = 'Clickable'
            Checked = True
            State = cbChecked
            TabOrder = 7
          end
          object cbKmlPreserveViewport: TCheckBox
            Left = 450
            Top = 55
            Width = 150
            Height = 15
            Caption = 'PreserveViewport'
            TabOrder = 8
          end
          object cbKmlScreenOverlays: TCheckBox
            Left = 610
            Top = 55
            Width = 120
            Height = 15
            Caption = 'ScreenOverlays'
            Checked = True
            State = cbChecked
            TabOrder = 9
          end
          object cbKmlSuppressInfoWindows: TCheckBox
            Left = 740
            Top = 55
            Width = 150
            Height = 15
            Caption = 'SuppressInfoWindows'
            TabOrder = 10
          end
          object bApplyLayers: TButton
            Left = 180
            Top = 104
            Width = 120
            Height = 25
            Caption = 'Apply Layers'
            TabOrder = 11
            OnClick = bApplyLayersClick
          end
        end
        object tsInfoWindows: TTabSheet
          Caption = 'Info Windows'
          object Label1: TLabel
            Left = 48
            Top = 32
            Width = 624
            Height = 84
            Caption = 
              'Create a marker on the map by clicking on it, then tap on it to ' +
              'display an info window with:'#10'- position'#10'- geocoding'#10'- elevation'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
        end
        object tsGeoCode: TTabSheet
          Caption = 'Geocoding'
          object Label2: TLabel
            Left = 48
            Top = 32
            Width = 624
            Height = 84
            Caption = 
              'Create a marker on the map by clicking on it, then tap on it to ' +
              'display an info window with:'#10'- position'#10'- geocoding'#10'- elevation'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
        end
        object tsElevation: TTabSheet
          Caption = 'Elevation'
          object Label3: TLabel
            Left = 48
            Top = 32
            Width = 624
            Height = 84
            Caption = 
              'Create a marker on the map by clicking on it, then tap on it to ' +
              'display an info window with:'#10'- position'#10'- geocoding'#10'- elevation'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
        end
        object tsRoutes: TTabSheet
          Caption = 'Routes'
          object lRouteFrom: TLabel
            Left = 10
            Top = 10
            Width = 35
            Height = 15
            Caption = 'Desde:'
          end
          object lRouteTo: TLabel
            Left = 10
            Top = 55
            Width = 33
            Height = 15
            Caption = 'Hasta:'
          end
          object lRoutes: TLabel
            Left = 394
            Top = 10
            Width = 32
            Height = 15
            Caption = 'Rutes:'
          end
          object eRouteFrom: TEdit
            Left = 10
            Top = 28
            Width = 350
            Height = 23
            TabOrder = 0
            Text = 'Barcelona, Spain'
          end
          object eRouteTo: TEdit
            Left = 10
            Top = 73
            Width = 350
            Height = 23
            TabOrder = 1
            Text = 'Madrid, Spain'
          end
          object bApplyRoute: TButton
            Left = 10
            Top = 100
            Width = 100
            Height = 25
            Caption = 'Aplicar'
            TabOrder = 2
            OnClick = bApplyRouteClick
          end
          object lbRoutes: TListBox
            Left = 394
            Top = 28
            Width = 350
            Height = 141
            ItemHeight = 15
            TabOrder = 3
            OnClick = lbRoutesClick
          end
          object cbRouteCloseOthers: TCheckBox
            Left = 778
            Top = 28
            Width = 233
            Height = 17
            Caption = 'Cerrar otras rutas al mostrar esta'
            TabOrder = 4
            OnClick = cbRouteCloseOthersClick
          end
        end
        object tsGeometry: TTabSheet
          Caption = 'Geometry'
          object lGeomFromLat: TLabel
            Left = 10
            Top = 10
            Width = 38
            Height = 15
            Caption = 'From Y'
          end
          object lGeomFromLng: TLabel
            Left = 110
            Top = 10
            Width = 38
            Height = 15
            Caption = 'From X'
          end
          object lGeomToLat: TLabel
            Left = 10
            Top = 62
            Width = 23
            Height = 15
            Caption = 'To Y'
          end
          object lGeomToLng: TLabel
            Left = 110
            Top = 62
            Width = 23
            Height = 15
            Caption = 'To X'
          end
          object lGeomPointLat: TLabel
            Left = 220
            Top = 10
            Width = 41
            Height = 15
            Caption = 'Probe Y'
          end
          object lGeomPointLng: TLabel
            Left = 320
            Top = 10
            Width = 41
            Height = 15
            Caption = 'Probe X'
          end
          object eGeomFromLat: TEdit
            Left = 10
            Top = 28
            Width = 90
            Height = 23
            TabOrder = 0
            Text = '41.3874'
          end
          object eGeomFromLng: TEdit
            Left = 110
            Top = 28
            Width = 90
            Height = 23
            TabOrder = 1
            Text = '2.1686'
          end
          object eGeomToLat: TEdit
            Left = 10
            Top = 80
            Width = 90
            Height = 23
            TabOrder = 2
            Text = '41.3980'
          end
          object eGeomToLng: TEdit
            Left = 110
            Top = 80
            Width = 90
            Height = 23
            TabOrder = 3
            Text = '2.1800'
          end
          object eGeomPointLat: TEdit
            Left = 220
            Top = 28
            Width = 90
            Height = 23
            TabOrder = 4
            Text = '41.3920'
          end
          object eGeomPointLng: TEdit
            Left = 320
            Top = 28
            Width = 90
            Height = 23
            TabOrder = 5
            Text = '2.1740'
          end
          object bComputeGeometry: TButton
            Left = 220
            Top = 80
            Width = 120
            Height = 25
            Caption = 'Compute'
            TabOrder = 6
            OnClick = bComputeGeometryClick
          end
          object mGeometryResults: TMemo
            Left = 440
            Top = 10
            Width = 680
            Height = 149
            Align = alCustom
            ReadOnly = True
            ScrollBars = ssVertical
            TabOrder = 7
          end
        end
      end
    end
    object tsOSM: TTabSheet
      Caption = 'OpenStreetMap'
      ImageIndex = 1
      object pcOSMOptions: TPageControl
        Left = 0
        Top = 0
        Width = 1227
        Height = 205
        ActivePage = tsOSMPopups
        Align = alClient
        TabOrder = 0
        object tsOSMGeneral: TTabSheet
          Caption = 'Map'
          object lOSMCenterLat: TLabel
            Left = 16
            Top = 16
            Width = 54
            Height = 15
            Caption = 'Center Lat'
          end
          object lOSMCenterLng: TLabel
            Left = 152
            Top = 16
            Width = 58
            Height = 15
            Caption = 'Center Lng'
          end
          object lOSMZoom: TLabel
            Left = 288
            Top = 16
            Width = 32
            Height = 15
            Caption = 'Zoom'
          end
          object lOSMNorth: TLabel
            Left = 945
            Top = 42
            Width = 31
            Height = 15
            Caption = 'North'
          end
          object lOSMSouth: TLabel
            Left = 1033
            Top = 42
            Width = 31
            Height = 15
            Caption = 'South'
          end
          object lOSMEast: TLabel
            Left = 945
            Top = 89
            Width = 21
            Height = 15
            Caption = 'East'
          end
          object lOSMWest: TLabel
            Left = 1033
            Top = 89
            Width = 26
            Height = 15
            Caption = 'West'
          end
          object lOSMStyleUrl: TLabel
            Left = 384
            Top = 16
            Width = 49
            Height = 15
            Caption = 'Style URL'
          end
          object lOSMMapMode: TLabel
            Left = 16
            Top = 64
            Width = 58
            Height = 15
            Caption = 'Map mode'
          end
          object lOSMBearing: TLabel
            Left = 16
            Top = 122
            Width = 40
            Height = 15
            Caption = 'Bearing'
          end
          object lOSMPitch: TLabel
            Left = 104
            Top = 122
            Width = 27
            Height = 15
            Caption = 'Pitch'
          end
          object lOSMMinZoom: TLabel
            Left = 192
            Top = 122
            Width = 54
            Height = 15
            Caption = 'Min zoom'
          end
          object lOSMMaxZoom: TLabel
            Left = 280
            Top = 122
            Width = 55
            Height = 15
            Caption = 'Max zoom'
          end
          object lOSMMinPitch: TLabel
            Left = 262
            Top = 63
            Width = 51
            Height = 15
            Caption = 'Min pitch'
          end
          object lOSMMaxPitch: TLabel
            Left = 326
            Top = 63
            Width = 52
            Height = 15
            Caption = 'Max pitch'
          end
          object eOSMCenterLat: TEdit
            Left = 16
            Top = 34
            Width = 120
            Height = 23
            TabOrder = 0
            Text = '41.3874'
          end
          object eOSMCenterLng: TEdit
            Left = 152
            Top = 34
            Width = 120
            Height = 23
            TabOrder = 1
            Text = '2.1686'
          end
          object eOSMZoom: TEdit
            Left = 288
            Top = 34
            Width = 70
            Height = 23
            TabOrder = 2
            Text = '12'
          end
          object bActivateOSM: TButton
            Left = 16
            Top = 89
            Width = 110
            Height = 25
            Caption = 'Activate OSM'
            TabOrder = 3
            OnClick = ActivateOSMClick
          end
          object bApplyOSMView: TButton
            Left = 137
            Top = 89
            Width = 110
            Height = 25
            Caption = 'Apply View'
            TabOrder = 4
            OnClick = ApplyOSMViewClick
          end
          object eOSMNorth: TEdit
            Left = 945
            Top = 60
            Width = 80
            Height = 23
            TabOrder = 5
            Text = '41.42'
          end
          object eOSMSouth: TEdit
            Left = 1033
            Top = 60
            Width = 80
            Height = 23
            TabOrder = 6
            Text = '41.35'
          end
          object eOSMEast: TEdit
            Left = 945
            Top = 107
            Width = 80
            Height = 23
            TabOrder = 7
            Text = '2.22'
          end
          object eOSMWest: TEdit
            Left = 1033
            Top = 107
            Width = 80
            Height = 23
            TabOrder = 8
            Text = '2.12'
          end
          object bFitOSMBounds: TButton
            Left = 945
            Top = 3
            Width = 110
            Height = 25
            Caption = 'Fit Bounds'
            TabOrder = 9
            OnClick = FitOSMBoundsClick
          end
          object eOSMStyleUrl: TEdit
            Left = 384
            Top = 34
            Width = 430
            Height = 23
            TabOrder = 10
          end
          object bApplyOSMStyle: TButton
            Left = 820
            Top = 34
            Width = 90
            Height = 23
            Caption = 'Apply Style'
            TabOrder = 11
            OnClick = ApplyOSMStyleClick
          end
          object cbOSMStyles: TComboBox
            Left = 384
            Top = 60
            Width = 526
            Height = 23
            Style = csDropDownList
            TabOrder = 12
            OnChange = OSMStylePresetChange
          end
          object cbOSMLogMove: TCheckBox
            Left = 384
            Top = 92
            Width = 115
            Height = 17
            Caption = 'Log Move/Zoom'
            TabOrder = 13
          end
          object cbOSMLogRender: TCheckBox
            Left = 506
            Top = 92
            Width = 95
            Height = 17
            Caption = 'Log Render'
            TabOrder = 14
          end
          object cbOSMLogData: TCheckBox
            Left = 616
            Top = 92
            Width = 89
            Height = 17
            Caption = 'Log Data'
            TabOrder = 15
          end
          object cbOSMMapMode: TComboBox
            Left = 88
            Top = 60
            Width = 160
            Height = 23
            Style = csDropDownList
            TabOrder = 16
          end
          object eOSMBearing: TEdit
            Left = 16
            Top = 140
            Width = 80
            Height = 23
            TabOrder = 17
            Text = '0'
          end
          object eOSMPitch: TEdit
            Left = 104
            Top = 140
            Width = 80
            Height = 23
            TabOrder = 18
            Text = '0'
          end
          object eOSMMinZoom: TEdit
            Left = 192
            Top = 140
            Width = 80
            Height = 23
            TabOrder = 19
            Text = '0'
          end
          object eOSMMaxZoom: TEdit
            Left = 280
            Top = 140
            Width = 80
            Height = 23
            TabOrder = 20
            Text = '22'
          end
          object eOSMMinPitch: TEdit
            Left = 262
            Top = 81
            Width = 54
            Height = 23
            TabOrder = 21
            Text = '0'
          end
          object eOSMMaxPitch: TEdit
            Left = 326
            Top = 81
            Width = 52
            Height = 23
            TabOrder = 22
            Text = '60'
          end
          object cbOSMDragPan: TCheckBox
            Left = 384
            Top = 113
            Width = 97
            Height = 17
            Caption = 'DragPan'
            Checked = True
            State = cbChecked
            TabOrder = 23
          end
          object cbOSMDragRotate: TCheckBox
            Left = 506
            Top = 113
            Width = 97
            Height = 17
            Caption = 'DragRotate'
            Checked = True
            State = cbChecked
            TabOrder = 24
          end
          object cbOSMDoubleClickZoom: TCheckBox
            Left = 616
            Top = 113
            Width = 121
            Height = 17
            Caption = 'DoubleClickZoom'
            Checked = True
            State = cbChecked
            TabOrder = 25
          end
          object cbOSMScrollZoom: TCheckBox
            Left = 717
            Top = 92
            Width = 87
            Height = 17
            Caption = 'ScrollZoom'
            Checked = True
            State = cbChecked
            TabOrder = 26
          end
          object cbOSMKeyboard: TCheckBox
            Left = 384
            Top = 134
            Width = 97
            Height = 17
            Caption = 'Keyboard'
            Checked = True
            State = cbChecked
            TabOrder = 27
          end
          object cbOSMTouchZoomRotate: TCheckBox
            Left = 506
            Top = 134
            Width = 125
            Height = 17
            Caption = 'TouchZoomRotate'
            Checked = True
            State = cbChecked
            TabOrder = 28
          end
          object cbOSMTouchPitch: TCheckBox
            Left = 820
            Top = 92
            Width = 90
            Height = 17
            Caption = 'TouchPitch'
            Checked = True
            State = cbChecked
            TabOrder = 29
          end
          object cbOSMCooperativeGestures: TCheckBox
            Left = 742
            Top = 113
            Width = 154
            Height = 17
            Caption = 'CooperativeGestures'
            TabOrder = 30
          end
          object cbOSMUseMaxBounds: TCheckBox
            Left = 945
            Top = 140
            Width = 110
            Height = 17
            Caption = 'Use MaxBounds'
            TabOrder = 31
          end
          object cbOSMRenderWorldCopies: TCheckBox
            Left = 633
            Top = 134
            Width = 140
            Height = 17
            Caption = 'RenderWorldCopies'
            Checked = True
            State = cbChecked
            TabOrder = 32
          end
        end
        object tsOSMOffline: TTabSheet
          Caption = 'OfflineMode'
          ImageIndex = 1
          object lOSMOfflineTileJsonUrl: TLabel
            Left = 16
            Top = 48
            Width = 115
            Height = 15
            Caption = 'Remote Tile Template'
          end
          object lOSMOfflineServerExecutable: TLabel
            Left = 16
            Top = 80
            Width = 91
            Height = 15
            Caption = 'Glyphs Root Path'
          end
          object lOSMOfflineServerPort: TLabel
            Left = 16
            Top = 112
            Width = 104
            Height = 15
            Caption = 'Style Template Path'
          end
          object lOSMOfflineSourcePreset: TLabel
            Left = 16
            Top = 144
            Width = 109
            Height = 15
            Caption = 'Offline source preset'
          end
          object eOSMOfflineTileJsonUrl: TEdit
            Left = 152
            Top = 44
            Width = 577
            Height = 23
            TabOrder = 0
            Text = 'https://tiles.openfreemap.org/planet/latest/{z}/{x}/{y}.pbf'
          end
          object eOSMOfflineServerExecutable: TEdit
            Left = 152
            Top = 76
            Width = 577
            Height = 23
            TabOrder = 1
            Text = 'resources\js\osm\vendor'
          end
          object eOSMOfflineServerPort: TEdit
            Left = 152
            Top = 108
            Width = 577
            Height = 23
            TabOrder = 2
            Text = 'resources\js\osm\offline\style.template.json'
          end
          object cbOSMOfflineSourcePreset: TComboBox
            Left = 152
            Top = 140
            Width = 320
            Height = 23
            Style = csDropDownList
            TabOrder = 3
          end
          object lbOSMRegions: TListBox
            Left = 764
            Top = 16
            Width = 420
            Height = 110
            ItemHeight = 15
            TabOrder = 4
          end
          object bOSMDownloadRegion: TButton
            Left = 764
            Top = 140
            Width = 140
            Height = 25
            Caption = 'Download Region'
            TabOrder = 5
            OnClick = bOSMDownloadRegionClick
          end
          object bOSMDeleteRegion: TButton
            Left = 924
            Top = 140
            Width = 140
            Height = 25
            Caption = 'Delete Region'
            TabOrder = 6
          end
        end
        object tsOSMMarkers: TTabSheet
          Caption = 'Markers'
          ImageIndex = 2
          DesignSize = (
            1219
            175)
          object lOSMMarkerLat: TLabel
            Left = 331
            Top = 8
            Width = 16
            Height = 15
            Caption = 'Lat'
          end
          object lOSMMarkerLng: TLabel
            Left = 402
            Top = 8
            Width = 20
            Height = 15
            Caption = 'Lng'
          end
          object lOSMMarkerTitle: TLabel
            Left = 331
            Top = 50
            Width = 23
            Height = 15
            Caption = 'Title'
          end
          object lOSMMarkerKind: TLabel
            Left = 331
            Top = 91
            Width = 24
            Height = 15
            Caption = 'Kind'
          end
          object lbOSMMarkers: TListBox
            Left = 8
            Top = 8
            Width = 200
            Height = 163
            ItemHeight = 15
            TabOrder = 0
          end
          object bOSMClearMarkers: TButton
            Left = 214
            Top = 68
            Width = 89
            Height = 25
            Caption = 'Clear Markers'
            TabOrder = 1
          end
          object bOSMAddMarker: TButton
            Left = 214
            Top = 8
            Width = 89
            Height = 25
            Caption = 'Add Marker'
            TabOrder = 2
          end
          object bOSMUpdateMarker: TButton
            Left = 214
            Top = 103
            Width = 89
            Height = 25
            Caption = 'Update Marker'
            TabOrder = 3
          end
          object bOSMDeleteMarker: TButton
            Left = 214
            Top = 39
            Width = 89
            Height = 25
            Caption = 'Delete Marker'
            TabOrder = 4
          end
          object bOSMZoomToMarkers: TButton
            Left = 488
            Top = 8
            Width = 97
            Height = 25
            Caption = 'Zoom To Markers'
            TabOrder = 5
          end
          object bApplyOSMEventFilter: TButton
            Left = 488
            Top = 39
            Width = 97
            Height = 25
            Caption = 'Apply Event Filter'
            TabOrder = 6
            OnClick = ApplyOSMEventFilterClick
          end
          object eOSMMarkerLat: TEdit
            Left = 331
            Top = 23
            Width = 65
            Height = 23
            TabOrder = 7
          end
          object eOSMMarkerLng: TEdit
            Left = 402
            Top = 23
            Width = 65
            Height = 23
            TabOrder = 8
          end
          object eOSMMarkerTitle: TEdit
            Left = 331
            Top = 65
            Width = 105
            Height = 23
            TabOrder = 9
          end
          object cbOSMMarkerVisible: TCheckBox
            Left = 331
            Top = 135
            Width = 65
            Height = 17
            Caption = 'Visible'
            Checked = True
            State = cbChecked
            TabOrder = 10
          end
          object cbOSMMarkerDraggable: TCheckBox
            Left = 402
            Top = 135
            Width = 75
            Height = 17
            Caption = 'Draggable'
            TabOrder = 11
          end
          object cbOSMMarkerKind: TComboBox
            Left = 331
            Top = 107
            Width = 97
            Height = 23
            Style = csDropDownList
            TabOrder = 12
          end
          object pcOSMMarkers: TPageControl
            Left = 591
            Top = 3
            Width = 625
            Height = 168
            ActivePage = tsOSMDotMarkers
            Anchors = [akLeft, akTop, akRight, akBottom]
            TabOrder = 13
            object tsOSMStandardMarkers: TTabSheet
              Caption = 'Standard'
              object sbOSMStandardMarkers: TScrollBox
                Left = 0
                Top = 0
                Width = 617
                Height = 138
                HorzScrollBar.Visible = False
                VertScrollBar.Tracking = True
                Align = alClient
                BorderStyle = bsNone
                TabOrder = 0
                object lOSMMarkerColor: TLabel
                  Left = 16
                  Top = 10
                  Width = 29
                  Height = 15
                  Caption = 'Color'
                end
                object lOSMMarkerGlyphTextColor: TLabel
                  Left = 120
                  Top = 10
                  Width = 61
                  Height = 15
                  Caption = 'Glyph color'
                end
                object lOSMMarkerScale: TLabel
                  Left = 224
                  Top = 10
                  Width = 27
                  Height = 15
                  Caption = 'Scale'
                end
                object lOSMMarkerGlyphText: TLabel
                  Left = 16
                  Top = 56
                  Width = 53
                  Height = 15
                  Caption = 'Glyph text'
                end
                object lOSMMarkerStandardBorderColor: TLabel
                  Left = 265
                  Top = 10
                  Width = 65
                  Height = 15
                  Caption = 'Border color'
                end
                object lOSMMarkerStandardBorderWidth: TLabel
                  Left = 362
                  Top = 10
                  Width = 68
                  Height = 15
                  Caption = 'Border width'
                end
                object lOSMMarkerStandardGlyphFontSize: TLabel
                  Left = 437
                  Top = 10
                  Width = 78
                  Height = 15
                  Caption = 'Glyph font size'
                end
                object lOSMMarkerStandardPopupText: TLabel
                  Left = 87
                  Top = 56
                  Width = 57
                  Height = 15
                  Caption = 'Legacy popup text'
                  Visible = False
                end
                object lOSMMarkerStandardOpacity: TLabel
                  Left = 216
                  Top = 57
                  Width = 41
                  Height = 15
                  Caption = 'Opacity'
                end
                object lOSMMarkerStandardZIndex: TLabel
                  Left = 280
                  Top = 57
                  Width = 35
                  Height = 15
                  Caption = 'ZIndex'
                end
                object lOSMMarkerStandardRotation: TLabel
                  Left = 344
                  Top = 57
                  Width = 45
                  Height = 15
                  Caption = 'Rotation'
                end
                object lOSMMarkerStandardAnchorX: TLabel
                  Left = 408
                  Top = 57
                  Width = 67
                  Height = 15
                  Caption = 'Anchor X off.'
                end
                object lOSMMarkerStandardAnchorY: TLabel
                  Left = 472
                  Top = 57
                  Width = 67
                  Height = 15
                  Caption = 'Anchor Y off.'
                end
                object lOSMMarkerStandardGlyphOffsetX: TLabel
                  Left = 536
                  Top = 10
                  Width = 62
                  Height = 15
                  Caption = 'Glyph off. X'
                end
                object lOSMMarkerStandardGlyphOffsetY: TLabel
                  Left = 536
                  Top = 56
                  Width = 62
                  Height = 15
                  Caption = 'Glyph off. Y'
                end
                object cbOSMMarkerColor: TColorBox
                  Left = 16
                  Top = 27
                  Width = 90
                  Height = 22
                  Selected = clRed
                  TabOrder = 0
                end
                object cbOSMMarkerGlyphTextColor: TColorBox
                  Left = 120
                  Top = 27
                  Width = 90
                  Height = 22
                  Selected = clWhite
                  TabOrder = 1
                end
                object eOSMMarkerScale: TEdit
                  Left = 224
                  Top = 27
                  Width = 33
                  Height = 23
                  TabOrder = 2
                  Text = '1'
                end
                object eOSMMarkerGlyphText: TEdit
                  Left = 16
                  Top = 73
                  Width = 65
                  Height = 23
                  TabOrder = 3
                end
                object cbOSMMarkerHideCenterDot: TCheckBox
                  Left = 264
                  Top = 112
                  Width = 121
                  Height = 17
                  Caption = 'Hide center dot'
                  TabOrder = 4
                end
                object cbOSMMarkerStandardBorderColor: TColorBox
                  Left = 265
                  Top = 27
                  Width = 90
                  Height = 22
                  TabOrder = 5
                end
                object eOSMMarkerStandardBorderWidth: TEdit
                  Left = 362
                  Top = 27
                  Width = 52
                  Height = 23
                  TabOrder = 6
                  Text = '0'
                end
                object eOSMMarkerStandardGlyphFontSize: TEdit
                  Left = 437
                  Top = 27
                  Width = 52
                  Height = 23
                  TabOrder = 7
                  Text = '0'
                end
                object eOSMMarkerStandardPopupText: TEdit
                  Left = 87
                  Top = 73
                  Width = 114
                  Height = 23
                  TabOrder = 8
                  Visible = False
                end
                object cbOSMMarkerStandardShadowEnabled: TCheckBox
                  Left = 504
                  Top = 112
                  Width = 81
                  Height = 17
                  Caption = 'Shadow'
                  TabOrder = 9
                  Visible = False
                end
                object cbOSMMarkerStandardPopupEnabled: TCheckBox
                  Left = 407
                  Top = 112
                  Width = 81
                  Height = 17
                  Caption = 'Popup'
                  Checked = True
                  State = cbChecked
                  TabOrder = 10
                end
                object cbOSMMarkerStandardUseDefaultShape: TCheckBox
                  Left = 16
                  Top = 112
                  Width = 133
                  Height = 17
                  Caption = 'Use default shape'
                  Checked = True
                  State = cbChecked
                  TabOrder = 11
                end
                object cbOSMMarkerStandardUseGlyph: TCheckBox
                  Left = 155
                  Top = 112
                  Width = 81
                  Height = 17
                  Caption = 'Use glyph'
                  Checked = True
                  State = cbChecked
                  TabOrder = 12
                end
                object eOSMMarkerStandardOpacity: TEdit
                  Left = 216
                  Top = 73
                  Width = 50
                  Height = 23
                  TabOrder = 13
                  Text = '1'
                end
                object eOSMMarkerStandardZIndex: TEdit
                  Left = 280
                  Top = 73
                  Width = 50
                  Height = 23
                  TabOrder = 14
                  Text = '0'
                end
                object eOSMMarkerStandardRotation: TEdit
                  Left = 344
                  Top = 73
                  Width = 50
                  Height = 23
                  TabOrder = 15
                  Text = '0'
                end
                object eOSMMarkerStandardAnchorX: TEdit
                  Left = 408
                  Top = 73
                  Width = 50
                  Height = 23
                  TabOrder = 16
                  Text = '0'
                end
                object eOSMMarkerStandardAnchorY: TEdit
                  Left = 472
                  Top = 73
                  Width = 50
                  Height = 23
                  TabOrder = 17
                  Text = '0'
                end
                object eOSMMarkerStandardGlyphOffsetX: TEdit
                  Left = 536
                  Top = 27
                  Width = 50
                  Height = 23
                  TabOrder = 18
                  Text = '0'
                end
                object eOSMMarkerStandardGlyphOffsetY: TEdit
                  Left = 536
                  Top = 73
                  Width = 50
                  Height = 23
                  TabOrder = 19
                  Text = '0'
                end
              end
            end
            object tsOSMPinMarkers: TTabSheet
              Caption = 'Pin'
              ImageIndex = 1
              object sbOSMPinMarkers: TScrollBox
                Left = 0
                Top = 0
                Width = 617
                Height = 138
                HorzScrollBar.Visible = False
                VertScrollBar.Tracking = True
                Align = alClient
                BorderStyle = bsNone
                TabOrder = 0
                object lOSMMarkerPinBackgroundColor: TLabel
                  Left = 16
                  Top = 10
                  Width = 94
                  Height = 15
                  Caption = 'Background color'
                end
                object lOSMMarkerPinBorderColor: TLabel
                  Left = 120
                  Top = 10
                  Width = 65
                  Height = 15
                  Caption = 'Border color'
                end
                object lOSMMarkerPinGlyphColor: TLabel
                  Left = 224
                  Top = 10
                  Width = 61
                  Height = 15
                  Caption = 'Glyph color'
                end
                object lOSMMarkerPinShadowColor: TLabel
                  Left = 328
                  Top = 10
                  Width = 72
                  Height = 15
                  Caption = 'Shadow color'
                end
                object lOSMMarkerPinScale: TLabel
                  Left = 432
                  Top = 10
                  Width = 27
                  Height = 15
                  Caption = 'Scale'
                end
                object lOSMMarkerPinBorderWidth: TLabel
                  Left = 488
                  Top = 10
                  Width = 68
                  Height = 15
                  Caption = 'Border width'
                end
                object lOSMMarkerPinGlyphFontSize: TLabel
                  Left = 560
                  Top = 10
                  Width = 56
                  Height = 15
                  Caption = 'Glyph font'
                end
                object lOSMMarkerPinGlyphText: TLabel
                  Left = 16
                  Top = 56
                  Width = 53
                  Height = 15
                  Caption = 'Glyph text'
                end
                object lOSMMarkerPinPopupText: TLabel
                  Left = 80
                  Top = 56
                  Width = 95
                  Height = 15
                  Caption = 'Legacy popup text'
                  Visible = False
                end
                object lOSMMarkerPinCornerStyle: TLabel
                  Left = 202
                  Top = 56
                  Width = 63
                  Height = 15
                  Caption = 'Corner style'
                end
                object lOSMMarkerPinShapeVariant: TLabel
                  Left = 282
                  Top = 56
                  Width = 71
                  Height = 15
                  Caption = 'Shape variant'
                end
                object lOSMMarkerPinMinWidth: TLabel
                  Left = 16
                  Top = 102
                  Width = 54
                  Height = 15
                  Caption = 'Min width'
                end
                object lOSMMarkerPinMinHeight: TLabel
                  Left = 80
                  Top = 102
                  Width = 58
                  Height = 15
                  Caption = 'Min height'
                end
                object lOSMMarkerPinPadding: TLabel
                  Left = 144
                  Top = 102
                  Width = 44
                  Height = 15
                  Caption = 'Padding'
                end
                object lOSMMarkerPinPointerLength: TLabel
                  Left = 200
                  Top = 102
                  Width = 75
                  Height = 15
                  Caption = 'Pointer length'
                end
                object lOSMMarkerPinPointerWidth: TLabel
                  Left = 280
                  Top = 102
                  Width = 71
                  Height = 15
                  Caption = 'Pointer width'
                end
                object lOSMMarkerPinShadowBlur: TLabel
                  Left = 352
                  Top = 102
                  Width = 66
                  Height = 15
                  Caption = 'Shadow blur'
                end
                object lOSMMarkerPinOpacity: TLabel
                  Left = 416
                  Top = 102
                  Width = 41
                  Height = 15
                  Caption = 'Opacity'
                end
                object lOSMMarkerPinZIndex: TLabel
                  Left = 480
                  Top = 102
                  Width = 35
                  Height = 15
                  Caption = 'ZIndex'
                end
                object lOSMMarkerPinRotation: TLabel
                  Left = 544
                  Top = 102
                  Width = 45
                  Height = 15
                  Caption = 'Rotation'
                end
                object lOSMMarkerPinAnchorX: TLabel
                  Left = 362
                  Top = 56
                  Width = 67
                  Height = 15
                  Caption = 'Anchor X off.'
                end
                object lOSMMarkerPinAnchorY: TLabel
                  Left = 426
                  Top = 56
                  Width = 67
                  Height = 15
                  Caption = 'Anchor Y off.'
                end
                object cbOSMMarkerPinBackgroundColor: TColorBox
                  Left = 16
                  Top = 27
                  Width = 90
                  Height = 22
                  TabOrder = 0
                end
                object cbOSMMarkerPinBorderColor: TColorBox
                  Left = 120
                  Top = 27
                  Width = 90
                  Height = 22
                  TabOrder = 1
                end
                object cbOSMMarkerPinGlyphTextColor: TColorBox
                  Left = 224
                  Top = 27
                  Width = 90
                  Height = 22
                  TabOrder = 2
                end
                object cbOSMMarkerPinShadowColor: TColorBox
                  Left = 328
                  Top = 27
                  Width = 90
                  Height = 22
                  TabOrder = 3
                end
                object eOSMMarkerPinScale: TEdit
                  Left = 432
                  Top = 27
                  Width = 48
                  Height = 23
                  TabOrder = 4
                  Text = '1'
                end
                object eOSMMarkerPinBorderWidth: TEdit
                  Left = 488
                  Top = 27
                  Width = 48
                  Height = 23
                  TabOrder = 5
                  Text = '0'
                end
                object eOSMMarkerPinGlyphFontSize: TEdit
                  Left = 560
                  Top = 27
                  Width = 48
                  Height = 23
                  TabOrder = 6
                  Text = '0'
                end
                object eOSMMarkerPinGlyphText: TEdit
                  Left = 16
                  Top = 73
                  Width = 58
                  Height = 23
                  TabOrder = 7
                end
                object eOSMMarkerPinPopupText: TEdit
                  Left = 80
                  Top = 73
                  Width = 114
                  Height = 23
                  TabOrder = 8
                  Visible = False
                end
                object cbOSMMarkerPinCornerStyle: TComboBox
                  Left = 202
                  Top = 73
                  Width = 72
                  Height = 23
                  Style = csDropDownList
                  ItemIndex = 0
                  TabOrder = 9
                  Text = 'Default'
                  Items.Strings = (
                    'Default'
                    'Square'
                    'Pill')
                end
                object cbOSMMarkerPinShapeVariant: TComboBox
                  Left = 282
                  Top = 73
                  Width = 71
                  Height = 23
                  Style = csDropDownList
                  ItemIndex = 0
                  TabOrder = 10
                  Text = 'Default'
                  Items.Strings = (
                    'Default'
                    'Classic'
                    'Pill'
                    'Tag'
                    'Bubble')
                end
                object cbOSMMarkerPinShadowEnabled: TCheckBox
                  Left = 512
                  Top = 79
                  Width = 63
                  Height = 17
                  Caption = 'Shadow'
                  TabOrder = 11
                end
                object cbOSMMarkerPinPopupEnabled: TCheckBox
                  Left = 512
                  Top = 56
                  Width = 56
                  Height = 17
                  Caption = 'Popup'
                  Checked = True
                  State = cbChecked
                  TabOrder = 12
                end
                object eOSMMarkerPinMinWidth: TEdit
                  Left = 16
                  Top = 119
                  Width = 48
                  Height = 23
                  TabOrder = 13
                  Text = '0'
                end
                object eOSMMarkerPinMinHeight: TEdit
                  Left = 80
                  Top = 119
                  Width = 48
                  Height = 23
                  TabOrder = 14
                  Text = '0'
                end
                object eOSMMarkerPinPadding: TEdit
                  Left = 144
                  Top = 119
                  Width = 48
                  Height = 23
                  TabOrder = 15
                  Text = '0'
                end
                object eOSMMarkerPinPointerLength: TEdit
                  Left = 200
                  Top = 119
                  Width = 48
                  Height = 23
                  TabOrder = 16
                  Text = '0'
                end
                object eOSMMarkerPinPointerWidth: TEdit
                  Left = 280
                  Top = 119
                  Width = 48
                  Height = 23
                  TabOrder = 17
                  Text = '0'
                end
                object eOSMMarkerPinShadowBlur: TEdit
                  Left = 352
                  Top = 119
                  Width = 48
                  Height = 23
                  TabOrder = 18
                  Text = '0'
                end
                object eOSMMarkerPinOpacity: TEdit
                  Left = 416
                  Top = 119
                  Width = 48
                  Height = 23
                  TabOrder = 19
                  Text = '1'
                end
                object eOSMMarkerPinZIndex: TEdit
                  Left = 480
                  Top = 119
                  Width = 48
                  Height = 23
                  TabOrder = 20
                  Text = '0'
                end
                object eOSMMarkerPinRotation: TEdit
                  Left = 544
                  Top = 119
                  Width = 48
                  Height = 23
                  TabOrder = 21
                  Text = '0'
                end
                object eOSMMarkerPinAnchorX: TEdit
                  Left = 362
                  Top = 73
                  Width = 48
                  Height = 23
                  TabOrder = 22
                  Text = '0'
                end
                object eOSMMarkerPinAnchorY: TEdit
                  Left = 426
                  Top = 73
                  Width = 48
                  Height = 23
                  TabOrder = 23
                  Text = '0'
                end
              end
            end
            object tsOSMDotMarkers: TTabSheet
              Caption = 'Dot'
              ImageIndex = 2
              object sbOSMDotMarkers: TScrollBox
                Left = 0
                Top = 0
                Width = 617
                Height = 138
                HorzScrollBar.Visible = False
                VertScrollBar.Tracking = True
                Align = alClient
                BorderStyle = bsNone
                TabOrder = 0
                object lOSMMarkerDotColor: TLabel
                  Left = 16
                  Top = 10
                  Width = 29
                  Height = 15
                  Caption = 'Color'
                end
                object lOSMMarkerDotBorderColor: TLabel
                  Left = 120
                  Top = 10
                  Width = 65
                  Height = 15
                  Caption = 'Border color'
                end
                object lOSMMarkerDotGlyphColor: TLabel
                  Left = 224
                  Top = 10
                  Width = 61
                  Height = 15
                  Caption = 'Glyph color'
                end
                object lOSMMarkerDotPulseColor: TLabel
                  Left = 328
                  Top = 10
                  Width = 58
                  Height = 15
                  Caption = 'Pulse color'
                end
                object lOSMMarkerDotShadowColor: TLabel
                  Left = 432
                  Top = 10
                  Width = 72
                  Height = 15
                  Caption = 'Shadow color'
                end
                object lOSMMarkerDotScale: TLabel
                  Left = 536
                  Top = 10
                  Width = 27
                  Height = 15
                  Caption = 'Scale'
                end
                object lOSMMarkerDotGlyphText: TLabel
                  Left = 16
                  Top = 56
                  Width = 53
                  Height = 15
                  Caption = 'Glyph text'
                end
                object lOSMMarkerDotPopupText: TLabel
                  Left = 88
                  Top = 56
                  Width = 95
                  Height = 15
                  Caption = 'Legacy popup text'
                  Visible = False
                end
                object lOSMMarkerDotBorderWidth: TLabel
                  Left = 16
                  Top = 102
                  Width = 68
                  Height = 15
                  Caption = 'Border width'
                end
                object lOSMMarkerDotRadius: TLabel
                  Left = 88
                  Top = 102
                  Width = 35
                  Height = 15
                  Caption = 'Radius'
                end
                object lOSMMarkerDotDiameter: TLabel
                  Left = 144
                  Top = 102
                  Width = 48
                  Height = 15
                  Caption = 'Diameter'
                end
                object lOSMMarkerDotGlyphFontSize: TLabel
                  Left = 208
                  Top = 102
                  Width = 56
                  Height = 15
                  Caption = 'Glyph font'
                end
                object lOSMMarkerDotPulseRadius: TLabel
                  Left = 272
                  Top = 102
                  Width = 63
                  Height = 15
                  Caption = 'Pulse radius'
                end
                object lOSMMarkerDotPulseDuration: TLabel
                  Left = 344
                  Top = 102
                  Width = 76
                  Height = 15
                  Caption = 'Pulse duration'
                end
                object lOSMMarkerDotShadowBlur: TLabel
                  Left = 424
                  Top = 102
                  Width = 66
                  Height = 15
                  Caption = 'Shadow blur'
                end
                object lOSMMarkerDotOpacity: TLabel
                  Left = 496
                  Top = 102
                  Width = 41
                  Height = 15
                  Caption = 'Opacity'
                end
                object lOSMMarkerDotZIndex: TLabel
                  Left = 560
                  Top = 102
                  Width = 35
                  Height = 15
                  Caption = 'ZIndex'
                end
                object lOSMMarkerDotRotation: TLabel
                  Left = 224
                  Top = 56
                  Width = 45
                  Height = 15
                  Caption = 'Rotation'
                end
                object lOSMMarkerDotAnchorX: TLabel
                  Left = 288
                  Top = 56
                  Width = 67
                  Height = 15
                  Caption = 'Anchor X off.'
                end
                object lOSMMarkerDotAnchorY: TLabel
                  Left = 352
                  Top = 56
                  Width = 67
                  Height = 15
                  Caption = 'Anchor Y off.'
                end
                object cbOSMMarkerDotColor: TColorBox
                  Left = 16
                  Top = 27
                  Width = 90
                  Height = 22
                  TabOrder = 0
                end
                object cbOSMMarkerDotBorderColor: TColorBox
                  Left = 120
                  Top = 27
                  Width = 90
                  Height = 22
                  TabOrder = 1
                end
                object cbOSMMarkerDotGlyphTextColor: TColorBox
                  Left = 224
                  Top = 27
                  Width = 90
                  Height = 22
                  TabOrder = 2
                end
                object cbOSMMarkerDotPulseColor: TColorBox
                  Left = 328
                  Top = 27
                  Width = 90
                  Height = 22
                  TabOrder = 3
                end
                object cbOSMMarkerDotShadowColor: TColorBox
                  Left = 432
                  Top = 27
                  Width = 90
                  Height = 22
                  TabOrder = 4
                end
                object eOSMMarkerDotScale: TEdit
                  Left = 536
                  Top = 27
                  Width = 48
                  Height = 23
                  TabOrder = 5
                  Text = '1'
                end
                object eOSMMarkerDotGlyphText: TEdit
                  Left = 16
                  Top = 73
                  Width = 66
                  Height = 23
                  TabOrder = 6
                end
                object eOSMMarkerDotPopupText: TEdit
                  Left = 88
                  Top = 73
                  Width = 114
                  Height = 23
                  TabOrder = 7
                  Visible = False
                end
                object cbOSMMarkerDotPulseEnabled: TCheckBox
                  Left = 466
                  Top = 69
                  Width = 52
                  Height = 17
                  Caption = 'Pulse'
                  TabOrder = 8
                end
                object cbOSMMarkerDotShadowEnabled: TCheckBox
                  Left = 534
                  Top = 79
                  Width = 63
                  Height = 17
                  Caption = 'Shadow'
                  TabOrder = 9
                end
                object cbOSMMarkerDotPopupEnabled: TCheckBox
                  Left = 534
                  Top = 56
                  Width = 56
                  Height = 17
                  Caption = 'Popup'
                  Checked = True
                  State = cbChecked
                  TabOrder = 10
                end
                object eOSMMarkerDotBorderWidth: TEdit
                  Left = 16
                  Top = 119
                  Width = 48
                  Height = 23
                  TabOrder = 11
                  Text = '0'
                end
                object eOSMMarkerDotRadius: TEdit
                  Left = 88
                  Top = 119
                  Width = 48
                  Height = 23
                  TabOrder = 12
                  Text = '0'
                end
                object eOSMMarkerDotDiameter: TEdit
                  Left = 144
                  Top = 119
                  Width = 48
                  Height = 23
                  TabOrder = 13
                  Text = '0'
                end
                object eOSMMarkerDotGlyphFontSize: TEdit
                  Left = 208
                  Top = 119
                  Width = 48
                  Height = 23
                  TabOrder = 14
                  Text = '0'
                end
                object eOSMMarkerDotPulseRadius: TEdit
                  Left = 272
                  Top = 119
                  Width = 48
                  Height = 23
                  TabOrder = 15
                  Text = '0'
                end
                object eOSMMarkerDotPulseDuration: TEdit
                  Left = 344
                  Top = 119
                  Width = 48
                  Height = 23
                  TabOrder = 16
                  Text = '0'
                end
                object eOSMMarkerDotShadowBlur: TEdit
                  Left = 424
                  Top = 119
                  Width = 48
                  Height = 23
                  TabOrder = 17
                  Text = '0'
                end
                object eOSMMarkerDotOpacity: TEdit
                  Left = 496
                  Top = 119
                  Width = 48
                  Height = 23
                  TabOrder = 18
                  Text = '1'
                end
                object eOSMMarkerDotZIndex: TEdit
                  Left = 560
                  Top = 119
                  Width = 48
                  Height = 23
                  TabOrder = 19
                  Text = '0'
                end
                object eOSMMarkerDotRotation: TEdit
                  Left = 224
                  Top = 73
                  Width = 48
                  Height = 23
                  TabOrder = 20
                  Text = '0'
                end
                object eOSMMarkerDotAnchorX: TEdit
                  Left = 288
                  Top = 73
                  Width = 48
                  Height = 23
                  TabOrder = 21
                  Text = '0'
                end
                object eOSMMarkerDotAnchorY: TEdit
                  Left = 352
                  Top = 73
                  Width = 48
                  Height = 23
                  TabOrder = 22
                  Text = '0'
                end
              end
            end
          end
        end
        object tsOSMPopups: TTabSheet
          Caption = 'Popups'
          ImageIndex = 3
          DesignSize = (
            1219
            175)
          object lOSMPopupLat: TLabel
            Left = 344
            Top = 8
            Width = 16
            Height = 15
            Caption = 'Lat'
          end
          object lOSMPopupLng: TLabel
            Left = 432
            Top = 8
            Width = 20
            Height = 15
            Caption = 'Lng'
          end
          object lOSMPopupAnchorObjectId: TLabel
            Left = 520
            Top = 8
            Width = 88
            Height = 15
            Caption = 'Anchor object id'
          end
          object lOSMPopupMaxWidth: TLabel
            Left = 344
            Top = 56
            Width = 55
            Height = 15
            Caption = 'Max width'
          end
          object lOSMPopupCssClass: TLabel
            Left = 432
            Top = 56
            Width = 59
            Height = 15
            Caption = 'Preset style'
          end
          object lOSMPopupContentType: TLabel
            Left = 584
            Top = 56
            Width = 69
            Height = 15
            Caption = 'Content type'
          end
          object lOSMPopupContent: TLabel
            Left = 688
            Top = 8
            Width = 43
            Height = 15
            Caption = 'Content'
          end
          object lbOSMPopups: TListBox
            Left = 8
            Top = 8
            Width = 220
            Height = 163
            ItemHeight = 15
            TabOrder = 0
          end
          object bOSMAddPopup: TButton
            Left = 236
            Top = 8
            Width = 96
            Height = 25
            Caption = 'Add Popup'
            TabOrder = 1
          end
          object bOSMDeletePopup: TButton
            Left = 236
            Top = 39
            Width = 96
            Height = 25
            Caption = 'Delete Popup'
            TabOrder = 2
          end
          object bOSMClearPopups: TButton
            Left = 236
            Top = 70
            Width = 96
            Height = 25
            Caption = 'Clear Popups'
            TabOrder = 3
          end
          object bOSMUpdatePopup: TButton
            Left = 236
            Top = 101
            Width = 96
            Height = 25
            Caption = 'Update Popup'
            TabOrder = 4
          end
          object bOSMPopupUseSelectedMarker: TButton
            Left = 236
            Top = 132
            Width = 96
            Height = 25
            Caption = 'Use Sel. Marker'
            TabOrder = 5
          end
          object eOSMPopupLat: TEdit
            Left = 344
            Top = 23
            Width = 80
            Height = 23
            TabOrder = 6
            Text = '41.3874'
          end
          object eOSMPopupLng: TEdit
            Left = 432
            Top = 23
            Width = 80
            Height = 23
            TabOrder = 7
            Text = '2.1686'
          end
          object eOSMPopupAnchorObjectId: TEdit
            Left = 520
            Top = 23
            Width = 152
            Height = 23
            TabOrder = 8
          end
          object eOSMPopupMaxWidth: TEdit
            Left = 344
            Top = 71
            Width = 80
            Height = 23
            TabOrder = 9
            Text = '0'
          end
          object cbOSMPopupCssClass: TComboBox
            Left = 432
            Top = 71
            Width = 144
            Height = 23
            Style = csDropDownList
            TabOrder = 10
          end
          object cbOSMPopupContentType: TComboBox
            Left = 584
            Top = 71
            Width = 88
            Height = 23
            Style = csDropDownList
            TabOrder = 11
          end
          object mOSMPopupContent: TMemo
            Left = 688
            Top = 23
            Width = 523
            Height = 108
            Anchors = [akLeft, akTop, akRight, akBottom]
            ScrollBars = ssVertical
            TabOrder = 12
          end
          object cbOSMPopupVisible: TCheckBox
            Left = 344
            Top = 112
            Width = 65
            Height = 17
            Caption = 'Visible'
            Checked = True
            State = cbChecked
            TabOrder = 13
          end
          object cbOSMPopupCloseButton: TCheckBox
            Left = 432
            Top = 112
            Width = 97
            Height = 17
            Caption = 'Close button'
            Checked = True
            State = cbChecked
            TabOrder = 14
          end
          object cbOSMPopupCloseOnClick: TCheckBox
            Left = 544
            Top = 112
            Width = 97
            Height = 17
            Caption = 'Close on click'
            Checked = True
            State = cbChecked
            TabOrder = 15
          end
          object cbOSMPopupCloseOnMove: TCheckBox
            Left = 344
            Top = 136
            Width = 113
            Height = 17
            Caption = 'Close on move'
            TabOrder = 16
          end
          object cbOSMPopupCloseOthersBeforeOpen: TCheckBox
            Left = 472
            Top = 136
            Width = 177
            Height = 17
            Caption = 'Close others before open'
            TabOrder = 17
          end
        end
      end
    end
  end
  object pRight: TPanel
    Left = 956
    Top = 235
    Width = 279
    Height = 478
    Align = alRight
    Caption = 'pRight'
    TabOrder = 2
    object lStatus: TLabel
      Left = 1
      Top = 1
      Width = 277
      Height = 15
      Align = alTop
      Caption = 'Status:'
      ExplicitWidth = 35
    end
    object mLog: TMemo
      Left = 1
      Top = 16
      Width = 277
      Height = 461
      Align = alClient
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
  object GMMap: TGMLibVclMap
    Circles = <
      item
        Options.Center.Lat = 33.678000000000000000
        Options.Center.Lng = -116.242500000000000000
        Options.Radius = 1000.000000000000000000
        Options.FillColor = clRed
        Options.FillOpacity = 0.350000000000000000
        Options.StrokeColor = clRed
        Options.StrokeOpacity = 1.000000000000000000
      end>
    InfoWindows.CloseOthersBeforeOpen = True
    InfoWindows = <
      item
      end>
    Markers = <
      item
        Options.ContentMode = mcmPin
        Options.PinOptions.Scale = 1.000000000000000000
        Options.Title = 'designTime'
      end>
    GroundOverlays = <>
    Layers.Kml.ZIndex = 0
    Polygons = <
      item
        Options.FillOpacity = 0.350000000000000000
        Options.StrokeOpacity = 1.000000000000000000
        Options.FillColor = clRed
        Options.Path = <
          item
            Lat = 41.392800000000000000
            Lng = 2.154800000000000000
          end
          item
            Lat = 41.392800000000000000
            Lng = 2.181200000000000000
          end
          item
            Lat = 41.378200000000000000
            Lng = 2.181200000000000000
          end>
        Options.StrokeColor = clRed
      end>
    Polylines = <
      item
        Options.Path = <
          item
            Lat = 42.501500000000000000
            Lng = 1.514500000000000000
          end
          item
            Lat = 42.510000000000000000
            Lng = 1.520000000000000000
          end>
        Options.StrokeOpacity = 1.000000000000000000
        Options.Visible = False
        Options.StrokeColor = clRed
      end>
    Rectangles = <
      item
        Options.FillColor = clRed
        Options.FillOpacity = 0.350000000000000000
        Options.StrokeColor = clRed
        Options.StrokeOpacity = 1.000000000000000000
        Options.Bounds.East = -116.234000000000000000
        Options.Bounds.North = 33.685000000000000000
        Options.Bounds.South = 33.671000000000000000
        Options.Bounds.West = -116.251000000000000000
      end>
    OnBoundsChanged = MapBoundsChanged
    OnCenterChanged = MapCenterChanged
    OnContextMenu = MapContextMenu
    OnDblClick = MapDblClick
    OnDrag = MapDrag
    OnDragEnd = MapDragEnd
    OnDragStart = MapDragStart
    OnHeadingChanged = MapHeadingChanged
    OnIdle = MapIdle
    OnMapClick = MapMapClick
    OnMapTypeIdChanged = MapMapTypeIdChanged
    OnMapReady = MapMapReady
    OnMouseOut = MapMouseOut
    OnMouseOver = MapMouseOver
    OnMouseMove = MapMouseMove
    OnProjectionChanged = MapProjectionChanged
    OnRenderingTypeChanged = MapRenderingTypeChanged
    OnTilesLoaded = MapTilesLoaded
    OnTiltChanged = MapTiltChanged
    OnZoomChanged = MapZoomChanged
    Browser = EdgeBrowser1
    Left = 272
    Top = 432
  end
  object OSMMap: TOSMLibVclMap
    OfflineStoragePath = 'C:\Users\cadetill\AppData\Local\Temp\GMLib\OSM'
    MaxZoom = 22.000000000000000000
    MaxPitch = 60.000000000000000000
    MapId = 'OSMLib_MAP'
    Markers = <>
    Popups = <>
    StyleUrl = 'https://tiles.openfreemap.org/styles/bright'
    MapLibreCssUrl = 'https://unpkg.com/maplibre-gl@5.6.2/dist/maplibre-gl.css'
    MapLibreJsUrl = 'https://unpkg.com/maplibre-gl@5.6.2/dist/maplibre-gl.js'
    Zoom = 1.000000000000000000
    Left = 368
    Top = 432
  end
end
