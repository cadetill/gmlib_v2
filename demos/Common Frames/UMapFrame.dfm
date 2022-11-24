object MapFrame: TMapFrame
  Left = 0
  Top = 0
  Width = 376
  Height = 608
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
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
  end
  object pcPages: TPageControl
    Left = 0
    Top = 65
    Width = 376
    Height = 543
    ActivePage = tsMapOptions
    Align = alClient
    TabOrder = 1
    object tsGeneral: TTabSheet
      Caption = 'General'
      object lIntervalEvents: TLabel
        Left = 16
        Top = 194
        Width = 83
        Height = 17
        Caption = 'Interval Events'
      end
      object lAPIVersion: TLabel
        Left = 16
        Top = 136
        Width = 61
        Height = 17
        Caption = 'APIVersion'
      end
      object lAPILang: TLabel
        Left = 16
        Top = 88
        Width = 46
        Height = 17
        Caption = 'APILang'
      end
      object lAPIKey: TLabel
        Left = 16
        Top = 24
        Width = 39
        Height = 17
        Caption = 'APIKey'
      end
      object lAPIRegion: TLabel
        Left = 127
        Top = 88
        Width = 59
        Height = 17
        Caption = 'APIRegion'
      end
      object lLanguage: TLabel
        Left = 16
        Top = 280
        Width = 57
        Height = 17
        Caption = 'Language'
      end
      object Label1: TLabel
        Left = 64
        Top = 28
        Width = 278
        Height = 15
        Caption = '(you need to put an API Key to use some features)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object eIntervalEvents: TSpinEdit
        Left = 16
        Top = 218
        Width = 81
        Height = 27
        MaxValue = 1000
        MinValue = 1
        TabOrder = 0
        Value = 50
        OnChange = eIntervalEventsChange
      end
      object cbAPIVersion: TComboBox
        Left = 16
        Top = 160
        Width = 105
        Height = 22
        Style = csOwnerDrawFixed
        TabOrder = 1
        OnChange = cbAPIVersionChange
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
      object eAPIKey: TEdit
        Left = 16
        Top = 48
        Width = 273
        Height = 25
        TabOrder = 3
        OnChange = eAPIKeyChange
      end
      object cbAPIRegion: TComboBox
        Left = 127
        Top = 112
        Width = 162
        Height = 22
        Style = csOwnerDrawFixed
        TabOrder = 4
        OnChange = cbAPIRegionChange
      end
      object cbLanguage: TComboBox
        Left = 16
        Top = 304
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
      object pcObjects: TPageControl
        Left = 0
        Top = 201
        Width = 368
        Height = 310
        ActivePage = tsFullScreenControl
        Align = alClient
        TabOrder = 0
        object tsFullScreenControl: TTabSheet
          Caption = 'FullScreen'
          object lFSPosition: TLabel
            Left = 16
            Top = 48
            Width = 46
            Height = 17
            Caption = 'Position'
          end
          object cbFullScreenControl: TCheckBox
            Left = 16
            Top = 16
            Width = 162
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
            Top = 120
            Width = 46
            Height = 17
            Caption = 'Position'
          end
          object lMTStyle: TLabel
            Left = 8
            Top = 148
            Width = 27
            Height = 17
            Caption = 'Style'
          end
          object lMTIds: TLabel
            Left = 176
            Top = 70
            Width = 17
            Height = 17
            Caption = 'Ids'
          end
          object lMapTypeId: TLabel
            Left = 8
            Top = 24
            Width = 65
            Height = 17
            Caption = 'MapTypeId'
          end
          object cbMTPosition: TComboBox
            Left = 65
            Top = 117
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
            Height = 137
            ItemHeight = 17
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
            Top = 145
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
            Top = 53
            Width = 275
            Height = 64
            Caption = 'NE'
            TabOrder = 2
            object lRNELat: TLabel
              Left = 16
              Top = 32
              Width = 17
              Height = 17
              Caption = 'Lat'
            end
            object lRNELng: TLabel
              Left = 146
              Top = 32
              Width = 21
              Height = 17
              Caption = 'Lng'
            end
            object eRNELat: TEdit
              Left = 40
              Top = 29
              Width = 94
              Height = 25
              TabOrder = 0
              OnChange = eRNELatChange
            end
            object eRNELng: TEdit
              Left = 173
              Top = 29
              Width = 94
              Height = 25
              TabOrder = 1
              OnChange = eRNELngChange
            end
          end
          object gbRSW: TGroupBox
            Left = 4
            Top = 119
            Width = 275
            Height = 64
            Caption = 'SW'
            TabOrder = 3
            object lRSWLat: TLabel
              Left = 16
              Top = 32
              Width = 17
              Height = 17
              Caption = 'Lat'
            end
            object lRSWLng: TLabel
              Left = 146
              Top = 32
              Width = 21
              Height = 17
              Caption = 'Lng'
            end
            object eRSWLat: TEdit
              Left = 40
              Top = 29
              Width = 94
              Height = 25
              TabOrder = 0
              OnChange = eRSWLatChange
            end
            object eRSWLng: TEdit
              Left = 173
              Top = 29
              Width = 94
              Height = 25
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
            Width = 46
            Height = 17
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
            Width = 27
            Height = 17
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
            Width = 46
            Height = 17
            Caption = 'Position'
          end
          object cbStreetViewControl: TCheckBox
            Left = 32
            Top = 32
            Width = 162
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
            Width = 46
            Height = 17
            Caption = 'Position'
          end
          object lZoom: TLabel
            Left = 32
            Top = 24
            Width = 34
            Height = 17
            Caption = 'Zoom'
          end
          object lMaxZoom: TLabel
            Left = 8
            Top = 136
            Width = 59
            Height = 17
            Caption = 'MaxZoom'
          end
          object lMinZoom: TLabel
            Left = 151
            Top = 136
            Width = 56
            Height = 17
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
            Height = 25
            TabOrder = 2
            OnChange = eZoomChange
          end
          object eMaxZoom: TEdit
            Left = 83
            Top = 133
            Width = 54
            Height = 25
            TabOrder = 3
            OnChange = eMaxZoomChange
          end
          object eMinZoom: TEdit
            Left = 226
            Top = 133
            Width = 55
            Height = 25
            TabOrder = 4
            OnChange = eMinZoomChange
          end
        end
      end
      object pMapOptions: TPanel
        Left = 0
        Top = 0
        Width = 368
        Height = 201
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object lBackgroundColor: TLabel
          Left = 8
          Top = 15
          Width = 101
          Height = 17
          Caption = 'BackgroundColor'
        end
        object cbIsFractionalZoomEnabled: TCheckBox
          Left = 8
          Top = 166
          Width = 209
          Height = 17
          Caption = 'IsFractionalZoomEnabled'
          TabOrder = 0
          OnClick = cbIsFractionalZoomEnabledClick
        end
        object cbNoClear: TCheckBox
          Left = 8
          Top = 143
          Width = 125
          Height = 17
          Caption = 'NoClear'
          TabOrder = 1
          OnClick = cbNoClearClick
        end
        object cbKeyboardShortcuts: TCheckBox
          Left = 152
          Top = 143
          Width = 193
          Height = 17
          Caption = 'KeyboardShortcuts'
          TabOrder = 2
          OnClick = cbKeyboardShortcutsClick
        end
        object cbDisableDoubleClickZoom: TCheckBox
          Left = 152
          Top = 120
          Width = 193
          Height = 17
          Caption = 'DisableDoubleClickZoom'
          TabOrder = 3
          OnClick = cbDisableDoubleClickZoomClick
        end
        object cbClickableIcons: TCheckBox
          Left = 8
          Top = 120
          Width = 125
          Height = 17
          Caption = 'ClickableIcons'
          TabOrder = 4
          OnClick = cbClickableIconsClick
        end
        object gbCenter: TGroupBox
          Left = 8
          Top = 41
          Width = 285
          Height = 64
          Caption = 'Center'
          TabOrder = 5
          object lLat: TLabel
            Left = 16
            Top = 32
            Width = 17
            Height = 17
            Caption = 'Lat'
          end
          object lLng: TLabel
            Left = 149
            Top = 32
            Width = 21
            Height = 17
            Caption = 'Lng'
          end
          object eLat: TEdit
            Left = 43
            Top = 29
            Width = 94
            Height = 25
            TabOrder = 0
            OnChange = eLatChange
          end
          object eLng: TEdit
            Left = 176
            Top = 29
            Width = 94
            Height = 25
            TabOrder = 1
            OnChange = eLngChange
          end
        end
        object cbBackgroundColor: TColorBox
          Left = 131
          Top = 13
          Width = 105
          Height = 22
          TabOrder = 6
          OnChange = cbBackgroundColorChange
        end
      end
    end
  end
end
