unit InfraFwk4D.Validation.Default.Validators;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.Rtti,
  System.DateUtils,
  System.Types,
  InfraFwk4D.Validation,
  InfraFwk4D.Validation.Default.Attributes,
  Data.DB;

type

  TAbstractValidator = class abstract(TInterfacedObject)
  private
    { private declarations }
  protected
    procedure Initialize(const attribute: ConstraintAttribute; const obj: TObject); virtual;
    function ProcessingMessage(const msg: string): string; virtual;
  public
    { public declarations }
  end;

  TAssertFalseValidator = class(TAbstractValidator, IConstraintValidator)
  private
    { private declarations }
  protected
    function IsValid(const value: TValue): Boolean;
  public
    { public declarations }
  end;

  TAssertTrueValidator = class(TAbstractValidator, IConstraintValidator)
  private
    { private declarations }
  protected
    function IsValid(const value: TValue): Boolean;
  public
    { public declarations }
  end;

  TAssertInValidator = class(TAbstractValidator, IConstraintValidator)
  private
    fValues: TArray<String>;
    function IsStringInValues(const str: string): Boolean;
  protected
    procedure Initialize(const attribute: ConstraintAttribute; const obj: TObject); override;
    function IsValid(const value: TValue): Boolean;
    function ProcessingMessage(const msg: string): string; override;
  public
    { public declarations }
  end;

  TMaxValidator = class(TAbstractValidator, IConstraintValidator)
  private
    fMaxValue: Integer;
  protected
    procedure Initialize(const attribute: ConstraintAttribute; const obj: TObject); override;
    function IsValid(const value: TValue): Boolean;
    function ProcessingMessage(const msg: string): string; override;
  public
    { public declarations }
  end;

  TMinValidator = class(TAbstractValidator, IConstraintValidator)
  private
    fMinValue: Integer;
  protected
    procedure Initialize(const attribute: ConstraintAttribute; const obj: TObject); override;
    function IsValid(const value: TValue): Boolean;
    function ProcessingMessage(const msg: string): string; override;
  public
    { public declarations }
  end;

  TSizeValidator = class(TAbstractValidator, IConstraintValidator)
  private
    fMinValue: Integer;
    fMaxValue: Integer;
  protected
    procedure Initialize(const attribute: ConstraintAttribute; const obj: TObject); override;
    function IsValid(const value: TValue): Boolean;
    function ProcessingMessage(const msg: string): string; override;
  public
    { public declarations }
  end;

  TDecimalMaxValidator = class(TAbstractValidator, IConstraintValidator)
  private
    fMaxValue: Double;
  protected
    procedure Initialize(const attribute: ConstraintAttribute; const obj: TObject); override;
    function IsValid(const value: TValue): Boolean;
    function ProcessingMessage(const msg: string): string; override;
  public
    { public declarations }
  end;

  TDecimalMinValidator = class(TAbstractValidator, IConstraintValidator)
  private
    fMinValue: Double;
  protected
    procedure Initialize(const attribute: ConstraintAttribute; const obj: TObject); override;
    function IsValid(const value: TValue): Boolean;
    function ProcessingMessage(const msg: string): string; override;
  public
    { public declarations }
  end;

  TNotNullValidator = class(TAbstractValidator, IConstraintValidator)
  private
    { private declarations }
  protected
    function IsValid(const value: TValue): Boolean; virtual;
  public
    { public declarations }
  end;

  TNotNullWhenValidator = class(TNotNullValidator, IConstraintValidator)
  private
    fObj: TObject;
    fName: string;
    fValue: string;
  protected
    procedure Initialize(const attribute: ConstraintAttribute; const obj: TObject); override;
    function IsValid(const value: TValue): Boolean; override;
  public
    { public declarations }
  end;

  TNotNullInValidator = class(TNotNullValidator, IConstraintValidator)
  private
    fObj: TObject;
    fName: string;
    fValues: TArray<String>;
  protected
    procedure Initialize(const attribute: ConstraintAttribute; const obj: TObject); override;
    function IsValid(const value: TValue): Boolean; override;
  public
    { public declarations }
  end;

  TNullValidator = class(TAbstractValidator, IConstraintValidator)
  private
    { private declarations }
  protected
    function IsValid(const value: TValue): Boolean;
  public
    { public declarations }
  end;

  TPastValidator = class(TAbstractValidator, IConstraintValidator)
  private
    { private declarations }
  protected
    function IsValid(const value: TValue): Boolean;
  public
    { public declarations }
  end;

  TPresentValidator = class(TAbstractValidator, IConstraintValidator)
  private
    { private declarations }
  protected
    function IsValid(const value: TValue): Boolean;
  public
    { public declarations }
  end;

  TFutureValidator = class(TAbstractValidator, IConstraintValidator)
  private
    { private declarations }
  protected
    function IsValid(const value: TValue): Boolean;
  public
    { public declarations }
  end;

