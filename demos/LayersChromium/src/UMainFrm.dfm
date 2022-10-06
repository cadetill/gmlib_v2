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
  PixelsPerInch = 96
  TextHeight = 15
  object CEFWindowParent1: TCEFWindowParent
    Left = 0
    Top = 0
    Width = 656
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
    TabOrder = 1
    ExplicitLeft = 656
    ExplicitWidth = 353
    ExplicitHeight = 587
    inherited cbActive: TCheckBox
      Width = 335
      ExplicitWidth = 335
    end
    inherited pcPages: TPageControl
      Width = 353
      Height = 522
      ExplicitWidth = 353
      ExplicitHeight = 522
      inherited tsMapOptions: TTabSheet
        ExplicitWidth = 345
        ExplicitHeight = 492
        inherited pcObjects: TPageControl
          Width = 345
          Height = 492
          ExplicitWidth = 345
          ExplicitHeight = 492
          inherited tsTrafficLayer: TTabSheet
            ExplicitWidth = 337
            ExplicitHeight = 462
          end
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
