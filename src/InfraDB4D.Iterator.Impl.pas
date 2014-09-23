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
    function HasNext(): Boolean;
    function RecIndex: Integer;
    function IsEmpty(): Boolean;
    function Fields: TFields;
    function FieldByName(const pFieldName: string): TField;

    function GetDataSet: T;

    constructor Create(const pDataSet: T; const pDestroyDataSet: Boolean);
    destructor Destroy(); override;
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

end.