implementation

{ TAbstractValidator }

procedure TAbstractValidator.Initialize(const attribute: ConstraintAttribute; const obj: TObject);
begin
  { not used }
end;

function TAbstractValidator.ProcessingMessage(const msg: string): string;
begin
  Result := msg;
end;

{ TAssertFalseValidator }

function TAssertFalseValidator.IsValid(const value: TValue): Boolean;
begin
  Result := False;

  if (not value.IsEmpty) and (value.IsType<TField>) then
    if (not value.AsType<TField>.IsNull) then
      Exit(value.AsType<TField>.AsBoolean = False)
    else
      Exit(True);

  if value.IsType<Boolean> then
    Exit(value.AsType<Boolean> = False);
end;

{ TAssertTrueValidator }

function TAssertTrueValidator.IsValid(const value: TValue): Boolean;
begin
  Result := False;

  if (not value.IsEmpty) and (value.IsType<TField>) then
    if (not value.AsType<TField>.IsNull) then
      Exit(value.AsType<TField>.AsBoolean = True)
    else
      Exit(True);

  if value.IsType<Boolean> then
    Exit(value.AsType<Boolean> = True);
end;

{ TMaxValidator }

procedure TMaxValidator.Initialize(const attribute: ConstraintAttribute; const obj: TObject);
begin
  inherited;
  fMaxValue := MaxAttribute(attribute).Value;
end;

function TMaxValidator.IsValid(const value: TValue): Boolean;
begin
  Result := False;

  if (not value.IsEmpty) and (value.IsType<TField>) then
    if (not value.AsType<TField>.IsNull) then
      Exit(value.AsType<TField>.AsInteger <= fMaxValue)
    else
      Exit(True);

  if value.IsType<Integer> then
    Exit(value.AsType<Integer> <= fMaxValue)
end;

function TMaxValidator.ProcessingMessage(const msg: string): string;
begin
  Result := msg.Replace('{value}', fMaxValue.ToString);
end;

{ TMinValidator }

function TMinValidator.ProcessingMessage(const msg: string): string;
begin
  Result := msg.Replace('{value}', fMinValue.ToString);
end;

procedure TMinValidator.Initialize(const attribute: ConstraintAttribute; const obj: TObject);
begin
  inherited;
  fMinValue := MinAttribute(attribute).Value;
end;

function TMinValidator.IsValid(const value: TValue): Boolean;
begin
  Result := False;

  if (not value.IsEmpty) and (value.IsType<TField>) then
    if (not value.AsType<TField>.IsNull) then
      Exit(value.AsType<TField>.AsInteger >= fMinValue)
    else
      Exit(True);

  if value.IsType<Integer> then
    Exit(value.AsType<Integer> >= fMinValue);
end;

{ TSizeValidator }

procedure TSizeValidator.Initialize(const attribute: ConstraintAttribute; const obj: TObject);
begin
  inherited;
  fMinValue := SizeAttribute(attribute).Min;
  fMaxValue := SizeAttribute(attribute).Max;
end;

function TSizeValidator.IsValid(const value: TValue): Boolean;
begin
  Result := False;

  if (not value.IsEmpty) and (value.IsType<TField>) then
    if (not value.AsType<TField>.IsNull) and (not value.AsType<TField>.AsString.IsEmpty) then
      Exit((value.AsType<TField>.AsString.Length >= fMinValue) and (value.AsType<TField>.AsString.Length <= fMaxValue))
    else
      Exit(True);

  if (value.IsType<string>) and (not value.AsType<string>.IsEmpty) then
    Exit((value.AsType<string>.Length >= fMinValue) and (value.AsType<string>.Length <= fMaxValue))
  else
    Exit(True);
end;

function TSizeValidator.ProcessingMessage(const msg: string): string;
begin
  Result := msg.Replace('{min}', fMinValue.ToString).Replace('{max}', fMaxValue.ToString);
end;

{ TNotNullValidator }

