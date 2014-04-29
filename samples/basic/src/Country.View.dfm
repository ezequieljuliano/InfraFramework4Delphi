object CountryView: TCountryView
  Left = 0
  Top = 0
  Caption = 'CountryView'
  ClientHeight = 300
  ClientWidth = 581
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object DBNavigator1: TDBNavigator
    Left = 0
    Top = 0
    Width = 581
    Height = 25
    DataSource = DsCountry
    Align = alTop
    TabOrder = 0
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 25
    Width = 581
    Height = 275
    Align = alClient
    DataSource = DsCountry
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object DsCountry: TDataSource
    DataSet = CountryModel.DataSet
    Left = 144
    Top = 96
  end
end
