object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'MainFrm'
  ClientHeight = 587
  ClientWidth = 1009
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCloseQuery = FormCloseQuery
  TextHeight = 15
  object CEFWindowParent1: TCEFWindowParent
    Left = 0
    Top = 0
    Width = 638
    Height = 587
    Align = alClient
    TabStop = True
    TabOrder = 0
    ExplicitLeft = -208
    ExplicitTop = 65
  end
  inline MakerFrame1: TMakerFrame
    Left = 638
    Top = 0
    Width = 371
    Height = 587
    Align = alRight
    TabOrder = 1
    ExplicitLeft = 638
    ExplicitHeight = 587
    inherited pcPages: TPageControl
      Height = 466
      ExplicitHeight = 466
      inherited tsMakers: TTabSheet
        ExplicitHeight = 436
        inherited lbMarkers: TListBox
          Height = 380
          ExplicitHeight = 380
        end
      end
    end
  end
  object GMMapChrm1: TGMMapChrm
    Browser = Chromium1
    MapOptions.Center.Lat = 42.539899000000000000
    MapOptions.Center.Lng = 1.578505000000000000
    MapOptions.ClickableIcons = True
    MapOptions.GestureHandling = ghAuto
    MapOptions.IsFractionalZoomEnabled = True
    MapOptions.Restriction.StrictBounds = False
    MapOptions.Restriction.Enabled = False
    Markers.Markers = <
      item
        Name = 'TGMMarker'
        Icon.Symbol.FillColor = clBlack
        Icon.Symbol.StrokeColor = clBlack
        Icon.Symbol.Path = spFORWARD_OPEN_ARROW
        Icon.Symbol.Rotation = 0
        Icon.Symbol.Scale = 1
        Icon.Symbol.StrokeOpacity = 1.000000000000000000
        Icon.Symbol.StrokeWeight = 1
        Icon.Icon.ScaledSize = 0
        LabelText.Color = clBlack
        LabelText.FontFamily = 'Arial'
        LabelText.FontSize = 14
        LabelText.FontWeight = 0
        Animation = aniNONE
        Clickable = True
        CollisionBehavior = cbNONE
        CrossOnDrag = True
        Draggable = False
        Opacity = 1.000000000000000000
        Optimized = True
        Title = 'TGMMarker'
        Visible = True
      end>
    Markers.AutoUpdate = False
    APILang = lSpanish
    APIRegion = rSpain
    TrafficLayer.Show = False
    TrafficLayer.TrafficLayerOptions.AutoRefresh = True
    TransitLayer.Show = False
    ByciclingLayer.Show = False
    KmlLayer.Show = False
    Left = 136
    Top = 304
  end
  object Chromium1: TChromium
    OnAfterCreated = Chromium1AfterCreated
    OnBeforeClose = Chromium1BeforeClose
    OnClose = Chromium1Close
    Left = 50
    Top = 302
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 300
    OnTimer = Timer1Timer
    Left = 49
    Top = 225
  end
end
