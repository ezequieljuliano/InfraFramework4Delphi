object Model: TModel
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 150
  Width = 215
  object Entity: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 88
    Top = 48
    object EntityFalseValue: TBooleanField
      FieldName = 'FalseValue'
    end
    object EntityTrueValue: TBooleanField
      FieldName = 'TrueValue'
    end
    object EntityMaxValue: TIntegerField
      FieldName = 'MaxValue'
    end
    object EntityMinValue: TIntegerField
      FieldName = 'MinValue'
    end
    object EntitySizeValue: TStringField
      FieldName = 'SizeValue'
      Size = 10
    end
    object EntityNotNullValue: TStringField
      FieldName = 'NotNullValue'
    end
    object EntityNullValue: TStringField
      FieldName = 'NullValue'
    end
    object EntityPastValue: TDateField
      FieldName = 'PastValue'
    end
    object EntityPresentValue: TDateField
      FieldName = 'PresentValue'
    end
    object EntityFutureValue: TDateField
      FieldName = 'FutureValue'
    end
    object EntityDecimalMaxValue: TFloatField
      FieldName = 'DecimalMaxValue'
    end
    object EntityDecimalMinValue: TFloatField
      FieldName = 'DecimalMinValue'
    end
    object EntityNotNullWhenValue: TStringField
      FieldName = 'NotNullWhenValue'
      Size = 15
    end
    object EntityNotNullWhenBooleanValue: TStringField
      FieldName = 'NotNullWhenBooleanValue'
      Size = 50
    end
    object EntityNotNullInValues: TStringField
      FieldName = 'NotNullInValues'
      Size = 15
    end
    object EntityAssertInValue: TStringField
      FieldName = 'AssertInValue'
      Size = 2
    end
  end
end
