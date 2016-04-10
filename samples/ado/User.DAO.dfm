inherited UserDAO: TUserDAO
  OldCreateOrder = True
  object DtsUser: TADOQuery
    Connection = DatabaseADO.FADOConnection
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'SELECT * FROM USUARIO')
    Left = 96
    Top = 40
  end
end
