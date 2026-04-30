object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'GMLib VCL Polyline Lab'
  ClientHeight = 760
  ClientWidth = 1260
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 352
    Top = 78
    Height = 502
    ExplicitLeft = 288
    ExplicitTop = 176
    ExplicitHeight = 100
  end
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 1260
    Height = 78
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object APIKeyLabel: TLabel
      Left = 16
      Top = 14
      Width = 39
      Height = 15
      Caption = 'API key'
    end
    object CenterLatLabel: TLabel
      Left = 456
      Top = 14
      Width = 43
      Height = 15
      Caption = 'Latitude'
    end
    object CenterLngLabel: TLabel
      Left = 572
      Top = 14
      Width = 54
      Height = 15
      Caption = 'Longitude'
    end
    object ZoomLabel: TLabel
      Left = 688
      Top = 14
      Width = 32
      Height = 15
      Caption = 'Zoom'
    end
    object StatusTitleLabel: TLabel
      Left = 1010
      Top = 14
      Width = 32
      Height = 15
      Caption = 'Status'
    end
    object StatusValueLabel: TLabel
      Left = 1010
      Top = 38
      Width = 32
      Height = 15
      Caption = 'Ready'
    end
    object APIKeyEdit: TEdit
      Left = 16
      Top = 32
      Width = 420
      Height = 23
      TabOrder = 0
    end
    object CenterLatEdit: TEdit
      Left = 456
      Top = 32
      Width = 100
      Height = 23
      TabOrder = 1
    end
    object CenterLngEdit: TEdit
      Left = 572
      Top = 32
      Width = 100
      Height = 23
      TabOrder = 2
    end
    object ZoomEdit: TEdit
      Left = 688
      Top = 32
      Width = 60
      Height = 23
      TabOrder = 3
    end
    object ApplyViewButton: TButton
      Left = 764
      Top = 30
      Width = 100
      Height = 25
      Caption = 'Apply view'
      TabOrder = 4
      OnClick = ApplyViewButtonClick
    end
    object ActivateButton: TButton
      Left = 880
      Top = 30
      Width = 110
      Height = 25
      Caption = 'Activate map'
      TabOrder = 5
      OnClick = ActivateButtonClick
    end
  end
  object LeftPanel: TPanel
    Left = 0
    Top = 78
    Width = 352
    Height = 502
    Align = alLeft
    BevelOuter = bvNone
    Padding.Left = 12
    Padding.Top = 12
    Padding.Right = 12
    Padding.Bottom = 12
    TabOrder = 1
    object PathLabel: TLabel
      Left = 12
      Top = 12
      Width = 198
      Height = 15
      Caption = 'Path coordinates (one lat,lng per line)'
    end
    object PathMemo: TMemo
      Left = 12
      Top = 12
      Width = 328
      Height = 230
      Align = alTop
      ScrollBars = ssVertical
      TabOrder = 0
      WordWrap = False
    end
    object PolylineButtonsPanel: TPanel
      Left = 12
      Top = 242
      Width = 328
      Height = 82
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object LoadSampleButton: TButton
        Left = 0
        Top = 0
        Width = 156
        Height = 25
        Caption = 'Load sample path'
        TabOrder = 0
        OnClick = LoadSampleButtonClick
      end
      object ApplyPolylineButton: TButton
        Left = 172
        Top = 0
        Width = 156
        Height = 25
        Caption = 'Apply polyline'
        TabOrder = 1
        OnClick = ApplyPolylineButtonClick
      end
      object ZoomToPolylineButton: TButton
        Left = 0
        Top = 41
        Width = 156
        Height = 25
        Caption = 'Zoom to polyline'
        TabOrder = 2
        OnClick = ZoomToPolylineButtonClick
      end
      object ClearPolylineButton: TButton
        Left = 172
        Top = 41
        Width = 156
        Height = 25
        Caption = 'Clear polylines'
        TabOrder = 3
        OnClick = ClearPolylineButtonClick
      end
    end
    object PolylineOptionsGroup: TGroupBox
      Left = 12
      Top = 324
      Width = 328
      Height = 142
      Align = alTop
      Caption = 'Polyline options'
      TabOrder = 2
      object StrokeColorLabel: TLabel
        Left = 16
        Top = 62
        Width = 63
        Height = 15
        Caption = 'Stroke color'
      end
      object StrokeWeightLabel: TLabel
        Left = 16
        Top = 102
        Width = 72
        Height = 15
        Caption = 'Stroke weight'
      end
      object StrokeOpacityLabel: TLabel
        Left = 176
        Top = 102
        Width = 75
        Height = 15
        Caption = 'Stroke opacity'
      end
      object VisibleCheckBox: TCheckBox
        Left = 16
        Top = 27
        Width = 97
        Height = 17
        Caption = 'Visible'
        TabOrder = 0
      end
      object EditableCheckBox: TCheckBox
        Left = 120
        Top = 27
        Width = 97
        Height = 17
        Caption = 'Editable'
        TabOrder = 1
      end
      object DraggableCheckBox: TCheckBox
        Left = 224
        Top = 27
        Width = 89
        Height = 17
        Caption = 'Draggable'
        TabOrder = 2
      end
      object StrokeColorBox: TColorBox
        Left = 104
        Top = 58
        Width = 209
        Height = 22
        TabOrder = 3
      end
      object StrokeWeightEdit: TEdit
        Left = 104
        Top = 99
        Width = 48
        Height = 23
        TabOrder = 4
      end
      object StrokeOpacityEdit: TEdit
        Left = 264
        Top = 99
        Width = 49
        Height = 23
        TabOrder = 5
      end
    end
  end
  object Browser: TEdgeBrowser
    Left = 355
    Top = 78
    Width = 905
    Height = 502
    Align = alClient
    TabOrder = 2
    AllowSingleSignOnUsingOSPrimaryAccount = False
    TargetCompatibleBrowserVersion = '137.0.3296.44'
    UserDataFolder = '%LOCALAPPDATA%\bds.exe.WebView2'
    OnCreateWebViewCompleted = BrowserCreateWebViewCompleted
  end
  object LogPanel: TPanel
    Left = 0
    Top = 580
    Width = 1260
    Height = 180
    Align = alBottom
    TabOrder = 3
    object LogMemo: TMemo
      Left = 1
      Top = 1
      Width = 1258
      Height = 178
      Align = alClient
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
      WordWrap = False
    end
  end
end
