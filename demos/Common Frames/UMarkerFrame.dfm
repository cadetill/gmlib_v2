object MarkerFrame: TMarkerFrame
  Left = 0
  Top = 0
  Width = 371
  Height = 480
  TabOrder = 0
  object pcPages: TPageControl
    Left = 0
    Top = 137
    Width = 371
    Height = 343
    ActivePage = tsMarker
    Align = alClient
    TabOrder = 0
    object tsGeneral: TTabSheet
      Caption = 'General'
      object cbAutoUpdate: TCheckBox
        Left = 32
        Top = 32
        Width = 129
        Height = 17
        Caption = 'AutoUpdate'
        TabOrder = 0
      end
    end
    object tsMarkers: TTabSheet
      Caption = 'Markers'
      ImageIndex = 1
      DesignSize = (
        363
        313)
      object lMarkersList: TLabel
        Left = 16
        Top = 16
        Width = 63
        Height = 15
        Caption = 'Markers List'
      end
      object lbMarkersList: TListBox
        Left = 16
        Top = 40
        Width = 121
        Height = 241
        Anchors = [akLeft, akTop, akBottom]
        ItemHeight = 15
        TabOrder = 0
        OnClick = lbMarkersListClick
      end
      object bAdd: TButton
        Left = 160
        Top = 40
        Width = 75
        Height = 25
        Caption = 'Add'
        TabOrder = 1
        OnClick = bAddClick
      end
      object bDel: TButton
        Left = 160
        Top = 72
        Width = 75
        Height = 25
        Caption = 'Del'
        TabOrder = 2
        OnClick = bDelClick
      end
    end
    object tsMarker: TTabSheet
      Caption = 'Marker'
      ImageIndex = 2
      object lAnimation: TLabel
        Left = 11
        Top = 16
        Width = 56
        Height = 15
        Caption = 'Animation'
      end
      object lCollisionBehavior: TLabel
        Left = 11
        Top = 74
        Width = 92
        Height = 15
        Caption = 'CollisionBehavior'
      end
      object lIconUrl: TLabel
        Left = 11
        Top = 154
        Width = 41
        Height = 15
        Caption = 'Icon Url'
      end
      object lLabelText: TLabel
        Left = 11
        Top = 183
        Width = 52
        Height = 15
        Caption = 'Label Text'
      end
      object cbAnimation: TComboBox
        Left = 96
        Top = 13
        Width = 145
        Height = 22
        Style = csOwnerDrawFixed
        TabOrder = 0
        OnChange = cbAnimationChange
      end
      object cbClickable: TCheckBox
        Left = 11
        Top = 48
        Width = 142
        Height = 17
        Caption = 'Clickable'
        TabOrder = 1
        OnClick = cbClickableClick
      end
      object cbCollisionBehavior: TComboBox
        Left = 136
        Top = 71
        Width = 145
        Height = 22
        Style = csOwnerDrawFixed
        TabOrder = 2
        OnChange = cbCollisionBehaviorChange
      end
      object cbCrossOnDrag: TCheckBox
        Left = 11
        Top = 99
        Width = 142
        Height = 17
        Caption = 'CrossOnDrag'
        TabOrder = 3
        OnClick = cbCrossOnDragClick
      end
      object cbDraggable: TCheckBox
        Left = 11
        Top = 123
        Width = 142
        Height = 17
        Caption = 'Draggable'
        TabOrder = 4
        OnClick = cbDraggableClick
      end
      object eIconUrl: TEdit
        Left = 88
        Top = 151
        Width = 121
        Height = 23
        AutoSize = False
        TabOrder = 5
        OnChange = eIconUrlChange
      end
      object eLabelText: TEdit
        Left = 88
        Top = 180
        Width = 121
        Height = 23
        AutoSize = False
        TabOrder = 6
        OnChange = eLabelTextChange
      end
      object gbPosition: TGroupBox
        Left = 11
        Top = 209
        Width = 286
        Height = 64
        Caption = 'Position'
        TabOrder = 7
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
        object eLat: TEdit
          Left = 40
          Top = 29
          Width = 94
          Height = 23
          TabOrder = 0
          OnChange = eLatChange
        end
        object eLng: TEdit
          Left = 173
          Top = 29
          Width = 94
          Height = 23
          TabOrder = 1
          OnChange = eLngChange
        end
      end
      object cbVisible: TCheckBox
        Left = 11
        Top = 287
        Width = 142
        Height = 17
        Caption = 'Visible'
        TabOrder = 8
        OnClick = cbVisibleClick
      end
    end
  end
  object cbActive: TCheckBox
    AlignWithMargins = True
    Left = 15
    Top = 20
    Width = 353
    Height = 42
    Margins.Left = 15
    Margins.Top = 20
    Align = alTop
    Caption = 'Active'
    TabOrder = 1
    OnClick = cbActiveClick
  end
  object pAPIKey: TPanel
    Left = 0
    Top = 65
    Width = 371
    Height = 72
    Align = alTop
    BevelOuter = bvNone
    Caption = ' '
    TabOrder = 2
    object lNeedAPI: TLabel
      Left = 63
      Top = 12
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
    object lAPIKey: TLabel
      Left = 15
      Top = 8
      Width = 37
      Height = 15
      Caption = 'APIKey'
    end
    object eAPIKey: TEdit
      Left = 15
      Top = 32
      Width = 273
      Height = 23
      TabOrder = 0
      OnChange = eAPIKeyChange
    end
  end
end
