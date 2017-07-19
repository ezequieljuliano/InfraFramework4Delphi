inherited CountryDAO: TCountryDAO
  OldCreateOrder = True
  object Country: TADOQuery
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'Select * From Country')
    Left = 88
    Top = 56
    object Countryid: TAutoIncField
      FieldName = 'id'
      ReadOnly = True
    end
    object Countryname: TWideStringField
      FieldName = 'name'
      Size = 50
    end
  end
end
