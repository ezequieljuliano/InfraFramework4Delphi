object CustomerModel: TCustomerModel
  OldCreateOrder = True
  Height = 141
  Width = 311
  object DataSet: TFDQuery
    Connection = ConnectionFireDAC.FDConnection
    SQL.Strings = (
      'Select * From Customer')
    Left = 132
    Top = 19
    object DataSetCTR_CODE: TIntegerField
      DisplayLabel = 'Code'
      FieldName = 'CTR_CODE'
      Origin = 'CTR_CODE'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object DataSetCTR_NAME: TStringField
      DisplayLabel = 'Name'
      FieldName = 'CTR_NAME'
      Origin = 'CTR_NAME'
      ProviderFlags = [pfInUpdate]
      Required = True
      Size = 60
    end
  end
  object DsCustomer: TDataSource
    DataSet = DataSet
    Left = 132
    Top = 77
  end
end
