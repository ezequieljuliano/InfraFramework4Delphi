object CountryView: TCountryView
  Left = 0
  Top = 0
  Caption = 'Country'
  ClientHeight = 325
  ClientWidth = 662
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 0
    Top = 26
    Width = 662
    Height = 258
    Align = alClient
    DataSource = DsoCountry
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'ID'
        Width = 150
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'NAME'
        Width = 300
        Visible = True
      end>
  end
  object DBNavigator1: TDBNavigator
    Left = 0
    Top = 0
    Width = 662
    Height = 26
    DataSource = DsoCountry
    Align = alTop
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 0
    Top = 284
    Width = 662
    Height = 41
    Align = alBottom
    TabOrder = 2
    ExplicitLeft = 198
    ExplicitTop = 236
    ExplicitWidth = 185
    object Button2: TButton
      Left = 1
      Top = 1
      Width = 121
      Height = 39
      Align = alLeft
      Caption = 'FilterById'
      TabOrder = 0
      OnClick = Button2Click
      ExplicitLeft = 60
      ExplicitTop = 16
      ExplicitHeight = 25
    end
    object Button1: TButton
      Left = 536
      Top = 1
      Width = 125
      Height = 39
      Align = alRight
      Caption = 'FindByName'
      TabOrder = 1
      OnClick = Button1Click
      ExplicitLeft = 460
      ExplicitTop = 16
      ExplicitHeight = 25
    end
  end
  object DsoCountry: TDataSource
    Left = 184
    Top = 30
  end
end
