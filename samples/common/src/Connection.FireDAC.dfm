object ConnectionFireDAC: TConnectionFireDAC
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 257
  Width = 219
  object FDConnection: TFDConnection
    Params.Strings = (
      
        'Database=D:\GitHub\InfraDatabase4Delphi\samples\common\bd\CUSTOM' +
        'ER.FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'Server=192.168.0.87'
      'Protocol=TCPIP'
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
