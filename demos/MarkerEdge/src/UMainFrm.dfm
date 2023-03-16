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
    Width = 626
    Height = 505
    Align = alClient
    TabOrder = 0
    UserDataFolder = '%LOCALAPPDATA%\bds.exe.WebView2'
  end
  inline MarkerFrame1: TMarkerFrame
    Left = 626
    Top = 0
    Width = 371
    Height = 505
    Align = alRight
    TabOrder = 1
    ExplicitLeft = 626
    ExplicitHeight = 505
    inherited pcPages: TPageControl
      Height = 368
      ActivePage = MarkerFrame1.tsGeneral
      ExplicitHeight = 368
      inherited tsGeneral: TTabSheet
        ExplicitHeight = 338
      end
      inherited tsMarker: TTabSheet
        ExplicitHeight = 338
      end
    end
  end
  object GMMapEdge1: TGMMapEdge
    Browser = EdgeBrowser1
    MapOptions.Center.Lat = 42.539899000000000000
    MapOptions.Center.Lng = 1.578505000000000000
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
