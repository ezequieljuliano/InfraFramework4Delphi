object MainView: TMainView
  Left = 0
  Top = 0
  Caption = 'MainView'
  ClientHeight = 106
  ClientWidth = 232
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button5: TButton
    Left = 8
    Top = 8
    Width = 209
    Height = 25
    Caption = 'Customer With Separate Model Option 1'
    TabOrder = 0
    OnClick = Button5Click
  end
  object Button1: TButton
    Left = 8
    Top = 39
    Width = 209
    Height = 25
    Caption = 'Customer With Separate Model Option 2'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 8
    Top = 70
    Width = 209
    Height = 25
    Caption = 'Customer With Single Model'
    TabOrder = 2
    OnClick = Button2Click
  end
end
