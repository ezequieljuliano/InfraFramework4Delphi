object DmModels: TDmModels
  OldCreateOrder = False
  Height = 150
  Width = 215
  object DtsCountry: TFDQuery
    Connection = ConnectionFireDAC.FDConnection
    SQL.Strings = (
      'Select * From Country')
    Left = 88
    Top = 16
    object DtsCountryCTY_CODE: TIntegerField
      DisplayLabel = 'Code'
      FieldName = 'CTY_CODE'
      Origin = 'CTY_CODE'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object DtsCountryCTY_NAME: TStringField
      DisplayLabel = 'Name'
      FieldName = 'CTY_NAME'
      Origin = 'CTY_NAME'
      ProviderFlags = [pfInUpdate]
      Required = True
      Size = 60
    end
  end
  object DtsProvince: TFDQuery
    Connection = ConnectionFireDAC.FDConnection
    SQL.Strings = (
      'Select * From Province')
    Left = 88
    Top = 80
    object DtsProvincePRO_CODE: TIntegerField
      DisplayLabel = 'Code'
      FieldName = 'PRO_CODE'
      Origin = 'PRO_CODE'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object DtsProvincePRO_NAME: TStringField
      DisplayLabel = 'Name'
      FieldName = 'PRO_NAME'
      Origin = 'PRO_NAME'
      ProviderFlags = [pfInUpdate]
      Required = True
      Size = 60
    end
    object DtsProvinceCTY_CODE: TIntegerField
      DisplayLabel = 'Country Name'
      FieldName = 'CTY_CODE'
      Origin = 'CTY_CODE'
      ProviderFlags = [pfInUpdate]
      Required = True
    end
  end
end