function TNotNullValidator.IsValid(const value: TValue): Boolean;
begin
  if (not value.IsEmpty) and (value.IsType<TField>) then
    case value.AsType<TField>.DataType of
      ftString, ftMemo, ftFmtMemo, ftWideString, ftFixedWideChar, ftWideMemo:
        Exit(not value.AsType<TField>.AsString.Trim.IsEmpty)
    else
      Exit(not value.AsType<TField>.IsNull);
    end;

  case value.Kind of
    tkChar, tkString, tkWChar, tkLString, tkWString, tkUString:
      Exit(not value.ToString.Trim.IsEmpty);
  else
    Exit(not value.IsEmpty);
  end;
end;

{ TNullValidator }

function TNullValidator.IsValid(const value: TValue): Boolean;
begin
  if (not value.IsEmpty) and (value.IsType<TField>) then
    case value.AsType<TField>.DataType of
      ftString, ftMemo, ftFmtMemo, ftWideString, ftFixedWideChar, ftWideMemo:
        Exit(value.AsType<TField>.AsString.IsEmpty)
    else
      Exit(value.AsType<TField>.IsNull);
    end;

  case value.Kind of
    tkChar, tkString, tkWChar, tkLString, tkWString, tkUString:
      Exit(value.ToString.IsEmpty);
  else
    Exit(value.IsEmpty);
  end;
end;

{ TPastValidator }

function TPastValidator.IsValid(const value: TValue): Boolean;
begin
  Result := False;

  if (not value.IsEmpty) and (value.IsType<TField>) then
    if (not value.AsType<TField>.IsNull) then
      Exit(CompareDate(value.AsType<TField>.AsDateTime, Now) = LessThanValue)
    else
      Exit(True);

  if value.IsType<TDateTime> then
    Exit(CompareDate(value.AsType<TDateTime>, Now) = LessThanValue);
end;

{ TPresentValidator }

function TPresentValidator.IsValid(const value: TValue): Boolean;
begin
  Result := False;

  if (not value.IsEmpty) and (value.IsType<TField>) then
    if (not value.AsType<TField>.IsNull) then
      Exit(CompareDate(value.AsType<TField>.AsDateTime, Now) = EqualsValue)
    else
      Exit(True);

  if value.IsType<TDateTime> then
    Exit(CompareDate(value.AsType<TDateTime>, Now) = EqualsValue);
end;

{ TFutureValidator }

function TFutureValidator.IsValid(const value: TValue): Boolean;
begin
  Result := False;

  if (not value.IsEmpty) and (value.IsType<TField>) then
    if (not value.AsType<TField>.IsNull) then
      Exit(CompareDate(value.AsType<TField>.AsDateTime, Now) = GreaterThanValue)
    else
      Exit(True);

  if value.IsType<TDateTime> then
    Exit(CompareDate(value.AsType<TDateTime>, Now) = GreaterThanValue);
end;

{ TDecimalMaxValidator }

procedure TDecimalMaxValidator.Initialize(const attribute: ConstraintAttribute; const obj: TObject);
begin
  inherited;
  fMaxValue := DecimalMaxAttribute(attribute).Value;
end;

function TDecimalMaxValidator.IsValid(const value: TValue): Boolean;
begin
  Result := False;

  if (not value.IsEmpty) and (value.IsType<TField>) then
    if (not value.AsType<TField>.IsNull) then
      Exit(value.AsType<TField>.AsFloat <= fMaxValue)
    else
      Exit(True);

  if value.IsType<Double> then
    Exit(value.AsType<Double> <= fMaxValue);
end;

function TDecimalMaxValidator.ProcessingMessage(const msg: string): string;
begin
  Result := msg.Replace('{value}', fMaxValue.ToString);
end;

{ TDecimalMinValidator }

procedure TDecimalMinValidator.Initialize(const attribute: ConstraintAttribute; const obj: TObject);
begin
  inherited;
  fMinValue := DecimalMaxAttribute(attribute).Value;
end;

function TDecimalMinValidator.IsValid(const value: TValue): Boolean;
begin
  Result := False;

  if (not value.IsEmpty) and (value.IsType<TField>) then
    if (not value.AsType<TField>.IsNull) then
      Exit(value.AsType<TField>.AsFloat >= fMinValue)
    else
      Exit(True);

  if value.IsType<Double> then
    Exit(value.AsType<Double> >= fMinValue);
end;

function TDecimalMinValidator.ProcessingMessage(const msg: string): string;
begin
  Result := msg.Replace('{value}', fMinValue.ToString);
end;

