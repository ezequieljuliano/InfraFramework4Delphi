inherited CustomerModel: TCustomerModel
  inherited DataSet: TFDQuery
    Connection = ConnectionFireDAC.FDConnection
    SQL.Strings = (
      'Select * From Customer')
    Top = 24
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
    Left = 88
    Top = 80
  end
end
