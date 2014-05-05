object MainView: TMainView
  Left = 0
  Top = 0
  Caption = 'MainView'
  ClientHeight = 116
  ClientWidth = 488
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
    Left = 24
    Top = 16
    Width = 209
    Height = 25
    Caption = 'Country With Separate Model Option 1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 24
    Top = 47
    Width = 209
    Height = 25
    Caption = 'Country With Separate Model Option 2'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 239
    Top = 16
    Width = 209
    Height = 25
    Caption = 'Country With Separate Model No View'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 239
    Top = 47
    Width = 209
    Height = 25
    Caption = 'Province With Separate Model No View'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 239
    Top = 78
    Width = 209
    Height = 25
    Caption = 'Province With Single Model No View'
    TabOrder = 4
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 24
    Top = 78
    Width = 209
    Height = 25
    Caption = 'Country With Separate Model Option 3'
    TabOrder = 5
    OnClick = Button6Click
  end
end
