object ProvinceView: TProvinceView
  Left = 0
  Top = 0
  Align = alCustom
  Caption = 'Province And Cities'
  ClientHeight = 430
  ClientWidth = 763
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
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 763
    Height = 194
    Align = alTop
    Caption = 'Province'
    TabOrder = 0
    ExplicitLeft = -8
    ExplicitTop = -6
    object DBNavigator1: TDBNavigator
      Left = 2
      Top = 15
      Width = 759
      Height = 33
      DataSource = DsoProvince
      Align = alTop
      TabOrder = 0
    end
    object DBGrid1: TDBGrid
      Left = 2
      Top = 48
      Width = 759
      Height = 109
      Align = alClient
      DataSource = DsoProvince
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'ID'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'NAME'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'COUNTRYID'
          Visible = True
        end>
    end
    object Panel1: TPanel
      Left = 2
      Top = 157
      Width = 759
      Height = 35
      Align = alBottom
      TabOrder = 2
      object Button1: TButton
        Left = 1
        Top = 1
        Width = 214
        Height = 33
        Align = alLeft
        Caption = 'Find Country to Province selected'
        TabOrder = 0
        OnClick = Button1Click
      end
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 194
    Width = 763
    Height = 236
    Align = alClient
    Caption = 'Cities'
    TabOrder = 1
    ExplicitTop = 8
    ExplicitWidth = 635
    ExplicitHeight = 139
    object DBNavigator2: TDBNavigator
      Left = 2
      Top = 15
      Width = 759
      Height = 33
      DataSource = DsoCities
      Align = alTop
      TabOrder = 0
      ExplicitTop = 17
    end
    object DBGrid2: TDBGrid
      Left = 2
      Top = 48
      Width = 759
      Height = 186
      Align = alClient
      DataSource = DsoCities
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'ID'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'NAME'
          Visible = True
        end>
    end
  end
  object DsoProvince: TDataSource
    DataSet = ProvinceDAO.Province
    Left = 622
    Top = 74
  end
  object DsoCities: TDataSource
    DataSet = ProvinceDAO.City
    Left = 616
    Top = 289
  end
end
