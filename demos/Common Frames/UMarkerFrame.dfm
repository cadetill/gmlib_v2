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
        308)
      object lMarkersList: TLabel
        Left = 16
        Top = 16
        Width = 78
        Height = 20
        Caption = 'Markers List'
      end
      object lbMarkersList: TListBox
        Left = 16
        Top = 40
        Width = 121
        Height = 241
        Anchors = [akLeft, akTop, akBottom]
        ItemHeight = 20
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
        Width = 69
        Height = 20
        Caption = 'Animation'
      end
      object lCollisionBehavior: TLabel
        Left = 11
        Top = 74
        Width = 115
        Height = 20
        Caption = 'CollisionBehavior'
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
      Width = 46
      Height = 20
      Caption = 'APIKey'
    end
    object eAPIKey: TEdit
      Left = 15
      Top = 32
      Width = 273
      Height = 28
      TabOrder = 0
      OnChange = eAPIKeyChange
    end
  end
end
