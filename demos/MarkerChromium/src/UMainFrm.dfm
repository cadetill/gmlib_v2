object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'MainFrm'
  ClientHeight = 587
  ClientWidth = 1009
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCloseQuery = FormCloseQuery
  TextHeight = 17
  object CEFWindowParent1: TCEFWindowParent
    Left = 0
    Top = 0
    Width = 638
    Height = 587
    Align = alClient
    TabStop = True
    TabOrder = 0
  end
  inline MarkerFrame1: TMarkerFrame
    Left = 638
    Top = 0
    Width = 371
    Height = 587
    Align = alRight
    TabOrder = 1
    ExplicitLeft = 638
    ExplicitHeight = 587
    inherited pcPages: TPageControl
      Height = 450
      ExplicitHeight = 450
      inherited tsGeneral: TTabSheet
        ExplicitTop = 28
        ExplicitHeight = 323
      end
      inherited tsMarkers: TTabSheet
        ExplicitTop = 28
        ExplicitHeight = 323
        DesignSize = (
          363
          323)
        inherited lMarkersList: TLabel
          Width = 71
          Height = 17
          ExplicitWidth = 71
          ExplicitHeight = 17
        end
        inherited lbMarkersList: TListBox
          Height = 477
          ItemHeight = 17
          ExplicitHeight = 477
        end
      end
      inherited tsMarker: TTabSheet
        ExplicitTop = 28
        ExplicitHeight = 418
        inherited lAnimation: TLabel
          Width = 58
          Height = 17
          ExplicitWidth = 58
          ExplicitHeight = 17
        end
        inherited lCollisionBehavior: TLabel
          Width = 99
          Height = 17
          ExplicitWidth = 99
          ExplicitHeight = 17
        end
        inherited lIconUrl: TLabel
          Width = 45
          Height = 17
          ExplicitWidth = 45
          ExplicitHeight = 17
        end
        inherited lLabelText: TLabel
          Width = 58
          Height = 17
          ExplicitWidth = 58
          ExplicitHeight = 17
        end
        inherited gbPosition: TGroupBox
          inherited lRNELat: TLabel
            Width = 17
            Height = 17
            ExplicitWidth = 17
            ExplicitHeight = 17
          end
          inherited lRNELng: TLabel
            Width = 21
            Height = 17
            ExplicitWidth = 21
            ExplicitHeight = 17
          end
          inherited eLat: TEdit
            Height = 25
            ExplicitHeight = 25
          end
          inherited eLng: TEdit
            Height = 25
            ExplicitHeight = 25
          end
        end
      end
    end
    inherited pAPIKey: TPanel
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
        Animation = aniBOUNCE
        Clickable = True
        CollisionBehavior = cbNONE
        CrossOnDrag = True
        Draggable = False
        Opacity = 1.000000000000000000
        Optimized = True
        Title = 'TGMMarker'
        Visible = True
      end
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
        Animation = aniDROP
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
    Left = 172
    Top = 376
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
