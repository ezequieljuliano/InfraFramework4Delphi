object MainView: TMainView
  Left = 0
  Top = 0
  Caption = 'Main View'
  ClientHeight = 240
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object MainMenu1: TMainMenu
    Left = 72
    Top = 32
    object Cad1: TMenuItem
      Caption = 'Records'
      object Country1: TMenuItem
        Caption = 'Countries'
        OnClick = Country1Click
      end
      object Provinces1: TMenuItem
        Caption = 'Provinces'
        OnClick = Provinces1Click
      end
    end
  end
end
