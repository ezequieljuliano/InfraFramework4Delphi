object CountryDAO: TCountryDAO
  OldCreateOrder = False
  Height = 90
  Width = 215
  object Country: TFDQuery
    Connection = DatabaseFireDAC.FDConnection
    SQL.Strings = (
      'Select * From Country')
    Left = 89
    Top = 20
    object CountryID: TIntegerField
      FieldName = 'ID'
      Origin = 'ID'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object CountryNAME: TStringField
      FieldName = 'NAME'
      Origin = 'NAME'
      ProviderFlags = [pfInUpdate]
      Required = True
      Size = 60
    end
  end
end
