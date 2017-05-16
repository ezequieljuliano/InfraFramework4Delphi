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
    object Label1: TLabel
      Left = 242
      Top = 14
      Width = 84
      Height = 13
      Align = alCustom
      Caption = 'Country Count: 0'
    end
    object Button2: TButton
      Left = 1
      Top = 1
      Width = 80
      Height = 39
      Align = alLeft
      Caption = 'FilterById'
      TabOrder = 0
      OnClick = Button2Click
    end
    object Button1: TButton
      Left = 552
      Top = 1
      Width = 109
      Height = 39
      Align = alRight
      Caption = 'FindByName'
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button3: TButton
      Left = 81
      Top = 1
      Width = 80
      Height = 39
      Align = alLeft
      Caption = 'Desfilter'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 161
      Top = 1
      Width = 75
      Height = 39
      Align = alLeft
      Caption = 'Count'
      TabOrder = 3
      OnClick = Button4Click
      ExplicitLeft = 233
    end
    object Button5: TButton
      Left = 448
      Top = 1
      Width = 104
      Height = 39
      Align = alRight
      Caption = 'FindById'
      TabOrder = 4
      OnClick = Button5Click
    end
  end
  object DsoCountry: TDataSource
    Left = 184
    Top = 30
  end
end
