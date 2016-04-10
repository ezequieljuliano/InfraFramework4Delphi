object Form3: TForm3
  Left = 0
  Top = 0
  Caption = 'Form3'
  ClientHeight = 266
  ClientWidth = 497
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 0
    Top = 47
    Width = 497
    Height = 219
    Align = alClient
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object DBNavigator1: TDBNavigator
    Left = 8
    Top = 207
    Width = 480
    Height = 51
    DataSource = DataSource1
    TabOrder = 1
  end
  object Panel1: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 491
    Height = 41
    Align = alTop
    TabOrder = 2
    ExplicitLeft = 128
    ExplicitTop = 104
    ExplicitWidth = 185
    object Label1: TLabel
      Left = 17
      Top = 14
      Width = 25
      Height = 13
      Caption = 'Login'
    end
    object Edit1: TEdit
      Left = 48
      Top = 11
      Width = 121
      Height = 21
      TabOrder = 0
    end
    object Button1: TButton
      Left = 175
      Top = 9
      Width = 75
      Height = 25
      Caption = 'Filtrar'
      TabOrder = 1
      OnClick = Button1Click
    end
  end
  object DataSource1: TDataSource
    DataSet = DmUserDAO.ADOQuery1
    Left = 368
    Top = 104
  end
end