{ TNotNullWhenValidator }

procedure TNotNullWhenValidator.Initialize(const attribute: ConstraintAttribute; const obj: TObject);
begin
  inherited;
  fObj := obj;
  fName := NotNullWhenAttribute(attribute).Name;
  fValue := NotNullWhenAttribute(attribute).Value;
end;

function TNotNullWhenValidator.IsValid(const value: TValue): Boolean;
var
  rttiContext: TRttiContext;
  rttiField: TRttiField;
  rttiProperty: TRttiProperty;
begin
  Result := True;
  if Assigned(fObj) and (not fName.IsEmpty) and (not fValue.IsEmpty) then
  begin
    rttiContext := TRttiContext.Create;
    try
      if (fObj is TDataSet) then
        fObj := TDataSet(fObj).Owner;

      rttiField := rttiContext.GetType(fObj.ClassType).GetField(fName);
      if Assigned(rttiField) and (not rttiField.GetValue(fObj).IsEmpty) then
        if (rttiField.GetValue(fObj).IsType<TField>) then
        begin
          if rttiField.GetValue(fObj).AsType<TField>.AsString.Equals(fValue) then
            Exit(inherited IsValid(value));
        end
        else if rttiField.GetValue(fObj).ToString.Equals(fValue) then
          Exit(inherited IsValid(value));

      rttiProperty := rttiContext.GetType(fObj.ClassType).GetProperty(fName);
      if Assigned(rttiProperty) and (not rttiProperty.GetValue(fObj).IsEmpty) then
        if rttiProperty.GetValue(fObj).ToString.Equals(fValue) then
          Exit(inherited IsValid(value));
    finally
      rttiContext.Free;
    end;
  end;
end;

{ TNotNullInValidator }

procedure TNotNullInValidator.Initialize(const attribute: ConstraintAttribute; const obj: TObject);
begin
  inherited;
  fObj := obj;
  fName := NotNullInAttribute(attribute).Name;
  fValues := NotNullInAttribute(attribute).Values;
end;

function TNotNullInValidator.IsValid(const value: TValue): Boolean;
var
  rttiContext: TRttiContext;
  rttiField: TRttiField;
  rttiProperty: TRttiProperty;
begin
  Result := True;
  if Assigned(fObj) and (not fName.IsEmpty) and (Length(fValues) > 0) then
  begin
    rttiContext := TRttiContext.Create;
    try
      if (fObj is TDataSet) then
        fObj := TDataSet(fObj).Owner;

      rttiField := rttiContext.GetType(fObj.ClassType).GetField(fName);
      if Assigned(rttiField) and (not rttiField.GetValue(fObj).IsEmpty) then
        if (rttiField.GetValue(fObj).IsType<TField>) then
        begin
          if MatchStr(rttiField.GetValue(fObj).AsType<TField>.AsString, fValues) then
            Exit(inherited IsValid(value));
        end
        else if MatchStr(rttiField.GetValue(fObj).ToString, fValues) then
          Exit(inherited IsValid(value));

      rttiProperty := rttiContext.GetType(fObj.ClassType).GetProperty(fName);
      if Assigned(rttiProperty) and (not rttiProperty.GetValue(fObj).IsEmpty) then
        if MatchStr(rttiProperty.GetValue(fObj).ToString, fValues) then
          Exit(inherited IsValid(value));
    finally
      rttiContext.Free;
    end;
  end;
end;

{ TAssertInValidator }

procedure TAssertInValidator.Initialize(const attribute: ConstraintAttribute; const obj: TObject);
begin
  inherited;
  fValues := AssertInAttribute(attribute).Values;
end;

function TAssertInValidator.IsValid(const value: TValue): Boolean;
begin
  Result := True;
  if not value.IsEmpty then
  begin
    if value.IsType<TField> then
      if not value.AsType<TField>.IsNull then
        Exit(IsStringInValues(value.AsType<TField>.AsString));
    if not value.ToString.IsEmpty then
      Exit(IsStringInValues(value.ToString));
  end;
end;

function TAssertInValidator.ProcessingMessage(const msg: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := Low(fValues) to High(fValues) do
  begin
    Result := Result + fValues[i];
    if (i < High(fValues)) then
      Result := Result + ', ';
  end;
  Result := msg.Replace('{value}', Result);
end;

function TAssertInValidator.IsStringInValues(const str: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := Low(fValues) to High(fValues) do
    if (fValues[i] = str) then
      Exit(True);
end;

end.
