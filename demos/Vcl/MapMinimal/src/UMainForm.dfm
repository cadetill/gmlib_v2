object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'GMLib VCL Map Minimal Demo'
  ClientHeight = 641
  ClientWidth = 1030
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object ControlPanel: TPanel
    Left = 0
    Top = 0
    Width = 1030
    Height = 72
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 1028
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
    object StatusLabel: TLabel
      Left = 1024
      Top = 35
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
      Width = 120
      Height = 25
      Caption = 'Activate map'
      TabOrder = 5
      OnClick = ActivateButtonClick
    end
  end
  object LogPanel: TPanel
    Left = 0
    Top = 461
    Width = 1030
    Height = 180
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 453
    ExplicitWidth = 1028
    object LogMemo: TMemo
      Left = 1
      Top = 1
      Width = 1028
      Height = 178
      Align = alClient
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
      WordWrap = False
      ExplicitWidth = 1026
    end
  end
  object Browser: TEdgeBrowser
    Left = 0
    Top = 72
    Width = 1030
    Height = 389
    Align = alClient
    TabOrder = 2
    AllowSingleSignOnUsingOSPrimaryAccount = False
    TargetCompatibleBrowserVersion = '137.0.3296.44'
    UserDataFolder = '%LOCALAPPDATA%\bds.exe.WebView2'
    OnCreateWebViewCompleted = BrowserCreateWebViewCompleted
    ExplicitWidth = 1028
    ExplicitHeight = 381
  end
end
