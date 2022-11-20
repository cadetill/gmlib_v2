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
    Width = 696
    Height = 505
    Align = alClient
    TabOrder = 0
  end
  inline MapFrame1: TMapFrame
    Left = 696
    Top = 0
    Width = 301
    Height = 505
    Align = alRight
    TabOrder = 1
    ExplicitLeft = 696
    ExplicitWidth = 301
    ExplicitHeight = 505
    inherited cbActive: TCheckBox
      Width = 283
      ExplicitWidth = 283
    end
    inherited pcPages: TPageControl
      Width = 301
      Height = 440
      ExplicitWidth = 301
      ExplicitHeight = 440
      inherited tsGeneral: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 293
        ExplicitHeight = 410
        inherited lIntervalEvents: TLabel
          Width = 76
          Height = 15
          ExplicitWidth = 76
          ExplicitHeight = 15
        end
        inherited lAPIVersion: TLabel
          Width = 56
          Height = 15
          ExplicitWidth = 56
          ExplicitHeight = 15
        end
        inherited lAPILang: TLabel
          Width = 44
          Height = 15
          ExplicitWidth = 44
          ExplicitHeight = 15
        end
        inherited lAPIKey: TLabel
          Width = 37
          Height = 15
          ExplicitWidth = 37
          ExplicitHeight = 15
        end
        inherited lAPIRegion: TLabel
          Width = 55
          Height = 15
          ExplicitWidth = 55
          ExplicitHeight = 15
        end
        inherited lLanguage: TLabel
          Width = 52
          Height = 15
          ExplicitWidth = 52
          ExplicitHeight = 15
        end
      end
      inherited tsMapOptions: TTabSheet
        ExplicitTop = 26
        ExplicitHeight = 513
        inherited lBackgroundColor: TLabel
          Width = 93
          Height = 15
          ExplicitWidth = 93
          ExplicitHeight = 15
        end
        inherited gbCenter: TGroupBox
          inherited lLat: TLabel
            Width = 16
            Height = 15
            ExplicitWidth = 16
            ExplicitHeight = 15
          end
          inherited lLng: TLabel
            Width = 20
            Height = 15
            ExplicitWidth = 20
            ExplicitHeight = 15
          end
        end
        inherited pcObjects: TPageControl
          Top = 314
          inherited tsFullScreenControl: TTabSheet
            ExplicitTop = 26
            ExplicitHeight = 169
            inherited lFSPosition: TLabel
              Width = 43
              Height = 15
              ExplicitWidth = 43
              ExplicitHeight = 15
            end
          end
          inherited tsMapTypeControl: TTabSheet
            ExplicitTop = 26
            ExplicitHeight = 169
            inherited lMTPosition: TLabel
              Width = 43
              Height = 15
              ExplicitWidth = 43
              ExplicitHeight = 15
            end
            inherited lMTStyle: TLabel
              Width = 25
              Height = 15
              ExplicitWidth = 25
              ExplicitHeight = 15
            end
            inherited lMTIds: TLabel
              Width = 15
              Height = 15
              ExplicitWidth = 15
              ExplicitHeight = 15
            end
            inherited lMapTypeId: TLabel
              Width = 58
              Height = 15
              ExplicitWidth = 58
              ExplicitHeight = 15
            end
            inherited clbMTIds: TCheckListBox
              ItemHeight = 16
            end
          end
          inherited tsRestriction: TTabSheet
            ExplicitTop = 26
            ExplicitHeight = 169
            inherited gbRNE: TGroupBox
              inherited lRNELat: TLabel
                Width = 16
                Height = 15
                ExplicitWidth = 16
                ExplicitHeight = 15
              end
              inherited lRNELng: TLabel
                Width = 20
                Height = 15
                ExplicitWidth = 20
                ExplicitHeight = 15
              end
            end
            inherited gbRSW: TGroupBox
              inherited lRSWLat: TLabel
                Width = 16
                Height = 15
                ExplicitWidth = 16
                ExplicitHeight = 15
              end
              inherited lRSWLng: TLabel
                Width = 20
                Height = 15
                ExplicitWidth = 20
                ExplicitHeight = 15
              end
            end
          end
          inherited tsRotateControl: TTabSheet
            ExplicitTop = 26
            ExplicitHeight = 169
            inherited lRotPosition: TLabel
              Width = 43
              Height = 15
              ExplicitWidth = 43
              ExplicitHeight = 15
            end
          end
          inherited tsScaleControl: TTabSheet
            ExplicitTop = 26
            ExplicitHeight = 169
            inherited lSStyle: TLabel
              Width = 25
              Height = 15
              ExplicitWidth = 25
              ExplicitHeight = 15
            end
          end
          inherited tsStreetViewControl: TTabSheet
            ExplicitTop = 26
            ExplicitHeight = 169
            inherited lSVPosition: TLabel
              Width = 43
              Height = 15
              ExplicitWidth = 43
              ExplicitHeight = 15
            end
          end
          inherited tsZoomControl: TTabSheet
            ExplicitTop = 26
            ExplicitHeight = 169
            inherited lZPosition: TLabel
              Width = 43
              Height = 15
              ExplicitWidth = 43
              ExplicitHeight = 15
            end
            inherited lZoom: TLabel
              Width = 32
              Height = 15
              ExplicitWidth = 32
              ExplicitHeight = 15
            end
            inherited lMaxZoom: TLabel
              Width = 55
              Height = 15
              ExplicitWidth = 55
              ExplicitHeight = 15
            end
            inherited lMinZoom: TLabel
              Width = 53
              Height = 15
              ExplicitWidth = 53
              ExplicitHeight = 15
            end
          end
        end
      end
    end
  end
  object GMMapEdge1: TGMMapEdge
    Browser = EdgeBrowser1
    MapOptions.Center.Lat = 42.539899000000000000
    MapOptions.Center.Lng = 1.578505000000000000
    MapOptions.ClickableIcons = True
    MapOptions.FullScreenControl = False
    MapOptions.GestureHandling = ghAuto
    MapOptions.IsFractionalZoomEnabled = True
    MapOptions.MapTypeControlOptions.Position = cpTOP_LEFT
    MapOptions.MapTypeControlOptions.Style = mtcDROPDOWN_MENU
    MapOptions.Restriction.StrictBounds = False
    MapOptions.Restriction.Enabled = False
    Markers.Markers = <>
    Markers.AutoUpdate = False
    APIRegion = rUnited_States
    TrafficLayer.Show = False
    TrafficLayer.TrafficLayerOptions.AutoRefresh = True
    TransitLayer.Show = False
    ByciclingLayer.Show = False
    KmlLayer.Show = False
    Left = 184
    Top = 216
  end
end
