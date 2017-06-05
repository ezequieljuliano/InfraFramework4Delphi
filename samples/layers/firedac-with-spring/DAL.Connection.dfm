object DALConnection: TDALConnection
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 194
  Width = 215
  object FDConnection: TFDConnection
    Params.Strings = (
      
        'Database=D:\Projetos\MsysFramework\2.0\Dependencies\InfraFramewo' +
        'rk4Delphi\samples\layers\firedac-with-spring\Database.db'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 88
    Top = 16
  end
  object FDGUIxWaitCursor: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 88
    Top = 72
  end
  object FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink
    Left = 87
    Top = 130
  end
end
