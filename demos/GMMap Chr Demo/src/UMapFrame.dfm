object Frame1: TFrame1
  Left = 0
  Top = 0
  Width = 376
  Height = 608
  TabOrder = 0
  PixelsPerInch = 96
  object cbActive: TCheckBox
    AlignWithMargins = True
    Left = 15
    Top = 20
    Width = 358
    Height = 42
    Margins.Left = 15
    Margins.Top = 20
    Align = alTop
    Caption = 'Active'
    TabOrder = 0
    OnClick = cbActiveClick
    ExplicitLeft = 16
    ExplicitTop = 21
    ExplicitWidth = 281
  end
  object pcPages: TPageControl
    Left = 0
    Top = 65
    Width = 376
    Height = 543
    ActivePage = tsMapOptions
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 1
    ExplicitTop = 66
    ExplicitWidth = 299
    ExplicitHeight = 424
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
      end
      object cbAPIVersion: TComboBox
        Left = 16
        Top = 136
        Width = 105
        Height = 22
        Style = csOwnerDrawFixed
        TabOrder = 1
      end
      object cbAPILang: TComboBox
        Left = 16
        Top = 88
        Width = 105
        Height = 22
        Style = csOwnerDrawFixed
        TabOrder = 2
      end
      object eAPIKey: TEdit
        Left = 16
        Top = 40
        Width = 273
        Height = 23
        TabOrder = 3
      end
      object cbAPIRegion: TComboBox
        Left = 127
        Top = 88
        Width = 162
        Height = 22
        Style = csOwnerDrawFixed
        TabOrder = 4
      end
      object cbLanguage: TComboBox
        Left = 16
        Top = 296
        Width = 105
        Height = 22
        Style = csOwnerDrawFixed
        TabOrder = 5
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
        end
        object eLng: TEdit
          Left = 176
          Top = 29
          Width = 94
          Height = 23
          TabOrder = 1
        end
      end
      object cbClickableIcons: TCheckBox
        Left = 8
        Top = 120
        Width = 97
        Height = 17
        Caption = 'ClickableIcons'
        TabOrder = 2
      end
      object cbDisableDoubleClickZoom: TCheckBox
        Left = 120
        Top = 120
        Width = 168
        Height = 17
        Caption = 'DisableDoubleClickZoom'
        TabOrder = 3
      end
      object pcObjects: TPageControl
        Left = 0
        Top = 314
        Width = 368
        Height = 199
        ActivePage = tsLayers
        Align = alBottom
        TabOrder = 4
        ExplicitTop = 195
        ExplicitWidth = 291
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
          end
          object cbFSPosition: TComboBox
            Left = 73
            Top = 45
            Width = 105
            Height = 22
            Style = csOwnerDrawFixed
            TabOrder = 1
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
          end
          object clbMTIds: TCheckListBox
            Left = 176
            Top = 88
            Width = 104
            Height = 65
            ItemHeight = 15
            TabOrder = 1
          end
          object cbMapTypeControl: TCheckBox
            Left = 8
            Top = 72
            Width = 129
            Height = 17
            Caption = 'MapTypeControl'
            TabOrder = 2
          end
          object cbMTStyle: TComboBox
            Left = 65
            Top = 129
            Width = 105
            Height = 22
            Style = csOwnerDrawFixed
            TabOrder = 3
          end
          object cbMapTypeId: TComboBox
            Left = 81
            Top = 21
            Width = 105
            Height = 22
            Style = csOwnerDrawFixed
            TabOrder = 4
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
          end
          object cbRStrictBounds: TCheckBox
            Left = 123
            Top = 16
            Width = 130
            Height = 17
            Caption = 'StrictBounds'
            TabOrder = 1
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
            end
            object eRNELng: TEdit
              Left = 173
              Top = 29
              Width = 94
              Height = 23
              TabOrder = 1
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
            end
            object eRSWLng: TEdit
              Left = 173
              Top = 29
              Width = 94
              Height = 23
              TabOrder = 1
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
          end
          object cbRotPosition: TComboBox
            Left = 81
            Top = 53
            Width = 105
            Height = 22
            Style = csOwnerDrawFixed
            TabOrder = 1
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
          end
          object cbSStyle: TComboBox
            Left = 81
            Top = 57
            Width = 105
            Height = 22
            Style = csOwnerDrawFixed
            TabOrder = 1
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
          end
          object cbSVPosition: TComboBox
            Left = 89
            Top = 61
            Width = 105
            Height = 22
            Style = csOwnerDrawFixed
            TabOrder = 1
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
          end
          object cbZPosition: TComboBox
            Left = 89
            Top = 77
            Width = 105
            Height = 22
            Style = csOwnerDrawFixed
            TabOrder = 1
          end
          object eZoom: TEdit
            Left = 75
            Top = 21
            Width = 94
            Height = 23
            TabOrder = 2
          end
          object eMaxZoom: TEdit
            Left = 75
            Top = 133
            Width = 54
            Height = 23
            TabOrder = 3
          end
          object eMinZoom: TEdit
            Left = 210
            Top = 133
            Width = 55
            Height = 23
            TabOrder = 4
          end
        end
        object tsLayers: TTabSheet
          Caption = 'Layers'
          ImageIndex = 7
          object cbTrafficLayerShow: TCheckBox
            Left = 16
            Top = 16
            Width = 129
            Height = 17
            Caption = 'Show TrafficLayer'
            TabOrder = 0
          end
          object cbTransitLayerShow: TCheckBox
            Left = 16
            Top = 57
            Width = 129
            Height = 17
            Caption = 'Show TransitLayer'
            TabOrder = 1
          end
          object cbByciclingLayerShow: TCheckBox
            Left = 16
            Top = 112
            Width = 129
            Height = 17
            Caption = 'Show ByciclingLayer'
            TabOrder = 2
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
      end
      object cbKeyboardShortcuts: TCheckBox
        Left = 120
        Top = 143
        Width = 137
        Height = 17
        Caption = 'KeyboardShortcuts'
        TabOrder = 6
      end
      object cbIsFractionalZoomEnabled: TCheckBox
        Left = 8
        Top = 166
        Width = 161
        Height = 17
        Caption = 'IsFractionalZoomEnabled'
        TabOrder = 7
      end
    end
  end
end
