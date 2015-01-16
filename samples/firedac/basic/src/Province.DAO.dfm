inherited ProvinceDAO: TProvinceDAO
  OldCreateOrder = True
  Height = 189
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
    MasterSource = DsProvince
    MasterFields = 'ID'
    Connection = DatabaseFireDAC.FDConnection
    SQL.Strings = (
      'Select * From City Where ProvinceId = :ID')
    Left = 91
    Top = 113
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
  object DsProvince: TDataSource
    DataSet = Province
    Left = 91
    Top = 60
  end
end
