object CustomerContactModel: TCustomerContactModel
  OldCreateOrder = True
  Height = 89
  Width = 274
  object DataSet: TFDQuery
    MasterSource = CustomerModel.DsCustomer
    MasterFields = 'CTR_CODE'
    Connection = ConnectionFireDAC.FDConnection
    SQL.Strings = (
      'Select * From Customer_Contact'
      'Where'
      '(Customer_Contact.Ctr_Code = :Ctr_Code)')
    Left = 114
    Top = 21
    ParamData = <
      item
        Name = 'CTR_CODE'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
    object DataSetCTC_CODE: TIntegerField
      DisplayLabel = 'Code'
      FieldName = 'CTC_CODE'
      Origin = 'CTC_CODE'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object DataSetCTC_NAME: TStringField
      DisplayLabel = 'Name'
      FieldName = 'CTC_NAME'
      Origin = 'CTC_NAME'
      ProviderFlags = [pfInUpdate]
      Required = True
      Size = 60
    end
    object DataSetCTR_CODE: TIntegerField
      DisplayLabel = 'Customer Code'
      FieldName = 'CTR_CODE'
      Origin = 'CTR_CODE'
      ProviderFlags = [pfInUpdate]
      Required = True
    end
  end
end
