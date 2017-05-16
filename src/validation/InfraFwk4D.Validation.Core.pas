unit InfraFwk4D.Validation.Core;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.Classes,
  System.Generics.Collections,
  Data.DB,
  InfraFwk4D.Validation,
  InfraFwk4D.Validation.Default.Attributes,
  InfraFwk4D.Validation.Default.Validators;

type

  TConstraintViolation = class(TInterfacedObject, IConstraintViolation)
  private
    fMessage: string;
    fClass: TClass;
    fObject: TObject;
    fInvalidValue: TValue;
    fValueOwnersName: string;
  protected
    function GetMessage: string;
    function GetClass: TClass;
    function GetObject: TObject;
    function GetInvalidValue: TValue;
    function GetValueOwnersName: string;
  public
    constructor Create(const msg: string; const clazz: TClass; const obj: TObject;
      const invalidValue: TValue; const valueOwnersName: string);
  end;

  TValidatorContext = class(TInterfacedObject, IValidatorContext)
  private
    fViolations: TList<IConstraintViolation>;
    fValidators: TDictionary<string, IConstraintValidator>;
    fMessages: TDictionary<string, string>;
    fRttiContext: TRttiContext;
    procedure ValidateFields(const obj: TObject);
    procedure ValidateProperties(const obj: TObject);
    procedure ValidateDataSet(const dataSet: TDataSet; const owner: TComponent);
    procedure ProcessingAttribute(const attribute: ConstraintAttribute; const obj: TObject; const value: TValue; const name: string);
  protected
    function GetViolations: TList<IConstraintViolation>;

    procedure RegisterConstraintValidator(const attribute: ConstraintAttributeClass; const validatedBy: IConstraintValidator);
    procedure RegisterConstraintMessage(const attribute: ConstraintAttributeClass; const msg: string);

    function Validate(const obj: TObject): TList<IConstraintViolation>;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TConstraintViolation }

constructor TConstraintViolation.Create(const msg: string; const clazz: TClass; const obj: TObject;
  const invalidValue: TValue; const valueOwnersName: string);
begin
  inherited Create;
  fMessage := msg;
  fClass := clazz;
  fObject := obj;
  fInvalidValue := invalidValue;
  fValueOwnersName := valueOwnersName;
end;

function TConstraintViolation.GetClass: TClass;
begin
  Result := fClass;
end;

function TConstraintViolation.GetInvalidValue: TValue;
begin
  Result := fInvalidValue;
end;

function TConstraintViolation.GetMessage: string;
begin
  Result := fMessage;
end;

function TConstraintViolation.GetObject: TObject;
begin
  Result := fObject;
end;

function TConstraintViolation.GetValueOwnersName: string;
begin
  Result := fValueOwnersName;
end;

{ TValidatorContext }

constructor TValidatorContext.Create;
begin
  inherited Create;
  fViolations := nil;
  fValidators := TDictionary<string, IConstraintValidator>.Create;
  fMessages := TDictionary<string, string>.Create;
  fRttiContext := TRttiContext.Create;

  // Define Default Validators
  RegisterConstraintValidator(AssertFalseAttribute, TAssertFalseValidator.Create);
  RegisterConstraintValidator(AssertTrueAttribute, TAssertTrueValidator.Create);
  RegisterConstraintValidator(AssertInAttribute, TAssertInValidator.Create);
  RegisterConstraintValidator(MaxAttribute, TMaxValidator.Create);
  RegisterConstraintValidator(MinAttribute, TMinValidator.Create);
  RegisterConstraintValidator(SizeAttribute, TSizeValidator.Create);
  RegisterConstraintValidator(NotNullAttribute, TNotNullValidator.Create);
  RegisterConstraintValidator(NotNullWhenAttribute, TNotNullWhenValidator.Create);
  RegisterConstraintValidator(NotNullInAttribute, TNotNullInValidator.Create);
  RegisterConstraintValidator(NullAttribute, TNullValidator.Create);
  RegisterConstraintValidator(PastAttribute, TPastValidator.Create);
  RegisterConstraintValidator(PresentAttribute, TPresentValidator.Create);
  RegisterConstraintValidator(FutureAttribute, TFutureValidator.Create);
  RegisterConstraintValidator(DecimalMaxAttribute, TDecimalMaxValidator.Create);
  RegisterConstraintValidator(DecimalMinAttribute, TDecimalMinValidator.Create);

  // Define Default Messages
  RegisterConstraintMessage(AssertFalseAttribute, 'This field should contain the false value.');
  RegisterConstraintMessage(AssertTrueAttribute, 'This field should contain the true value.');
  RegisterConstraintMessage(AssertInAttribute, 'This field should contain the {value} values.');
  RegisterConstraintMessage(MaxAttribute, 'The value must be less than or equal to {value}.');
  RegisterConstraintMessage(MinAttribute, 'The value must be greater than or equal to {value}.');
  RegisterConstraintMessage(SizeAttribute, 'The size should be between {min} and {max}.');
  RegisterConstraintMessage(NotNullAttribute, 'Value can not be null.');
  RegisterConstraintMessage(NotNullWhenAttribute, 'Value can not be null.');
  RegisterConstraintMessage(NotNullInAttribute, 'Value can not be null.');
  RegisterConstraintMessage(NullAttribute, 'The value should be null.');
  RegisterConstraintMessage(PastAttribute, 'It must be a date in the past.');
  RegisterConstraintMessage(PresentAttribute, 'It must be a date in the present.');
  RegisterConstraintMessage(FutureAttribute, 'It must be a date in the future.');
  RegisterConstraintMessage(DecimalMaxAttribute, 'The value must be less than or equal to {value}.');
  RegisterConstraintMessage(DecimalMinAttribute, 'The value must be greater than or equal to {value}.');
