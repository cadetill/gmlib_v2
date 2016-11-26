object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'MegaDemo GMLib'
  ClientHeight = 544
  ClientWidth = 971
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 637
    Top = 0
    Height = 544
    Align = alRight
    ExplicitLeft = 496
    ExplicitTop = 240
    ExplicitHeight = 100
  end
  object WebBrowser1: TWebBrowser
    Left = 0
    Top = 0
    Width = 637
    Height = 544
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 3
    ExplicitTop = 43
    ExplicitWidth = 406
    ExplicitHeight = 319
    ControlData = {
      4C000000D6410000393800000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object pcPages: TPageControl
    Left = 640
    Top = 0
    Width = 331
    Height = 544
    ActivePage = TabSheet1
    Align = alRight
    TabOrder = 1
    object tsMap: TTabSheet
      Caption = 'Map'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        323
        516)
      object bMapActive: TButton
        Left = 16
        Top = 9
        Width = 73
        Height = 25
        Caption = 'Active'
        TabOrder = 0
        OnClick = bMapActiveClick
      end
      object ScrollBox1: TScrollBox
        Left = 2
        Top = 40
        Width = 317
        Height = 475
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 1
        object Panel1: TPanel
          Left = 0
          Top = 0
          Width = 296
          Height = 242
          Align = alTop
          BevelOuter = bvNone
          Caption = ' '
          TabOrder = 0
          object Label4: TLabel
            Left = 159
            Top = 176
            Width = 78
            Height = 13
            Caption = 'Dragging Cursor'
          end
          object Label3: TLabel
            Left = 16
            Top = 176
            Width = 84
            Height = 13
            Caption = 'Draggable Cursor'
          end
          object Label2: TLabel
            Left = 16
            Top = 56
            Width = 74
            Height = 13
            Caption = 'Center (lat/lng)'
          end
          object Label1: TLabel
            Left = 16
            Top = 8
            Width = 84
            Height = 13
            Caption = 'Background Color'
          end
          object bMapFullScreenControl: TSpeedButton
            Left = 152
            Top = 221
            Width = 22
            Height = 20
            Caption = '+'
            OnClick = bMapFullScreenControlClick
          end
          object cbMapFullScreenControl: TCheckBox
            Left = 16
            Top = 222
            Width = 134
            Height = 17
            Caption = 'Full Screen Control'
            TabOrder = 0
            OnClick = cbMapFullScreenControlClick
          end
          object eMapDraggableCursor: TEdit
            Left = 16
            Top = 195
            Width = 137
            Height = 21
            TabOrder = 1
            Text = 'eMapDraggableCursor'
          end
          object eMapDraggingCursor: TEdit
            Left = 159
            Top = 195
            Width = 137
            Height = 21
            TabOrder = 2
            Text = 'eMapDraggingCursor'
          end
          object cbMapDraggable: TCheckBox
            Left = 16
            Top = 151
            Width = 145
            Height = 17
            Caption = 'Draggable'
            TabOrder = 3
            OnClick = cbMapDraggableClick
          end
          object cbMapDisableDoubleClickZoom: TCheckBox
            Left = 16
            Top = 128
            Width = 145
            Height = 17
            Caption = 'Disable DoubleClick Zoom'
            TabOrder = 4
            OnClick = cbMapDisableDoubleClickZoomClick
          end
          object cbMapDisableDefaultUI: TCheckBox
            Left = 16
            Top = 104
            Width = 113
            Height = 17
            Caption = 'Disable Default UI'
            TabOrder = 5
            OnClick = cbMapDisableDefaultUIClick
          end
          object eMapCenterLat: TEdit
            Left = 16
            Top = 75
            Width = 89
            Height = 21
            TabOrder = 6
            Text = 'eMapCenterLat'
          end
          object eMapCenterLng: TEdit
            Left = 103
            Top = 75
            Width = 91
            Height = 21
            TabOrder = 7
            Text = 'eMapCenterLng'
          end
          object bMapSetCenter: TButton
            Left = 196
            Top = 72
            Width = 25
            Height = 25
            Caption = 'Set'
            TabOrder = 8
            OnClick = bMapSetCenterClick
          end
          object cbMapBgColor: TColorBox
            Left = 16
            Top = 24
            Width = 145
            Height = 22
            TabOrder = 9
            OnChange = cbMapBgColorChange
          end
        end
        object Panel2: TPanel
          Left = 0
          Top = 269
          Width = 296
          Height = 122
          Align = alTop
          BevelOuter = bvNone
          Caption = ' '
          TabOrder = 1
          object Label5: TLabel
            Left = 16
            Top = 8
            Width = 39
            Height = 13
            Caption = 'Heading'
          end
          object bMapMapTypeControl: TSpeedButton
            Left = 152
            Top = 101
            Width = 22
            Height = 20
            Caption = '+'
            OnClick = bMapMapTypeControlClick
          end
          object eMapHeading: TSpinEdit
            Left = 16
            Top = 24
            Width = 65
            Height = 22
            MaxValue = 0
            MinValue = 0
            TabOrder = 0
            Value = 0
            OnChange = eMapHeadingChange
          end
          object cbMapKeyboardShortcuts: TCheckBox
            Left = 16
            Top = 56
            Width = 113
            Height = 17
            Caption = 'Keyboard Shortcuts'
            TabOrder = 1
            OnClick = cbMapKeyboardShortcutsClick
          end
          object cbMapMapMaker: TCheckBox
            Left = 16
            Top = 80
            Width = 113
            Height = 17
            Caption = 'MapMaker'
            TabOrder = 2
            OnClick = cbMapMapMakerClick
          end
          object cbMapMapTypeControl: TCheckBox
            Left = 16
            Top = 104
            Width = 113
            Height = 17
            Caption = 'MapType Control'
            TabOrder = 3
            OnClick = cbMapMapTypeControlClick
          end
        end
        object pMapFullScreenControl: TPanel
          Left = 0
          Top = 242
          Width = 296
          Height = 27
          Align = alTop
          BevelOuter = bvNone
          Caption = ' '
          Color = 14869218
          ParentBackground = False
          TabOrder = 2
          object Label6: TLabel
            Left = 64
            Top = 8
            Width = 37
            Height = 13
            Caption = 'Position'
          end
          object cbMapFSCPosition: TComboBox
            Left = 107
            Top = 3
            Width = 110
            Height = 21
            Style = csDropDownList
            TabOrder = 0
            OnChange = cbMapFSCPositionChange
            Items.Strings = (
              'cpBOTTOM_CENTER'
              'cpBOTTOM_LEFT'
              'cpBOTTOM_RIGHT'
              'cpLEFT_BOTTOM'
              'cpLEFT_CENTER'
              'cpLEFT_TOP'
              'cpRIGHT_BOTTOM'
              'cpRIGHT_CENTER'
              'cpRIGHT_TOP'
              'cpTOP_CENTER'
              'cpTOP_LEFT'
              'cpTOP_RIGHT')
          end
        end
        object pMapMapTypeControl: TPanel
          Left = 0
          Top = 391
          Width = 296
          Height = 135
          Align = alTop
          Caption = ' '
          Color = 14869218
          ParentBackground = False
          TabOrder = 3
          object Label7: TLabel
            Left = 63
            Top = 88
            Width = 37
            Height = 13
            Caption = 'Position'
          end
          object Style: TLabel
            Left = 76
            Top = 112
            Width = 24
            Height = 13
            Caption = 'Style'
          end
          object Label8: TLabel
            Left = 41
            Top = 6
            Width = 59
            Height = 13
            Caption = 'MapTypeIds'
          end
          object cbMapMTCPosition: TComboBox
            Left = 107
            Top = 83
            Width = 110
            Height = 21
            Style = csDropDownList
            TabOrder = 1
            OnChange = cbMapFSCPositionChange
            Items.Strings = (
              'cpBOTTOM_CENTER'
              'cpBOTTOM_LEFT'
              'cpBOTTOM_RIGHT'
              'cpLEFT_BOTTOM'
              'cpLEFT_CENTER'
              'cpLEFT_TOP'
              'cpRIGHT_BOTTOM'
              'cpRIGHT_CENTER'
              'cpRIGHT_TOP'
              'cpTOP_CENTER'
              'cpTOP_LEFT'
              'cpTOP_RIGHT')
          end
          object cbMapMTCStyle: TComboBox
            Left = 107
            Top = 107
            Width = 110
            Height = 21
            Style = csDropDownList
            TabOrder = 2
            OnChange = cbMapFSCPositionChange
            Items.Strings = (
              'cpBOTTOM_CENTER'
              'cpBOTTOM_LEFT'
              'cpBOTTOM_RIGHT'
              'cpLEFT_BOTTOM'
              'cpLEFT_CENTER'
              'cpLEFT_TOP'
              'cpRIGHT_BOTTOM'
              'cpRIGHT_CENTER'
              'cpRIGHT_TOP'
              'cpTOP_CENTER'
              'cpTOP_LEFT'
              'cpTOP_RIGHT')
          end
          object lbMapMTCMapTypeIds: TCheckListBox
            Left = 107
            Top = 6
            Width = 142
            Height = 75
            ItemHeight = 13
            TabOrder = 0
          end
        end
        object Panel3: TPanel
          Left = 0
          Top = 526
          Width = 296
          Height = 122
          Align = alTop
          BevelOuter = bvNone
          Caption = ' '
          TabOrder = 4
        end
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'TabSheet1'
      ImageIndex = 1
      DesignSize = (
        323
        516)
      object sbMap: TScrollBox
        Left = 6
        Top = 41
        Width = 317
        Height = 475
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 0
      end
    end
  end
  object GMMap1: TGMMap
    MapOptions.Styles = <>
    WebBrowser = WebBrowser1
    Left = 176
    Top = 136
  end
end
