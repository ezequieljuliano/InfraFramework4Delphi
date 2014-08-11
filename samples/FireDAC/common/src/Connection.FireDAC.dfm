object ConnectionFireDAC: TConnectionFireDAC
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 257
  Width = 219
  object FDConnection: TFDConnection
    Params.Strings = (
      
        'Database=D:\Projetos\MsysFramework\Delphi\Trunk\3rdPartyLibrarie' +
        's\InfraDatabase4Delphi\samples\FireDAC\common\bd\CUSTOMER.FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'DriverID=FB')
    LoginPrompt = False
    Left = 88
    Top = 48
  end
  object FDPhysFBDriverLink: TFDPhysFBDriverLink
    Left = 88
    Top = 104
  end
  object FDGUIxWaitCursor: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 88
    Top = 160
  end
end
