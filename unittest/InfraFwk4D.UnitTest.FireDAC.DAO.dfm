inherited FireDACDAO: TFireDACDAO
  OldCreateOrder = True
  Height = 132
  object Master: TFDQuery
    Connection = FireDACDmConnection.FDConnection
    Left = 90
    Top = 15
  end
  object Detail: TFDQuery
    Connection = FireDACDmConnection.FDConnection
    Left = 88
    Top = 70
  end
end
