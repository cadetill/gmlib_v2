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
    Width = 640
    Height = 505
    Align = alClient
    TabOrder = 0
    ExplicitTop = 81
    ExplicitWidth = 997
    ExplicitHeight = 424
  end
  inline LayersFrame1: TLayersFrame
    Left = 640
    Top = 0
    Width = 357
    Height = 505
    Align = alRight
    TabOrder = 1
    ExplicitLeft = 640
    ExplicitWidth = 357
    ExplicitHeight = 505
    inherited cbActive: TCheckBox
      Width = 339
    end
    inherited pcPages: TPageControl
      Width = 357
      Height = 440
      ActivePage = LayersFrame1.tsGeneral
      inherited tsGeneral: TTabSheet
        ExplicitWidth = 349
        ExplicitHeight = 410
      end
      inherited tsMapOptions: TTabSheet
        ExplicitHeight = 410
        inherited pcObjects: TPageControl
          Height = 410
          inherited tsTrafficLayer: TTabSheet
            ExplicitHeight = 380
          end
        end
      end
    end
  end
  object GMMapEdge1: TGMMapEdge
    Browser = EdgeBrowser1
    MapOptions.Center.Lat = 41.865838000000000000
    MapOptions.Center.Lng = -87.645589000000000000
    MapOptions.ClickableIcons = True
    MapOptions.GestureHandling = ghAuto
    MapOptions.IsFractionalZoomEnabled = True
    MapOptions.Restriction.StrictBounds = False
    MapOptions.Restriction.Enabled = False
    APIRegion = rUnited_States
    TrafficLayer.Show = False
    TrafficLayer.TrafficLayerOptions.AutoRefresh = True
    TransitLayer.Show = False
    ByciclingLayer.Show = False
    KmlLayer.Show = False
    KmlLayer.KmlLayerOptions.Url = 'https://googlearchive.github.io/js-v2-samples/ggeoxml/cta.kml'
    Left = 184
    Top = 216
  end
end
