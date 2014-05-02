object CustomerView: TCustomerView
  Left = 0
  Top = 0
  Caption = 'CustomerView'
  ClientHeight = 379
  ClientWidth = 686
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
    Width = 686
    Height = 25
    DataSource = DsCustomer
    Align = alTop
    TabOrder = 0
    ExplicitLeft = 112
    ExplicitTop = 32
    ExplicitWidth = 240
  end
  object DBNavigator2: TDBNavigator
    Left = 0
    Top = 145
    Width = 686
    Height = 25
    DataSource = DsCustomerContact
    Align = alTop
    TabOrder = 1
    ExplicitLeft = 168
    ExplicitTop = 136
    ExplicitWidth = 240
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 25
    Width = 686
    Height = 120
    Align = alTop
    DataSource = DsCustomer
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object DBGrid2: TDBGrid
    Left = 0
    Top = 170
    Width = 686
    Height = 209
    Align = alClient
    DataSource = DsCustomerContact
    TabOrder = 3
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object DsCustomer: TDataSource
    Left = 408
    Top = 56
  end
  object DsCustomerContact: TDataSource
    Left = 512
    Top = 248
  end
end
