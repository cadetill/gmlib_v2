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
  object EdgeBrowser1: TEdgeBrowser
    Left = 0
    Top = 0
    Width = 640
    Height = 505
    Align = alClient
    TabOrder = 0
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
      ExplicitWidth = 339
    end
    inherited pAPIKey: TPanel
      Width = 357
      ExplicitWidth = 357
      inherited lAPIKey: TLabel
        Width = 39
        Height = 17
        ExplicitWidth = 39
        ExplicitHeight = 17
      end
      inherited eAPIKey: TEdit
        Height = 25
        ExplicitHeight = 25
      end
    end
    inherited pcObjects: TPageControl
      Width = 357
      Height = 368
      ExplicitWidth = 357
      ExplicitHeight = 368
      inherited tsTrafficLayer: TTabSheet
        ExplicitTop = 28
        ExplicitWidth = 349
        ExplicitHeight = 336
      end
      inherited tsTransitLayer: TTabSheet
        ExplicitTop = 28
        ExplicitHeight = 350
      end
      inherited tsByciclingLayer: TTabSheet
        ExplicitTop = 28
        ExplicitHeight = 350
      end
      inherited tsKmlLayer: TTabSheet
        ExplicitTop = 28
        ExplicitHeight = 350
        inherited lKmlUrl: TLabel
          Width = 17
          Height = 17
          ExplicitWidth = 17
          ExplicitHeight = 17
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
    Markers.MarkersList = <>
    Markers.AutoUpdate = False
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
