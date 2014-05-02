object DmModels: TDmModels
  OldCreateOrder = False
  Height = 182
  Width = 215
  object DtsCustomer: TFDQuery
    Connection = ConnectionFireDAC.FDConnection
    SQL.Strings = (
      'Select * From Customer')
    Left = 88
    Top = 16
    object DtsCustomerCTR_CODE: TIntegerField
      DisplayLabel = 'Code'
      FieldName = 'CTR_CODE'
      Origin = 'CTR_CODE'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object DtsCustomerCTR_NAME: TStringField
      DisplayLabel = 'Name'
      FieldName = 'CTR_NAME'
      Origin = 'CTR_NAME'
      ProviderFlags = [pfInUpdate]
      Required = True
      Size = 60
    end
  end
  object DsCustomer: TDataSource
    DataSet = DtsCustomer
    Left = 88
    Top = 64
  end
  object DtsCustomerContact: TFDQuery
    MasterSource = DsCustomer
    MasterFields = 'CTR_CODE'
    Connection = ConnectionFireDAC.FDConnection
    SQL.Strings = (
      'Select * From Customer_Contact'
      'Where'
      '(Customer_Contact.Ctr_Code = :Ctr_Code)')
    Left = 88
    Top = 120
    ParamData = <
      item
        Name = 'CTR_CODE'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
    object DtsCustomerContactCTC_CODE: TIntegerField
      DisplayLabel = 'Code'
      FieldName = 'CTC_CODE'
      Origin = 'CTC_CODE'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object DtsCustomerContactCTC_NAME: TStringField
      DisplayLabel = 'Name'
      FieldName = 'CTC_NAME'
      Origin = 'CTC_NAME'
      ProviderFlags = [pfInUpdate]
      Required = True
      Size = 60
    end
    object DtsCustomerContactCTR_CODE: TIntegerField
      DisplayLabel = 'Customer Code'
      FieldName = 'CTR_CODE'
      Origin = 'CTR_CODE'
      ProviderFlags = [pfInUpdate]
      Required = True
    end
  end
end
