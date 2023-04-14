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
    ExplicitWidth = 622
    ExplicitHeight = 504
  end
  inline MarkerFrame1: TMarkerFrame
    Left = 626
    Top = 0
    Width = 371
    Height = 505
    Align = alRight
    TabOrder = 1
    ExplicitLeft = 622
    ExplicitHeight = 504
    inherited pcPages: TPageControl
      Height = 368
      ExplicitHeight = 367
      inherited tsGeneral: TTabSheet
        ExplicitHeight = 338
      end
      inherited tsMarkers: TTabSheet
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
    Markers.MarkersList = <
      item
        Name = 'TGMMarkerItem0'
        Marker.Icon.Symbol.FillColor = clBlack
        Marker.Icon.Symbol.StrokeColor = clBlack
        Marker.Icon.Symbol.Path = spFORWARD_OPEN_ARROW
        Marker.Icon.Symbol.Rotation = 0
        Marker.Icon.Symbol.Scale = 1
        Marker.Icon.Symbol.StrokeOpacity = 1.000000000000000000
        Marker.Icon.Symbol.StrokeWeight = 1
        Marker.Icon.Icon.ScaledSize = 0
        Marker.LabelText.Color = clBlack
        Marker.LabelText.FontFamily = 'Arial'
        Marker.LabelText.FontSize = 14
        Marker.LabelText.FontWeight = 0
        Marker.Animation = aniNONE
        Marker.Clickable = True
        Marker.CollisionBehavior = cbNONE
        Marker.CrossOnDrag = True
        Marker.Draggable = False
        Marker.Opacity = 1.000000000000000000
        Marker.Optimized = True
        Marker.Title = 'TGMMarkerItem0'
        Marker.Visible = True
      end>
    Markers.AutoUpdate = True
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
