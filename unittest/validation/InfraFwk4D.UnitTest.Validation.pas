unit InfraFwk4D.UnitTest.Validation;

interface

uses
  TestFramework,
  System.SysUtils,
  System.Generics.Collections,
  InfraFwk4D.Validation,
  InfraFwk4D.Validation.Impl,
  InfraFwk4D.Validation.Default.Attributes,
  InfraFwk4D.Validation.Default.Validators,
  InfraFwk4D.UnitTest.Validation.DataModule,
  InfraFwk4D.UnitTest.Validation.Entity,
  Data.DB;

type

  TTestInfraFwkValidation = class(TTestCase)
  private
    fEntity: TEntity;
    fModel: TModel;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAssertFalseValidator;
    procedure TestAssertTrueValidator;
    procedure TestAssertInValidator;
    procedure TestMaxValidator;
    procedure TestMinValidator;
    procedure TestDecimalMaxValidator;
    procedure TestDecimalMinValidator;
    procedure TestSizeValidator;
    procedure TestNotNullValidator;
    procedure TestNullValidator;
    procedure TestPastValidator;
    procedure TestPresentValidator;
    procedure TestFutureValidator;

    procedure TestEntityValidatorContext;
    procedure TestModelValidatorContext;
    procedure TestDataSetValidatorContext;
  end;

implementation

{ TTestInfraFwkValidation }

procedure TTestInfraFwkValidation.SetUp;
begin
  inherited;
  fEntity := TEntity.Create;
  fModel := TModel.Create(nil);
end;

procedure TTestInfraFwkValidation.TearDown;
begin
  inherited;
  fEntity.Free;
  fModel.Free;
end;

procedure TTestInfraFwkValidation.TestAssertFalseValidator;
var
  validator: IConstraintValidator;
begin
  validator := TAssertFalseValidator.Create;

  CheckFalse(validator.IsValid(True));
  CheckTrue(validator.IsValid(False));

  CheckFalse(validator.IsValid(fModel.EntityTrueValue));
  CheckTrue(validator.IsValid(fModel.EntityFalseValue));
end;

procedure TTestInfraFwkValidation.TestAssertInValidator;
var
  attr: AssertInAttribute;
  validator: IConstraintValidator;
begin
  validator := TAssertInValidator.Create;
  attr := AssertInAttribute.Create('10;20;30');
  try
    validator.Initialize(attr, nil);

    CheckTrue(validator.IsValid(10));
    CheckTrue(validator.IsValid(20));
    CheckTrue(validator.IsValid(30));
    CheckFalse(validator.IsValid(50));
    CheckTrue(validator.IsValid(''));

    CheckTrue(validator.IsValid(fModel.EntityAssertInValue));
  finally
    attr.Free;
  end;
end;

procedure TTestInfraFwkValidation.TestAssertTrueValidator;
var
  validator: IConstraintValidator;
begin
  validator := TAssertTrueValidator.Create;

  CheckFalse(validator.IsValid(False));
  CheckTrue(validator.IsValid(True));

  CheckFalse(validator.IsValid(fModel.EntityFalseValue));
  CheckTrue(validator.IsValid(fModel.EntityTrueValue));
end;

procedure TTestInfraFwkValidation.TestDataSetValidatorContext;
var
  validadorCtx: IValidatorContext;
  violations: TList<IConstraintViolation>;
