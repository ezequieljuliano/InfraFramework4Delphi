object ProvinceModel: TProvinceModel
  OldCreateOrder = True
  Height = 117
  Width = 236
  object DataSet: TFDQuery
    Connection = ConnectionFireDAC.FDConnection
    SQL.Strings = (
      'Select * From Province')
    Left = 100
    Top = 38
    object DataSetPRO_CODE: TIntegerField
      DisplayLabel = 'Code'
      FieldName = 'PRO_CODE'
      Origin = 'PRO_CODE'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object DataSetPRO_NAME: TStringField
      DisplayLabel = 'Name'
      FieldName = 'PRO_NAME'
      Origin = 'PRO_NAME'
      ProviderFlags = [pfInUpdate]
      Required = True
      Size = 60
    end
    object DataSetCTY_CODE: TIntegerField
      DisplayLabel = 'Country Code'
      FieldName = 'CTY_CODE'
      Origin = 'CTY_CODE'
      ProviderFlags = [pfInUpdate]
      Required = True
    end
  end
end