end;

destructor TValidatorContext.Destroy;
begin
  if Assigned(fViolations) then
    fViolations.Free;
  fValidators.Free;
  fMessages.Free;
  fRttiContext.Free;
  inherited Destroy;
end;

function TValidatorContext.GetViolations: TList<IConstraintViolation>;
begin
  if not Assigned(fViolations) then
    fViolations := TList<IConstraintViolation>.Create;
  Result := fViolations;
end;

procedure TValidatorContext.ProcessingAttribute(const attribute: ConstraintAttribute; const obj: TObject; const value: TValue;
  const name: string);
var
  msg: string;
begin
  if fValidators.ContainsKey(attribute.ClassName) then
  begin
    fValidators.Items[attribute.ClassName].Initialize(attribute, obj);
    if not fValidators.Items[attribute.ClassName].IsValid(value) then
    begin
      msg := EmptyStr;
      if fMessages.ContainsKey(attribute.ClassName) then
        msg := fValidators.Items[attribute.ClassName].ProcessingMessage(fMessages.Items[attribute.ClassName]);
      GetViolations.Add(TConstraintViolation.Create(msg, obj.ClassType, obj, value, name))
    end;
  end;
end;

procedure TValidatorContext.RegisterConstraintMessage(const attribute: ConstraintAttributeClass; const msg: string);
begin
  fMessages.AddOrSetValue(attribute.ClassName, msg);
end;

procedure TValidatorContext.RegisterConstraintValidator(const attribute: ConstraintAttributeClass;
  const validatedBy: IConstraintValidator);
begin
  fValidators.AddOrSetValue(attribute.ClassName, validatedBy);
end;

function TValidatorContext.Validate(const obj: TObject): TList<IConstraintViolation>;
begin
  GetViolations.Clear;

  if not Assigned(obj) then
    raise EValidationException.Create('Unable to Validator Context, undefined object.');

  if (obj is TDataSet) then
    ValidateDataSet(TDataSet(obj), TDataSet(obj).Owner)
  else if (obj is TDataModule) then
    ValidateFields(obj)
  else
  begin
    ValidateFields(obj);
    ValidateProperties(obj);
  end;

  Result := GetViolations;
end;

procedure TValidatorContext.ValidateDataSet(const dataSet: TDataSet; const owner: TComponent);
var
  rttiType: TRttiType;
  rttiField: TRttiField;
  dataSetField: TField;
  attr: TCustomAttribute;
begin
  if not Assigned(owner) then
    Exit;

  rttiType := fRttiContext.GetType(owner.ClassType);
  for dataSetField in dataSet.Fields do
  begin
    rttiField := rttiType.GetField(dataSetField.Name);
    if Assigned(rttiField) then
      for attr in rttiField.GetAttributes do
        if attr is ConstraintAttribute then
          ProcessingAttribute(ConstraintAttribute(attr), dataSet, dataSetField, dataSetField.Name);
  end;
end;

procedure TValidatorContext.ValidateFields(const obj: TObject);
var
  rttiType: TRttiType;
  rttiField: TRttiField;
  attr: TCustomAttribute;
begin
  rttiType := fRttiContext.GetType(obj.ClassType);
  for rttiField in rttiType.GetFields do
    for attr in rttiField.GetAttributes do
      if attr is ConstraintAttribute then
        ProcessingAttribute(ConstraintAttribute(attr), obj, rttiField.GetValue(obj), rttiField.Name);
end;

procedure TValidatorContext.ValidateProperties(const obj: TObject);
var
  rttiType: TRttiType;
  rttiProperty: TRttiProperty;
  attr: TCustomAttribute;
begin
  rttiType := fRttiContext.GetType(obj.ClassType);
  for rttiProperty in rttiType.GetProperties do
    for attr in rttiProperty.GetAttributes do
      if attr is ConstraintAttribute then
        ProcessingAttribute(ConstraintAttribute(attr), obj, rttiProperty.GetValue(obj), rttiProperty.Name);
end;

end.
