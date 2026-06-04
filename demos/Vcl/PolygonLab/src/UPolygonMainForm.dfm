object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'GMLib VCL Polygon Lab'
  ClientHeight = 561
  ClientWidth = 884
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Browser: TEdgeBrowser
    Left = 0
    Top = 0
    Width = 600
    Height = 561
    Align = alLeft
    TabOrder = 0
    AllowSingleSignOnUsingOSPrimaryAccount = False
    TargetCompatibleBrowserVersion = '137.0.3296.44'
    UserDataFolder = '%LOCALAPPDATA%\bds.exe.WebView2'
    ExplicitHeight = 553
  end
  object ControlPanel: TPanel
    Left = 600
    Top = 0
    Width = 284
    Height = 561
    Align = alClient
    Caption = 'Controls'
    TabOrder = 1
    ExplicitWidth = 282
    ExplicitHeight = 553
    object ApplyButton: TButton
      Left = 16
      Top = 16
      Width = 120
      Height = 25
      Caption = 'Apply Polygon'
      TabOrder = 0
      OnClick = ApplyButtonClick
    end
    object ClearButton: TButton
      Left = 152
      Top = 16
      Width = 120
      Height = 25
      Caption = 'Clear'
      TabOrder = 1
    end
    object ActivateButton: TButton
      Left = 16
      Top = 48
      Width = 120
      Height = 25
      Caption = 'Activate Map'
      TabOrder = 2
    end
    object ZoomToPolygonButton: TButton
      Left = 152
      Top = 48
      Width = 120
      Height = 25
      Caption = 'Zoom To Polygon'
      TabOrder = 3
    end
    object LogMemo: TMemo
      Left = 1
      Top = 480
      Width = 282
      Height = 80
      Align = alBottom
      ReadOnly = True
      TabOrder = 4
      ExplicitTop = 472
      ExplicitWidth = 280
    end
  end
end
