inherited UniDACDAO: TUniDACDAO
  OldCreateOrder = True
  object Master: TUniQuery
    Connection = UniDACDmConnection.UniConnection
    Left = 90
    Top = 24
  end
  object Detail: TUniQuery
    Connection = UniDACDmConnection.UniConnection
    Left = 88
    Top = 79
  end
end
