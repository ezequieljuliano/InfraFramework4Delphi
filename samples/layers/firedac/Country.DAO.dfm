inherited CountryDAO: TCountryDAO
  OldCreateOrder = True
  object Country: TFDQuery
    Connection = DALConnection.FDConnection
    SQL.Strings = (
      'Select * From Country')
    Left = 88
    Top = 48
    object CountryID: TIntegerField
      DisplayLabel = 'Identifier'
      FieldName = 'ID'
      Origin = 'ID'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object CountryNAME: TStringField
      DisplayLabel = 'Name'
      FieldName = 'NAME'
      Origin = 'NAME'
      Required = True
      Size = 60
    end
  end
end
