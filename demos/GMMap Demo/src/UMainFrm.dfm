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
  object EdgeBrowser1: TEdgeBrowser
    Left = 0
    Top = 0
    Width = 696
    Height = 505
    Align = alClient
    TabOrder = 0
  end
  inline MapFrame1: TMapFrame
    Left = 696
    Top = 0
    Width = 301
    Height = 505
    Align = alRight
    TabOrder = 1
    ExplicitLeft = 696
    ExplicitWidth = 301
    ExplicitHeight = 505
    inherited cbActive: TCheckBox
      Width = 283
      ExplicitWidth = 283
    end
    inherited pcPages: TPageControl
      Width = 301
      Height = 440
      ExplicitWidth = 301
      ExplicitHeight = 440
      inherited tsGeneral: TTabSheet
        ExplicitWidth = 293
        ExplicitHeight = 410
      end
    end
  end
  object GMMapEdge1: TGMMapEdge
    Browser = EdgeBrowser1
    MapOptions.Center.Lat = 42.539899000000000000
    MapOptions.Center.Lng = 1.578505000000000000
    MapOptions.ClickableIcons = True
    MapOptions.FullScreenControl = False
    MapOptions.GestureHandling = ghAuto
    MapOptions.IsFractionalZoomEnabled = True
    MapOptions.MapTypeControlOptions.Position = cpTOP_LEFT
    MapOptions.MapTypeControlOptions.Style = mtcDROPDOWN_MENU
    MapOptions.Restriction.StrictBounds = False
    MapOptions.Restriction.Enabled = False
    Markers.Markers = <>
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
