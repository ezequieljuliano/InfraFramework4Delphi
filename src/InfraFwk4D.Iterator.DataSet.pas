unit InfraFwk4D.Iterator.DataSet;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB;

type

  EIteratorDataSetException = class(Exception);

  IIteratorDataSet = interface
    ['{A9FC32EB-0436-435B-82A2-61497C77845A}']
    function GetDataSet(): TDataSet;

    function HasNext(): Boolean;
    function RecIndex: Integer;
    function IsEmpty(): Boolean;
    function Fields: TFields;
    function FieldByName(const pFieldName: string): TField;

    procedure FillSameFields(pTarget: TDataSet); overload;
    procedure FillSameFields(pTarget: IIteratorDataSet); overload;
    procedure SetSameFieldsValues(pProvider: TDataSet); overload;
    procedure SetSameFieldsValues(pProvider: IIteratorDataSet); overload;

    property DataSet: TDataSet read GetDataSet;
  end;

  IteratorDataSetFactory = class sealed
  strict private
  const
    CanNotBeInstantiatedException = 'This class can not be instantiated!';
  strict private

    {$HINTS OFF}

    constructor Create;

    {$HINTS ON}

  public
    class function Build(pDataSet: TDataSet): IIteratorDataSet; overload; static;
    class function Build(pDataSet: TDataSet; const pOwnsDataSet: Boolean): IIteratorDataSet; overload; static;
  end;

implementation

type

  TIteratorDataSet = class(TInterfacedObject, IIteratorDataSet)
  strict private
    FDataSet: TDataSet;
    FCurrentCount: Integer;
    FOwnsDataSet: Boolean;
    function GetDataSet(): TDataSet;
  public
    constructor Create(pDataSet: TDataSet; const pOwnsDataSet: Boolean);
    destructor Destroy(); override;

    function HasNext(): Boolean;
    function RecIndex: Integer;
    function IsEmpty(): Boolean;
    function Fields: TFields;
    function FieldByName(const pFieldName: string): TField;

    procedure FillSameFields(pTarget: TDataSet); overload;
    procedure FillSameFields(pTarget: IIteratorDataSet); overload;
    procedure SetSameFieldsValues(pProvider: TDataSet); overload;
    procedure SetSameFieldsValues(pProvider: IIteratorDataSet); overload;

    property DataSet: TDataSet read GetDataSet;
  end;

  { TIteratorDataSet }

constructor TIteratorDataSet.Create(pDataSet: TDataSet; const pOwnsDataSet: Boolean);
begin
  FDataSet := pDataSet;
  FCurrentCount := 0;
  FOwnsDataSet := pOwnsDataSet;

  if not(FDataSet.Active) then
  begin
    FDataSet.Open;
    FDataSet.First;
  end
  else
    FCurrentCount := FDataSet.RecNo;
end;

destructor TIteratorDataSet.Destroy;
begin
  if (FOwnsDataSet) then
    FreeAndNil(FDataSet);
  inherited;
end;

function TIteratorDataSet.FieldByName(const pFieldName: string): TField;
begin
  Result := FDataSet.FieldByName(pFieldName);
end;

function TIteratorDataSet.Fields: TFields;
begin
  Result := FDataSet.Fields;
end;

procedure TIteratorDataSet.FillSameFields(pTarget: TDataSet);
var
  I, J: Integer;
begin
  for I := 0 to Pred(FDataSet.FieldCount) do
    for J := 0 to Pred(pTarget.FieldCount) do
      if (UpperCase(FDataSet.Fields[I].FieldName) = UpperCase(pTarget.Fields[J].FieldName)) then
      begin
        if not(pTarget.State in [dsInsert, dsEdit]) then
          pTarget.Edit;
        pTarget.Fields[J].Value := FDataSet.Fields[I].Value;
      end;
end;

procedure TIteratorDataSet.FillSameFields(pTarget: IIteratorDataSet);
begin
  FillSameFields(pTarget.GetDataSet);
end;

function TIteratorDataSet.GetDataSet: TDataSet;
begin
  Result := FDataSet;
end;

function TIteratorDataSet.HasNext: Boolean;
begin
  if (FCurrentCount = 0) then
    FCurrentCount := 1
  else
    Inc(FCurrentCount);

  if (FCurrentCount > 1) then
    FDataSet.Next();

  Result := not FDataSet.Eof;
end;

function TIteratorDataSet.IsEmpty: Boolean;
begin
  Result := FDataSet.IsEmpty();
end;

function TIteratorDataSet.RecIndex: Integer;
begin
  Result := FCurrentCount;
end;

procedure TIteratorDataSet.SetSameFieldsValues(pProvider: IIteratorDataSet);
begin
  SetSameFieldsValues(pProvider.GetDataSet);
end;

procedure TIteratorDataSet.SetSameFieldsValues(pProvider: TDataSet);
var
  I, J: Integer;
begin
  for I := 0 to Pred(pProvider.FieldCount) do
    for J := 0 to Pred(FDataSet.FieldCount) do
      if (UpperCase(pProvider.Fields[I].FieldName) = UpperCase(FDataSet.Fields[J].FieldName)) then
      begin
        if not(FDataSet.State in [dsInsert, dsEdit]) then
          FDataSet.Edit;
        FDataSet.Fields[J].Value := pProvider.Fields[I].Value;
      end;
end;

{ IteratorDataSetFactory }

class function IteratorDataSetFactory.Build(pDataSet: TDataSet): IIteratorDataSet;
begin
  Result := TIteratorDataSet.Create(pDataSet, False);
end;

class function IteratorDataSetFactory.Build(pDataSet: TDataSet;
  const pOwnsDataSet: Boolean): IIteratorDataSet;
begin
  Result := TIteratorDataSet.Create(pDataSet, pOwnsDataSet);
end;

constructor IteratorDataSetFactory.Create;
begin
  raise EIteratorDataSetException.Create(CanNotBeInstantiatedException);
end;

end.
