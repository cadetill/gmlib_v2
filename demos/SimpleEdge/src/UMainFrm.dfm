object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'MainFrm'
  ClientHeight = 505
  ClientWidth = 997
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 997
    Height = 81
    Align = alTop
    Caption = ' '
    TabOrder = 0
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
  object EdgeBrowser1: TEdgeBrowser
    Left = 0
    Top = 81
    Width = 997
    Height = 424
    Align = alClient
    TabOrder = 1
  end
  object GMMapEdge1: TGMMapEdge
    Browser = EdgeBrowser1
    MapOptions.ClickableIcons = True
    MapOptions.GestureHandling = ghAuto
    MapOptions.IsFractionalZoomEnabled = True
    MapOptions.Restriction.StrictBounds = False
    MapOptions.Restriction.Enabled = False
    Markers.MarkersList = <>
    Markers.AutoUpdate = False
    APIRegion = rUnited_States
    TrafficLayer.Show = False
    TrafficLayer.TrafficLayerOptions.AutoRefresh = True
    TransitLayer.Show = False
    ByciclingLayer.Show = False
    KmlLayer.Show = False
    Left = 184
    Top = 216
  end
end
