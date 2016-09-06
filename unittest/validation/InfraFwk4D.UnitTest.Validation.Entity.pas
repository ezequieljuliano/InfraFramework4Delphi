unit InfraFwk4D.UnitTest.Validation.Entity;

interface

uses
  System.SysUtils,
  InfraFwk4D.Validation.Default.Attributes;

type

  TEntity = class
  private
    [AssertFalse]
    fFalseValue: Boolean;
    fTrueValue: Boolean;
    [Max(20)]
    fMaxValue: Integer;
    fMinValue: Integer;
    [Size(5, 10)]
    fSizeValue: string;
    [NotNull]
    fNotNullValue: string;
    [Null]
    fNullValue: string;
    [Past]
    fPastValue: TDateTime;
    [Present]
    fPresentValue: TDateTime;
    [Future]
    fFutureValue: TDateTime;
    [DecimalMax(20.5)]
    fDecimalMaxValue: Double;
    [DecimalMin(10.5)]
    fDecimalMinValue: Double;
    [NotNullWhen('fMaxValue', 20)]
    fNotNullWhenValue: string;
    [NotNullWhen('fFalseValue', False)]
    fNotNullWhenBooleanValue: string;
  public
    constructor Create;

    property FalseValue: Boolean read fFalseValue write fFalseValue;
    [AssertTrue]
    property TrueValue: Boolean read fTrueValue write fTrueValue;
    property MaxValue: Integer read fMaxValue write fMaxValue;
    [Min(5)]
    property MinValue: Integer read fMinValue write fMinValue;
    property SizeValue: string read fSizeValue write fSizeValue;
    property NotNullValue: string read fNotNullValue write fNotNullValue;
    property NullValue: string read fNullValue write fNullValue;
    property PastValue: TDateTime read fPastValue write fPastValue;
    property PresentValue: TDateTime read fPresentValue write fPresentValue;
    property FutureValue: TDateTime read fFutureValue write fFutureValue;
    property DecimalMaxValue: Double read fDecimalMaxValue write fDecimalMaxValue;
    property DecimalMinValue: Double read fDecimalMinValue write fDecimalMinValue;
    property NotNullWhenValue: string read fNotNullWhenValue write fNotNullWhenValue;
    property NotNullWhenBooleanValue: string read fNotNullWhenBooleanValue write fNotNullWhenBooleanValue;
  end;

implementation

{ TEntity }

constructor TEntity.Create;
begin
  fFalseValue := False;
  fTrueValue := True;
  fMaxValue := 20;
  fMinValue := 5;
  fSizeValue := 'Ezequiel';
  fNotNullValue := 'NotNull';
  fNullValue := '';
  fPastValue := Date - 1;
  fPresentValue := Date;
  fFutureValue := Date + 1;
  fDecimalMaxValue := 20.5;
  fDecimalMinValue := 10.5;
  fNotNullWhenValue := 'NotNullWhen';
  fNotNullWhenBooleanValue := 'NotNullWhenBooleanValue';
end;

end.
