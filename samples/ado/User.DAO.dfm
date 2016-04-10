inherited UserDAO: TUserDAO
  OldCreateOrder = True
  object DtsUser: TADOQuery
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
