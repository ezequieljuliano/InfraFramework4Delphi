unit InfraFwk4D.Validation.Default.Attributes;

interface

uses
  System.SysUtils,
  InfraFwk4D.Validation;

type

  AssertFalseAttribute = class(ConstraintAttribute)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  AssertTrueAttribute = class(ConstraintAttribute)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  MaxAttribute = class(ConstraintAttribute)
  private
    fValue: Integer;
  protected
    { protected declarations }
  public
    constructor Create(const value: Integer);

    property Value: Integer read fValue;
  end;

  MinAttribute = class(ConstraintAttribute)
  private
    fValue: Integer;
  protected
    { protected declarations }
  public
    constructor Create(const value: Integer);

    property Value: Integer read fValue;
  end;

  SizeAttribute = class(ConstraintAttribute)
  private
    fMin: Integer;
    fMax: Integer;
  protected
    { protected declarations }
  public
    constructor Create(const min, max: Integer); overload;
    constructor Create(const max: Integer); overload;

    property Min: Integer read fMin;
    property Max: Integer read fMax;
  end;

  DecimalMaxAttribute = class(ConstraintAttribute)
  private
    fValue: Double;
  protected
    { protected declarations }
  public
    constructor Create(const value: Double);

    property Value: Double read fValue;
  end;

  DecimalMinAttribute = class(ConstraintAttribute)
  private
    fValue: Double;
  protected
    { protected declarations }
  public
    constructor Create(const value: Double);

    property Value: Double read fValue;
  end;

  NotNullAttribute = class(ConstraintAttribute)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  NotNullWhenAttribute = class(ConstraintAttribute)
  private
    fName: string;
    fValue: string;
  protected
    { protected declarations }
  public
    constructor Create(const name: string; const value: string); overload;
    constructor Create(const name: string; const value: Integer); overload;
    constructor Create(const name: string; const value: Double); overload;
    constructor Create(const name: string; const value: Boolean); overload;

    property Name: string read fName;
    property Value: string read fValue;
  end;

  NotNullInAttribute = class(ConstraintAttribute)
  private
    fName: string;
    fValues: TArray<String>;
  protected
    { protected declarations }
  public
    constructor Create(const name: string; const values: string);

    property Name: string read fName;
    property Values: TArray<String> read fValues;
  end;

  NullAttribute = class(ConstraintAttribute)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  PastAttribute = class(ConstraintAttribute)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  PresentAttribute = class(ConstraintAttribute)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  FutureAttribute = class(ConstraintAttribute)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

implementation

{ MaxAttribute }

constructor MaxAttribute.Create(const value: Integer);
begin
  inherited Create;
  fValue := value;
end;

{ MinAttribute }

constructor MinAttribute.Create(const value: Integer);
begin
  inherited Create;
  fValue := value;
end;

{ SizeAttribute }

constructor SizeAttribute.Create(const min, max: Integer);
begin
  inherited Create;
  fMin := min;
  fMax := max;
end;

constructor SizeAttribute.Create(const max: Integer);
begin
  Create(0, max);
end;

{ DecimalMaxAttribute }

constructor DecimalMaxAttribute.Create(const value: Double);
begin
  inherited Create;
  fValue := value;
end;

{ DecimalMinAttribute }

constructor DecimalMinAttribute.Create(const value: Double);
begin
  inherited Create;
  fValue := value;
end;

{ NotNullWhenAttribute }

constructor NotNullWhenAttribute.Create(const name: string; const value: string);
begin
  inherited Create;
  fName := name;
  fValue := value;
end;

constructor NotNullWhenAttribute.Create(const name: string; const value: Integer);
begin
  Create(name, value.ToString);
end;

constructor NotNullWhenAttribute.Create(const name: string; const value: Double);
begin
  Create(name, value.ToString);
end;

constructor NotNullWhenAttribute.Create(const name: string; const value: Boolean);
begin
  Create(name, BoolToStr(value, True))
end;

{ NotNullInAttribute }

constructor NotNullInAttribute.Create(const name, values: string);
begin
  inherited Create;
  fName := name;
  fValues := values.Split([';']);
end;

end.
