object DatabaseFireDAC: TDatabaseFireDAC
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 181
  Width = 215
  object FDConnection: TFDConnection
    Params.Strings = (
      
        'Database=D:\InfraFramework4Delphi\samples\firedac\common\bd\data' +
        'base.db'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 88
    Top = 16
  end
  object FDGUIxWaitCursor: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 88
    Top = 64
  end
  object FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink
    Left = 85
    Top = 118
  end
end
