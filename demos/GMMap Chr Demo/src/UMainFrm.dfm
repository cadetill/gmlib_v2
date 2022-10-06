object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'MainFrm'
  ClientHeight = 641
  ClientWidth = 1009
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 15
  object CEFWindowParent1: TCEFWindowParent
    Left = 0
    Top = 0
    Width = 656
    Height = 518
    Align = alClient
    TabStop = True
    TabOrder = 0
  end
  object mEvents: TMemo
    Left = 0
    Top = 518
    Width = 1009
    Height = 123
    Align = alBottom
    ScrollBars = ssVertical
    TabOrder = 1
  end
  inline MapFrame1: TMapFrame
    Left = 656
    Top = 0
    Width = 353
    Height = 518
    Align = alRight
    TabOrder = 2
    ExplicitLeft = 656
    ExplicitWidth = 353
    ExplicitHeight = 518
    inherited cbActive: TCheckBox
      Width = 335
      ExplicitWidth = 335
    end
    inherited pcPages: TPageControl
      Width = 353
      Height = 453
      ActivePage = MapFrame1.tsGeneral
      ExplicitWidth = 353
      ExplicitHeight = 453
      inherited tsGeneral: TTabSheet
        ExplicitWidth = 345
        ExplicitHeight = 423
      end
      inherited tsMapOptions: TTabSheet
        ExplicitWidth = 345
        ExplicitHeight = 423
        inherited pcObjects: TPageControl
          Top = 224
          Width = 345
          ActivePage = MapFrame1.tsFullScreenControl
          ExplicitTop = 224
          ExplicitWidth = 345
          inherited tsFullScreenControl: TTabSheet
            ExplicitWidth = 337
          end
          inherited tsMapTypeControl: TTabSheet
            inherited clbMTIds: TCheckListBox
              Width = 137
              ExplicitWidth = 137
            end
          end
          inherited tsRotateControl: TTabSheet
            ExplicitWidth = 337
          end
        end
      end
    end
  end
  object GMMapChrm1: TGMMapChrm
    Browser = Chromium1
    MapOptions.BackgroundColor = clLime
    MapOptions.Center.Lat = 42.539899000000000000
    MapOptions.Center.Lng = 1.578505000000000000
    MapOptions.ClickableIcons = True
    MapOptions.FullScreenControl = False
    MapOptions.GestureHandling = ghAuto
    MapOptions.IsFractionalZoomEnabled = True
    MapOptions.MapTypeControlOptions.Style = mtcDROPDOWN_MENU
    MapOptions.Restriction.StrictBounds = False
    MapOptions.Restriction.Enabled = False
    MapOptions.Zoom = 10
    APILang = lSpanish
    APIRegion = rSpain
    TrafficLayer.Show = False
    TrafficLayer.TrafficLayerOptions.AutoRefresh = True
    TransitLayer.Show = False
    ByciclingLayer.Show = False
    KmlLayer.Show = False
    KmlLayer.KmlLayerOptions.Url = 'https://googlearchive.github.io/js-v2-samples/ggeoxml/cta.kml'
    OnActiveChange = GMMapChrm1ActiveChange
    OnIntervalEventsChange = GMMapChrm1IntervalEventsChange
    OnPrecisionChange = GMMapChrm1PrecisionChange
    OnPropertyChanges = GMMapChrm1PropertyChanges
    OnBoundsChanged = GMMapChrm1BoundsChanged
    OnCenterChanged = GMMapChrm1CenterChanged
    OnClick = GMMapChrm1Click
    OnDblClick = GMMapChrm1DblClick
    OnMouseMove = GMMapChrm1MouseMove
    OnMouseOut = GMMapChrm1MouseOut
    OnMouseOver = GMMapChrm1MouseOver
    OnContextmenu = GMMapChrm1Contextmenu
    OnDrag = GMMapChrm1Drag
    OnDragEnd = GMMapChrm1DragEnd
    OnDragStart = GMMapChrm1DragStart
    OnMapTypeIdChanged = GMMapChrm1MapTypeIdChanged
    OnZoomChanged = GMMapChrm1ZoomChanged
    Left = 127
    Top = 22
  end
  object Chromium1: TChromium
    OnAfterCreated = Chromium1AfterCreated
    OnBeforeClose = Chromium1BeforeClose
    OnClose = Chromium1Close
    Left = 43
    Top = 88
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 300
    OnTimer = Timer1Timer
    Left = 32
    Top = 16
  end
end
