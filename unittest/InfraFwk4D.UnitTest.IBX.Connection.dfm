object IBXDmConnection: TIBXDmConnection
  OldCreateOrder = False
  Height = 150
  Width = 215
  object IBDatabase: TIBDatabase
    DefaultTransaction = IBTransaction
    ServerType = 'IBServer'
    Left = 89
    Top = 23
  end
  object IBTransaction: TIBTransaction
    DefaultDatabase = IBDatabase
    Left = 88
    Top = 79
  end
end
