inherited CountryModel: TCountryModel
  inherited DataSet: TFDQuery
    Connection = ConnectionFireDAC.FDConnection
    SQL.Strings = (
      'Select * From Country')
    object DataSetCTY_CODE: TIntegerField
      DisplayLabel = 'Code'
      FieldName = 'CTY_CODE'
      Origin = 'CTY_CODE'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object DataSetCTY_NAME: TStringField
      DisplayLabel = 'Name'
      FieldName = 'CTY_NAME'
      Origin = 'CTY_NAME'
      ProviderFlags = [pfInUpdate]
      Required = True
      Size = 60
    end
  end
end
