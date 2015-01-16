object FireDACDmConnection: TFireDACDmConnection
  OldCreateOrder = False
  Height = 171
  Width = 215
  object FDConnection: TFDConnection
    Params.Strings = (
      'DriverID=FB'
      'User_Name=sysdba'
      'Password=masterkey')
    Left = 91
    Top = 11
  end
  object FDPhysFBDriverLink: TFDPhysFBDriverLink
    Left = 90
    Top = 59
  end
  object FDGUIxWaitCursor: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 89
    Top = 110
  end
end