begin
  validadorCtx := TValidatorContext.Create;

  violations := validadorCtx.Validate(fModel.Entity);
  CheckTrue(violations.Count = 0);

  fModel.Entity.Edit;
  fModel.EntityFalseValue.AsBoolean := True;
  violations := validadorCtx.Validate(fModel.Entity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('This field should contain the false value.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsBoolean = True);
  CheckEqualsString('EntityFalseValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityTrueValue.AsBoolean := False;
  violations := validadorCtx.Validate(fModel.Entity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('This field should contain the true value.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsBoolean = False);
  CheckEqualsString('EntityTrueValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityAssertInValue.AsString := '50';
  violations := validadorCtx.Validate(fModel.Entity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('This field should contain the 10, 20, 30 values.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsString = '50');
  CheckEqualsString('EntityAssertInValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityMaxValue.AsInteger := 21;
  violations := validadorCtx.Validate(fModel.Entity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('The value must be less than or equal to 20.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsInteger = 21);
  CheckEqualsString('EntityMaxValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityMinValue.AsInteger := 4;
  violations := validadorCtx.Validate(fModel.Entity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('The value must be greater than or equal to 5.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsInteger = 4);
  CheckEqualsString('EntityMinValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntitySizeValue.AsString := 'Eze';
  violations := validadorCtx.Validate(fModel.Entity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('The size should be between 5 and 10.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsString = 'Eze');
  CheckEqualsString('EntitySizeValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityNotNullValue.AsString := '';
  violations := validadorCtx.Validate(fModel.Entity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('Value can not be null.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsString = '');
  CheckEqualsString('EntityNotNullValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityNotNullWhenValue.AsString := '';
  violations := validadorCtx.Validate(fModel.Entity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('Value can not be null.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsString = '');
  CheckEqualsString('EntityNotNullWhenValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityNotNullWhenBooleanValue.AsString := '';
  violations := validadorCtx.Validate(fModel.Entity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('Value can not be null.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsString = '');
  CheckEqualsString('EntityNotNullWhenBooleanValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityNotNullInValues.AsString := '';
  violations := validadorCtx.Validate(fModel.Entity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('Value can not be null.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsString = '');
  CheckEqualsString('EntityNotNullInValues', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityNullValue.AsString := 'NotNull';
  violations := validadorCtx.Validate(fModel.Entity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('The value should be null.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsString = 'NotNull');
  CheckEqualsString('EntityNullValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityPastValue.AsDateTime := Date + 1;
  violations := validadorCtx.Validate(fModel.Entity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('It must be a date in the past.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsDateTime = Date + 1);
  CheckEqualsString('EntityPastValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityPresentValue.AsDateTime := Date + 1;
  violations := validadorCtx.Validate(fModel.Entity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('It must be a date in the present.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsDateTime = Date + 1);
  CheckEqualsString('EntityPresentValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityFutureValue.AsDateTime := Date - 1;
  violations := validadorCtx.Validate(fModel.Entity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('It must be a date in the future.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsDateTime = Date - 1);
  CheckEqualsString('EntityFutureValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityDecimalMaxValue.AsFloat := 21.5;
  violations := validadorCtx.Validate(fModel.Entity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('The value must be less than or equal to 20,5.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsFloat = 21.5);
  CheckEqualsString('EntityDecimalMaxValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityDecimalMinValue.AsFloat := 9.5;
  violations := validadorCtx.Validate(fModel.Entity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('The value must be greater than or equal to 10,5.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TClientDataSet'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsFloat = 9.5);
  CheckEqualsString('EntityDecimalMinValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;
end;

procedure TTestInfraFwkValidation.TestDecimalMaxValidator;
var
  attr: DecimalMaxAttribute;
  validator: IConstraintValidator;
begin
  validator := TDecimalMaxValidator.Create;
  attr := DecimalMaxAttribute.Create(20.5);
  try
    validator.Initialize(attr, nil);

    CheckTrue(validator.IsValid(19.2));
    CheckTrue(validator.IsValid(20.5));
    CheckFalse(validator.IsValid(21.2));

    CheckTrue(validator.IsValid(fModel.EntityDecimalMaxValue));
  finally
    attr.Free;
  end;
end;

procedure TTestInfraFwkValidation.TestDecimalMinValidator;
var
  attr: DecimalMinAttribute;
  validator: IConstraintValidator;
begin
  validator := TDecimalMinValidator.Create;
  attr := DecimalMinAttribute.Create(5.5);
  try
    validator.Initialize(attr, nil);

    CheckTrue(validator.IsValid(6.3));
    CheckTrue(validator.IsValid(5.5));
    CheckFalse(validator.IsValid(4.5));

    CheckTrue(validator.IsValid(fModel.EntityDecimalMinValue));
  finally
    attr.Free;
  end;
end;

procedure TTestInfraFwkValidation.TestFutureValidator;
var
  validator: IConstraintValidator;
begin
  validator := TFutureValidator.Create;

  CheckFalse(validator.IsValid(Now));
  CheckFalse(validator.IsValid(Date));
  CheckFalse(validator.IsValid(Date - 1));
  CheckTrue(validator.IsValid(Date + 1));

  CheckTrue(validator.IsValid(fModel.EntityFutureValue));
end;

procedure TTestInfraFwkValidation.TestMaxValidator;
var
  attr: MaxAttribute;
  validator: IConstraintValidator;
begin
  validator := TMaxValidator.Create;
  attr := MaxAttribute.Create(20);
  try
    validator.Initialize(attr, nil);

    CheckTrue(validator.IsValid(19));
    CheckTrue(validator.IsValid(20));
    CheckFalse(validator.IsValid(21));

    CheckTrue(validator.IsValid(fModel.EntityMaxValue));
  finally
    attr.Free;
  end;
end;

procedure TTestInfraFwkValidation.TestMinValidator;
var
  attr: MinAttribute;
  validator: IConstraintValidator;
begin
  validator := TMinValidator.Create;
  attr := MinAttribute.Create(5);
  try
    validator.Initialize(attr, nil);

    CheckTrue(validator.IsValid(6));
    CheckTrue(validator.IsValid(5));
    CheckFalse(validator.IsValid(4));

    CheckTrue(validator.IsValid(fModel.EntityMinValue));
  finally
    attr.Free;
  end;
end;

procedure TTestInfraFwkValidation.TestModelValidatorContext;
var
  validadorCtx: IValidatorContext;
  violations: TList<IConstraintViolation>;
begin
  validadorCtx := TValidatorContext.Create;

  violations := validadorCtx.Validate(fModel);
  CheckTrue(violations.Count = 0);

  fModel.Entity.Edit;
  fModel.EntityFalseValue.AsBoolean := True;
  violations := validadorCtx.Validate(fModel);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('This field should contain the false value.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsBoolean = True);
  CheckEqualsString('EntityFalseValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityTrueValue.AsBoolean := False;
  violations := validadorCtx.Validate(fModel);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('This field should contain the true value.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsBoolean = False);
  CheckEqualsString('EntityTrueValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityAssertInValue.AsString := '50';
  violations := validadorCtx.Validate(fModel);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('This field should contain the 10, 20, 30 values.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsString = '50');
  CheckEqualsString('EntityAssertInValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityMaxValue.AsInteger := 21;
  violations := validadorCtx.Validate(fModel);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('The value must be less than or equal to 20.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsInteger = 21);
  CheckEqualsString('EntityMaxValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityMinValue.AsInteger := 4;
  violations := validadorCtx.Validate(fModel);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('The value must be greater than or equal to 5.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsInteger = 4);
  CheckEqualsString('EntityMinValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntitySizeValue.AsString := 'Eze';
  violations := validadorCtx.Validate(fModel);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('The size should be between 5 and 10.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsString = 'Eze');
  CheckEqualsString('EntitySizeValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityNotNullValue.AsString := '';
  violations := validadorCtx.Validate(fModel);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('Value can not be null.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsString = '');
  CheckEqualsString('EntityNotNullValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityNotNullWhenValue.AsString := '';
  violations := validadorCtx.Validate(fModel);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('Value can not be null.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsString = '');
  CheckEqualsString('EntityNotNullWhenValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityNotNullWhenBooleanValue.AsString := '';
  violations := validadorCtx.Validate(fModel);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('Value can not be null.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsString = '');
  CheckEqualsString('EntityNotNullWhenBooleanValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityNotNullInValues.AsString := '';
  violations := validadorCtx.Validate(fModel);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('Value can not be null.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsString = '');
  CheckEqualsString('EntityNotNullInValues', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityNullValue.AsString := 'NotNull';
  violations := validadorCtx.Validate(fModel);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('The value should be null.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsString = 'NotNull');
  CheckEqualsString('EntityNullValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityPastValue.AsDateTime := Date + 1;
  violations := validadorCtx.Validate(fModel);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('It must be a date in the past.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsDateTime = Date + 1);
  CheckEqualsString('EntityPastValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityPresentValue.AsDateTime := Date + 1;
  violations := validadorCtx.Validate(fModel);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('It must be a date in the present.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsDateTime = Date + 1);
  CheckEqualsString('EntityPresentValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityFutureValue.AsDateTime := Date - 1;
  violations := validadorCtx.Validate(fModel);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('It must be a date in the future.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsDateTime = Date - 1);
  CheckEqualsString('EntityFutureValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityDecimalMaxValue.AsFloat := 21.5;
  violations := validadorCtx.Validate(fModel);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('The value must be less than or equal to 20,5.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsFloat = 21.5);
  CheckEqualsString('EntityDecimalMaxValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;

  fModel.Entity.Edit;
  fModel.EntityDecimalMinValue.AsFloat := 9.5;
  violations := validadorCtx.Validate(fModel);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('The value must be greater than or equal to 10,5.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TModel'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TField>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TField>.AsFloat = 9.5);
  CheckEqualsString('EntityDecimalMinValue', violations.Items[0].GetValueOwnersName);
  fModel.Entity.Cancel;
end;

procedure TTestInfraFwkValidation.TestNotNullValidator;
var
  validator: IConstraintValidator;
begin
  validator := TNotNullValidator.Create;

  CheckTrue(validator.IsValid(0));
  CheckFalse(validator.IsValid(' '));
  CheckFalse(validator.IsValid(nil));
  CheckFalse(validator.IsValid(''));

  CheckTrue(validator.IsValid(fModel.EntityNotNullValue));
end;

procedure TTestInfraFwkValidation.TestNullValidator;
var
  validator: IConstraintValidator;
begin
  validator := TNullValidator.Create;

  CheckFalse(validator.IsValid(0));
  CheckFalse(validator.IsValid(' '));
  CheckTrue(validator.IsValid(nil));
  CheckTrue(validator.IsValid(''));

  CheckTrue(validator.IsValid(fModel.EntityNullValue));
end;

procedure TTestInfraFwkValidation.TestPastValidator;
var
  validator: IConstraintValidator;
begin
  validator := TPastValidator.Create;

  CheckFalse(validator.IsValid(Now));
  CheckFalse(validator.IsValid(Date));
  CheckFalse(validator.IsValid(Date + 1));
  CheckTrue(validator.IsValid(Date - 1));

  CheckTrue(validator.IsValid(fModel.EntityPastValue));
end;

procedure TTestInfraFwkValidation.TestPresentValidator;
var
  validator: IConstraintValidator;
begin
  validator := TPresentValidator.Create;

  CheckTrue(validator.IsValid(Now));
  CheckTrue(validator.IsValid(Date));
  CheckFalse(validator.IsValid(Date + 1));
  CheckFalse(validator.IsValid(Date - 1));

  CheckTrue(validator.IsValid(fModel.EntityPresentValue));
end;

procedure TTestInfraFwkValidation.TestSizeValidator;
var
  attr: SizeAttribute;
  validator: IConstraintValidator;
begin
  validator := TSizeValidator.Create;
  attr := SizeAttribute.Create(5, 10);
  try
    validator.Initialize(attr, nil);

    CheckTrue(validator.IsValid('Ezequiel'));
    CheckTrue(validator.IsValid('Ezequ'));
    CheckFalse(validator.IsValid('Ezeq'));

    CheckTrue(validator.IsValid(fModel.EntitySizeValue));
  finally
    attr.Free;
  end;
end;

procedure TTestInfraFwkValidation.TestEntityValidatorContext;
var
  validadorCtx: IValidatorContext;
  violations: TList<IConstraintViolation>;
begin
  validadorCtx := TValidatorContext.Create;

  violations := validadorCtx.Validate(fEntity);
  CheckTrue(violations.Count = 0);

  fEntity.FalseValue := True;
  violations := validadorCtx.Validate(fEntity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('This field should contain the false value.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<Boolean>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<Boolean> = True);
  CheckEqualsString('fFalseValue', violations.Items[0].GetValueOwnersName);
  fEntity.FalseValue := False;

  fEntity.TrueValue := False;
  violations := validadorCtx.Validate(fEntity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('This field should contain the true value.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<Boolean>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<Boolean> = False);
  CheckEqualsString('TrueValue', violations.Items[0].GetValueOwnersName);
  fEntity.TrueValue := True;

  fEntity.AssertInValue := '50';
  violations := validadorCtx.Validate(fEntity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('This field should contain the 10, 20, 30 values.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<String>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<String> = '50');
  CheckEqualsString('fAssertInValue', violations.Items[0].GetValueOwnersName);
  fEntity.AssertInValue := '10';

  fEntity.MaxValue := 21;
  violations := validadorCtx.Validate(fEntity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('The value must be less than or equal to 20.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<Integer>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<Integer> = 21);
  CheckEqualsString('fMaxValue', violations.Items[0].GetValueOwnersName);
  fEntity.MaxValue := 20;

  fEntity.MinValue := 4;
  violations := validadorCtx.Validate(fEntity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('The value must be greater than or equal to 5.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<Integer>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<Integer> = 4);
  CheckEqualsString('MinValue', violations.Items[0].GetValueOwnersName);
  fEntity.MinValue := 5;

  fEntity.SizeValue := 'Eze';
  violations := validadorCtx.Validate(fEntity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('The size should be between 5 and 10.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<string>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<string> = 'Eze');
  CheckEqualsString('fSizeValue', violations.Items[0].GetValueOwnersName);
  fEntity.SizeValue := 'Ezequiel';

  fEntity.NotNullValue := '';
  violations := validadorCtx.Validate(fEntity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('Value can not be null.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<string>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<string> = '');
  CheckEqualsString('fNotNullValue', violations.Items[0].GetValueOwnersName);
  fEntity.NotNullValue := 'NotNull';

  fEntity.NotNullWhenValue := '';
  violations := validadorCtx.Validate(fEntity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('Value can not be null.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<string>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<string> = '');
  CheckEqualsString('fNotNullWhenValue', violations.Items[0].GetValueOwnersName);
  fEntity.NotNullWhenValue := 'NotNullWhen';

  fEntity.NotNullWhenBooleanValue := '';
  violations := validadorCtx.Validate(fEntity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('Value can not be null.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<string>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<string> = '');
  CheckEqualsString('fNotNullWhenBooleanValue', violations.Items[0].GetValueOwnersName);
  fEntity.NotNullWhenBooleanValue := 'fNotNullWhenBooleanValue';

  fEntity.NotNullInValues := '';
  violations := validadorCtx.Validate(fEntity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('Value can not be null.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<string>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<string> = '');
  CheckEqualsString('fNotNullInValues', violations.Items[0].GetValueOwnersName);
  fEntity.NotNullInValues := 'NotNullInValues';

  fEntity.NullValue := 'NotNull';
  violations := validadorCtx.Validate(fEntity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('The value should be null.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<string>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<string> = 'NotNull');
  CheckEqualsString('fNullValue', violations.Items[0].GetValueOwnersName);
  fEntity.NullValue := '';

  fEntity.PastValue := Date + 1;
  violations := validadorCtx.Validate(fEntity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('It must be a date in the past.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TDateTime>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TDateTime> = Date + 1);
  CheckEqualsString('fPastValue', violations.Items[0].GetValueOwnersName);
  fEntity.PastValue := Date - 1;

  fEntity.PresentValue := Date + 1;
  violations := validadorCtx.Validate(fEntity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('It must be a date in the present.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TDateTime>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TDateTime> = Date + 1);
  CheckEqualsString('fPresentValue', violations.Items[0].GetValueOwnersName);
  fEntity.PresentValue := Date;

  fEntity.FutureValue := Date - 1;
  violations := validadorCtx.Validate(fEntity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('It must be a date in the future.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<TDateTime>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<TDateTime> = Date - 1);
  CheckEqualsString('fFutureValue', violations.Items[0].GetValueOwnersName);
  fEntity.FutureValue := Date + 1;

  fEntity.DecimalMaxValue := 21.5;
  violations := validadorCtx.Validate(fEntity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('The value must be less than or equal to 20,5.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<Double>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<Double> = 21.5);
  CheckEqualsString('fDecimalMaxValue', violations.Items[0].GetValueOwnersName);
  fEntity.DecimalMaxValue := 20.5;

  fEntity.DecimalMinValue := 9.5;
  violations := validadorCtx.Validate(fEntity);
  CheckTrue(violations.Count = 1);
  CheckEqualsString('The value must be greater than or equal to 10,5.', violations.Items[0].GetMessage);
  CheckTrue(violations.Items[0].GetClass.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetObject.ClassNameIs('TEntity'));
  CheckTrue(violations.Items[0].GetInvalidValue.IsType<Double>);
  CheckTrue(violations.Items[0].GetInvalidValue.AsType<Double> = 9.5);
  CheckEqualsString('fDecimalMinValue', violations.Items[0].GetValueOwnersName);
  fEntity.DecimalMinValue := 10.5;
end;

initialization

RegisterTest(TTestInfraFwkValidation.Suite);

end.
