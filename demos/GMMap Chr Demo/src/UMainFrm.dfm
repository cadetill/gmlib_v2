object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'MainFrm'
  ClientHeight = 641
  ClientWidth = 1009
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCloseQuery = FormCloseQuery
  TextHeight = 17
  object Splitter1: TSplitter
    Left = 637
    Top = 0
    Height = 518
    Align = alRight
    ExplicitLeft = 512
    ExplicitTop = 296
    ExplicitHeight = 100
  end
  object CEFWindowParent1: TCEFWindowParent
    Left = 0
    Top = 0
    Width = 637
    Height = 518
    Align = alClient
    TabStop = True
    TabOrder = 0
    ExplicitWidth = 653
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
    Left = 640
    Top = 0
    Width = 369
    Height = 518
    Align = alRight
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    ExplicitLeft = 640
    ExplicitWidth = 369
    ExplicitHeight = 518
    inherited cbActive: TCheckBox
      Width = 351
      ExplicitWidth = 335
    end
    inherited pcPages: TPageControl
      Width = 369
      Height = 453
      ExplicitWidth = 353
      ExplicitHeight = 453
      inherited tsGeneral: TTabSheet
        ExplicitWidth = 361
        ExplicitHeight = 421
      end
      inherited tsMapOptions: TTabSheet
        inherited pcObjects: TPageControl
          ExplicitHeight = 310
          inherited tsMapTypeControl: TTabSheet
            inherited clbMTIds: TCheckListBox
              Width = 137
              ExplicitWidth = 137
            end
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
    Markers.Markers = <>
    Markers.AutoUpdate = False
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
