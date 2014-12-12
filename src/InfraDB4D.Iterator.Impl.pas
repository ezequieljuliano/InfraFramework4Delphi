unit InfraDB4D.Iterator.Impl;

interface

uses
  InfraDB4D.Iterator,
  Data.DB,
  System.Generics.Collections,
  System.SysUtils;

type

  TIterator<T: TDataSet> = class(TInterfacedObject, IIterator<T>)
  strict private
    FCurrentCount: Integer;
    FDataSet: T;
    FDestroyDataSet: Boolean;
  public
    constructor Create(const pDataSet: T; const pDestroyDataSet: Boolean);
    destructor Destroy(); override;

    function HasNext(): Boolean;
    function RecIndex: Integer;
    function IsEmpty(): Boolean;
    function Fields: TFields;
    function FieldByName(const pFieldName: string): TField;

    procedure FillSameFields(const pTarget: T); overload;
    procedure FillSameFields(const pTarget: IIterator<T>); overload;
    procedure SetSameFieldsValues(const pProvider: T); overload;
    procedure SetSameFieldsValues(const pProvider: IIterator<T>); overload;

    function GetDataSet: T;
  end;

  TIteratorDataSet = class(TIterator<TDataSet>, IIteratorDataSet);

implementation

{ TIterator<T> }

constructor TIterator<T>.Create(const pDataSet: T; const pDestroyDataSet: Boolean);
begin
  FDataSet := pDataSet;

  if (not(FDataSet.Active)) then
    FDataSet.Open;

  FDataSet.First();

  FCurrentCount := 0;
  FDestroyDataSet := pDestroyDataSet;
end;

destructor TIterator<T>.Destroy;
begin
  if (FDestroyDataSet) then
    FreeAndNil(FDataSet);
  inherited;
end;

function TIterator<T>.FieldByName(const pFieldName: string): TField;
begin
  Result := FDataSet.FieldByName(pFieldName);
end;

function TIterator<T>.Fields: TFields;
begin
  Result := FDataSet.Fields;
end;

procedure TIterator<T>.FillSameFields(const pTarget: IIterator<T>);
begin
  FillSameFields(pTarget.GetDataSet);
end;

procedure TIterator<T>.FillSameFields(const pTarget: T);
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

function TIterator<T>.GetDataSet: T;
begin
  Result := FDataSet;
end;

function TIterator<T>.HasNext: Boolean;
begin
  if (FCurrentCount = 0) then
    FCurrentCount := 1
  else
    Inc(FCurrentCount);

  if (FCurrentCount > 1) then
    FDataSet.Next();

  Result := not FDataSet.Eof;
end;

function TIterator<T>.IsEmpty: Boolean;
begin
  Result := FDataSet.IsEmpty();
end;

function TIterator<T>.RecIndex: Integer;
begin
  Result := FCurrentCount;
end;

procedure TIterator<T>.SetSameFieldsValues(const pProvider: T);
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

procedure TIterator<T>.SetSameFieldsValues(const pProvider: IIterator<T>);
begin
  SetSameFieldsValues(pProvider.GetDataSet);
end;

end.
