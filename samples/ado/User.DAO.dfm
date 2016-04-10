inherited DmUserDAO: TDmUserDAO
  OldCreateOrder = True
  object ADOQuery1: TADOQuery
    Active = True
    Connection = DatabaseADO.FADOConnection
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'SELECT * FROM USUARIO')
    Left = 96
    Top = 40
  end
end
