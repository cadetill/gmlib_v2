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
  PixelsPerInch = 96
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
    end
    inherited pcPages: TPageControl
      Width = 301
      Height = 440
      ActivePage = MapFrame1.tsGeneral
      inherited tsGeneral: TTabSheet
        ExplicitWidth = 293
        ExplicitHeight = 410
      end
      inherited tsMapOptions: TTabSheet
        ExplicitWidth = 293
        ExplicitHeight = 410
        inherited pcObjects: TPageControl
          Top = 211
          Width = 293
          inherited tsZoomControl: TTabSheet
            ExplicitWidth = 285
          end
        end
      end
    end
  end
  object GMMapEdge1: TGMMapEdge
    Browser = EdgeBrowser1
    MapOptions.ClickableIcons = True
    MapOptions.FullScreenControl = False
    MapOptions.GestureHandling = ghAuto
    MapOptions.IsFractionalZoomEnabled = True
    MapOptions.MapTypeControlOptions.Position = cpTOP_LEFT
    MapOptions.MapTypeControlOptions.Style = mtcDROPDOWN_MENU
    MapOptions.Restriction.StrictBounds = False
    MapOptions.Restriction.Enabled = False
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
