object ProvinceDAO: TProvinceDAO
  OldCreateOrder = False
  Height = 122
  Width = 215
  object Province: TFDQuery
    Connection = DatabaseFireDAC.FDConnection
    SQL.Strings = (
      'Select * From Province')
    Left = 91
    Top = 13
    object ProvinceID: TIntegerField
      FieldName = 'ID'
      Origin = 'ID'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object ProvinceNAME: TStringField
      FieldName = 'NAME'
      Origin = 'NAME'
      ProviderFlags = [pfInUpdate]
      Required = True
      Size = 60
    end
    object ProvinceCOUNTRYID: TIntegerField
      FieldName = 'COUNTRYID'
      Origin = 'COUNTRYID'
      ProviderFlags = [pfInUpdate]
    end
  end
  object City: TFDQuery
    Connection = DatabaseFireDAC.FDConnection
    SQL.Strings = (
      'Select * From City Where ProvinceId = :ID')
    Left = 90
    Top = 66
    ParamData = <
      item
        Name = 'ID'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
    object CityID: TIntegerField
      FieldName = 'ID'
      Origin = 'ID'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object CityNAME: TStringField
      FieldName = 'NAME'
      Origin = 'NAME'
      ProviderFlags = [pfInUpdate]
      Required = True
      Size = 60
    end
    object CityPROVINCEID: TIntegerField
      FieldName = 'PROVINCEID'
      Origin = 'PROVINCEID'
      ProviderFlags = [pfInUpdate]
    end
  end
end
