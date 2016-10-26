unit InfraFwk4D.UnitTest.Validation.DataModule;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Datasnap.DBClient,
  InfraFwk4D.Validation.Default.Attributes;

type

  TModel = class(TDataModule)
    Entity: TClientDataSet;

    [AssertFalse]
    EntityFalseValue: TBooleanField;

    [AssertTrue]
    EntityTrueValue: TBooleanField;

    [Max(20)]
    EntityMaxValue: TIntegerField;

    [Min(5)]
    EntityMinValue: TIntegerField;

    [Size(5, 10)]
    EntitySizeValue: TStringField;

    [NotNull]
    EntityNotNullValue: TStringField;

    [Null]
    EntityNullValue: TStringField;

    [Past]
    EntityPastValue: TDateField;

    [Present]
    EntityPresentValue: TDateField;

    [Future]
    EntityFutureValue: TDateField;

    [DecimalMax(20.5)]
    EntityDecimalMaxValue: TFloatField;

    [DecimalMin(10.5)]
    EntityDecimalMinValue: TFloatField;

    [NotNullWhen('EntityMaxValue', '20')]
    EntityNotNullWhenValue: TStringField;

    [NotNullWhen('EntityFalseValue', False)]
    EntityNotNullWhenBooleanValue: TStringField;

    [NotNullIn('EntityMaxValue', '10;20;30;40')]
    EntityNotNullInValues: TStringField;

    [AssertIn('10;20;30')]
    EntityAssertInValue: TStringField;

    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{ %CLASSGROUP 'System.Classes.TPersistent' }

{$R *.dfm}

procedure TModel.DataModuleCreate(Sender: TObject);
begin
  Entity.CreateDataSet;
  Entity.Edit;
  EntityFalseValue.AsBoolean := False;
  EntityTrueValue.AsBoolean := True;
  EntityMaxValue.AsInteger := 20;
  EntityMinValue.AsInteger := 5;
  EntitySizeValue.AsString := 'Ezequiel';
  EntityNotNullValue.AsString := 'NotNull';
  EntityNullValue.AsString := '';
  EntityPastValue.AsDateTime := Date - 1;
  EntityPresentValue.AsDateTime := Date;
  EntityFutureValue.AsDateTime := Date + 1;
  EntityDecimalMaxValue.AsFloat := 20.5;
  EntityDecimalMinValue.AsFloat := 10.5;
  EntityNotNullWhenValue.AsString := 'NotNullWhen';
  EntityNotNullWhenBooleanValue.AsString := 'NotNullWhenBooleanValue';
  EntityNotNullInValues.AsString := 'EntityNotNullInValues';
  EntityAssertInValue.AsString := '10';
  Entity.Post;
end;

end.
