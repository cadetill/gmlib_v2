object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'MegaDemo GMLib'
  ClientHeight = 202
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 184
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object GMMap1: TGMMap
    MapOptions.Styles = <>
    Left = 200
    Top = 104
  end
end
