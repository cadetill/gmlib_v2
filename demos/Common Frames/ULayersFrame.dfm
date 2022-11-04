object LayersFrame: TLayersFrame
  Left = 0
  Top = 0
  Width = 371
  Height = 519
  TabOrder = 0
  PixelsPerInch = 96
  object cbActive: TCheckBox
    AlignWithMargins = True
    Left = 15
    Top = 20
    Width = 353
    Height = 42
    Margins.Left = 15
    Margins.Top = 20
    Align = alTop
    Caption = 'Active'
    TabOrder = 0
    OnClick = cbActiveClick
  end
  object pAPIKey: TPanel
    Left = 0
    Top = 65
    Width = 371
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    Caption = ' '
    TabOrder = 1
    object lNeedAPI: TLabel
      Left = 63
      Top = 8
      Width = 278
      Height = 15
      Caption = '(you need to put an API Key to use some features)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lAPIKey: TLabel
      Left = 15
      Top = 8
      Width = 37
      Height = 15
      Caption = 'APIKey'
    end
    object eAPIKey: TEdit
      Left = 15
      Top = 24
      Width = 273
      Height = 23
      TabOrder = 0
      OnChange = eAPIKeyChange
    end
  end
  object pcObjects: TPageControl
    Left = 0
    Top = 121
    Width = 371
    Height = 398
    ActivePage = tsTrafficLayer
    Align = alClient
    TabOrder = 2
    object tsTrafficLayer: TTabSheet
      Caption = 'TrafficLayer'
      object cbTrafficAutoRefresh: TCheckBox
        Left = 32
        Top = 63
        Width = 129
        Height = 17
        Caption = 'AutoRefresh'
        TabOrder = 0
        OnClick = cbTrafficAutoRefreshClick
      end
      object cbTrafficShow: TCheckBox
        Left = 32
        Top = 32
        Width = 129
        Height = 17
        Caption = 'Show'
        TabOrder = 1
        OnClick = CheckBox1Click
      end
    end
    object tsTransitLayer: TTabSheet
      Caption = 'TransitLayer'
      ImageIndex = 1
      object cbTransitShow: TCheckBox
        Left = 32
        Top = 32
        Width = 129
        Height = 17
        Caption = 'Show'
        TabOrder = 0
        OnClick = cbTransitShowClick
      end
    end
    object tsByciclingLayer: TTabSheet
      Caption = 'ByciclingLayer'
      ImageIndex = 2
      object cbByciclingShow: TCheckBox
        Left = 32
        Top = 32
        Width = 129
        Height = 17
        Caption = 'Show'
        TabOrder = 0
        OnClick = cbByciclingShowClick
      end
    end
    object tsKmlLayer: TTabSheet
      Caption = 'KmlLayer'
      ImageIndex = 3
      object lKmlUrl: TLabel
        Left = 32
        Top = 184
        Width = 15
        Height = 15
        Caption = 'Url'
      end
      object cbKmlShow: TCheckBox
        Left = 32
        Top = 32
        Width = 153
        Height = 17
        Caption = 'Show'
        TabOrder = 0
        OnClick = cbKmlShowClick
      end
      object cbKmlClickable: TCheckBox
        Left = 32
        Top = 80
        Width = 153
        Height = 17
        Caption = 'Clickable'
        TabOrder = 1
        OnClick = cbKmlClickableClick
      end
      object cbKmlPreserveViewport: TCheckBox
        Left = 32
        Top = 103
        Width = 153
        Height = 17
        Caption = 'PreserveViewport'
        TabOrder = 2
        OnClick = cbKmlPreserveViewportClick
      end
      object cbKmlScreenOverlays: TCheckBox
        Left = 32
        Top = 126
        Width = 153
        Height = 17
        Caption = 'ScreenOverlays'
        TabOrder = 3
        OnClick = cbKmlScreenOverlaysClick
      end
      object cbKmlSuppressInfoWindows: TCheckBox
        Left = 32
        Top = 149
        Width = 153
        Height = 17
        Caption = 'SuppressInfoWindows'
        TabOrder = 4
        OnClick = cbKmlSuppressInfoWindowsClick
      end
      object eKmlUrl: TEdit
        Left = 32
        Top = 200
        Width = 289
        Height = 23
        TabOrder = 5
        OnChange = eKmlUrlChange
      end
    end
  end
end
