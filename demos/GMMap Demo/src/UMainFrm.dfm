object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'MainFrm'
  ClientHeight = 505
  ClientWidth = 997
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 17
  object Splitter1: TSplitter
    Left = 637
    Top = 0
    Height = 505
    Align = alRight
    ExplicitLeft = 504
    ExplicitTop = 224
    ExplicitHeight = 100
  end
  object EdgeBrowser1: TEdgeBrowser
    Left = 0
    Top = 0
    Width = 637
    Height = 505
    Align = alClient
    TabOrder = 0
  end
  inline MapFrame1: TMapFrame
    Left = 640
    Top = 0
    Width = 357
    Height = 505
    Align = alRight
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    ExplicitLeft = 640
    ExplicitWidth = 357
    ExplicitHeight = 505
    inherited cbActive: TCheckBox
      Width = 339
      ExplicitWidth = 339
    end
    inherited pcPages: TPageControl
      Width = 357
      Height = 440
      ExplicitWidth = 357
      ExplicitHeight = 440
      inherited tsMapOptions: TTabSheet
        ExplicitWidth = 349
        ExplicitHeight = 408
        inherited pcObjects: TPageControl
          Width = 349
          Height = 207
          ExplicitWidth = 349
          ExplicitHeight = 207
          inherited tsFullScreenControl: TTabSheet
            ExplicitWidth = 341
            ExplicitHeight = 175
          end
        end
        inherited pMapOptions: TPanel
          Width = 349
          ExplicitWidth = 349
        end
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
