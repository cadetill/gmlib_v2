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
  object Splitter1: TSplitter
    Left = 653
    Top = 0
    Height = 587
    Align = alRight
    ExplicitLeft = 512
    ExplicitTop = 264
    ExplicitHeight = 100
  end
  object CEFWindowParent1: TCEFWindowParent
    Left = 0
    Top = 0
    Width = 653
    Height = 587
    Align = alClient
    TabStop = True
    TabOrder = 0
  end
  inline LayersFrame1: TLayersFrame
    Left = 656
    Top = 0
    Width = 353
    Height = 587
    Align = alRight
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    ExplicitLeft = 656
    ExplicitWidth = 353
    ExplicitHeight = 587
    inherited cbActive: TCheckBox
      Width = 335
      ExplicitWidth = 335
    end
    inherited pAPIKey: TPanel
      Width = 353
      ExplicitWidth = 353
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
      Width = 353
      Height = 450
      ExplicitWidth = 353
      ExplicitHeight = 450
      inherited tsTrafficLayer: TTabSheet
        ExplicitTop = 28
        ExplicitWidth = 345
        ExplicitHeight = 418
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
  object GMMapChrm1: TGMMapChrm
    Browser = Chromium1
    MapOptions.Center.Lat = 41.865838000000000000
    MapOptions.Center.Lng = -87.645589000000000000
    MapOptions.ClickableIcons = True
    MapOptions.GestureHandling = ghAuto
    MapOptions.IsFractionalZoomEnabled = True
    MapOptions.Restriction.StrictBounds = False
    MapOptions.Restriction.Enabled = False
    MapOptions.Zoom = 12
    Markers.MarkersList = <>
    Markers.AutoUpdate = False
    APILang = lSpanish
    APIRegion = rSpain
    TrafficLayer.Show = False
    TrafficLayer.TrafficLayerOptions.AutoRefresh = True
    TransitLayer.Show = False
    ByciclingLayer.Show = False
    KmlLayer.Show = False
    KmlLayer.KmlLayerOptions.Url = 'https://googlearchive.github.io/js-v2-samples/ggeoxml/cta.kml'
    Left = 304
    Top = 224
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
