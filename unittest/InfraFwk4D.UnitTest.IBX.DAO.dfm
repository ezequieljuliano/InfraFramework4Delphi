inherited IBXDAO: TIBXDAO
  OldCreateOrder = True
  object Master: TIBDataSet
    Database = IBXDmConnection.IBDatabase
    Transaction = IBXDmConnection.IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    ParamCheck = True
    UniDirectional = False
    Left = 89
    Top = 21
  end
  object Detail: TIBDataSet
    Database = IBXDmConnection.IBDatabase
    Transaction = IBXDmConnection.IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    ParamCheck = True
    UniDirectional = False
    Left = 89
    Top = 76
  end
end
