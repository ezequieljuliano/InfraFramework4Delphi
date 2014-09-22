unit InfraDB4D.Iterator;

interface

uses
  System.SysUtils,
  Data.DB;

type

  IIteratorDataSet = interface
    ['{E3E84A64-DF07-498F-80C6-E3640EB37C9A}']
    function HasNext(): Boolean;
    function Fields: TFields;
    function FieldByName(const pFieldName: string): TField;

    function RecIndex: Integer;
    function GetDataSet: TDataSet;

    function IsEmpty(): Boolean;
  end;

  TIteratorDataSetFactory = class
  public
    class function Get(const pDataSet: TDataSet): IIteratorDataSet; overload; static;
    class function Get(const pDataSet: TDataSet; const pDestroyDataSet: Boolean): IIteratorDataSet; overload; static;
  end;

implementation

type

  TIteratorDataSet = class(TInterfacedObject, IIteratorDataSet)
  strict private
    FCurrentCount: Integer;
    FDataSet: TDataSet;
    FDestroyDataSet: Boolean;

    function HasNext(): Boolean;
    function Fields: TFields;
    function FieldByName(const pFieldName: string): TField;

    function RecIndex: Integer;
    function GetDataSet: TDataSet;

    function IsEmpty(): Boolean;
  public
    constructor Create(const pDataSet: TDataSet; const pDestroyDataSet: Boolean);
    destructor Destroy(); override;
  end;

  { TIteratorDataSet }

constructor TIteratorDataSet.Create(const pDataSet: TDataSet; const pDestroyDataSet: Boolean);
begin
  FDataSet := pDataSet;

  if (not(FDataSet.Active)) then
    FDataSet.Open;

  FDataSet.First();
  FCurrentCount := 0;

  FDestroyDataSet := False;
  FDestroyDataSet := pDestroyDataSet;
end;

function TIteratorDataSet.GetDataSet: TDataSet;
begin
  Result := FDataSet;
end;

destructor TIteratorDataSet.Destroy;
begin
  if (FDestroyDataSet) then
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

{ TIteratorDataSetFactory }

class function TIteratorDataSetFactory.Get(const pDataSet: TDataSet): IIteratorDataSet;
begin
  Result := TIteratorDataSet.Create(pDataSet, False);
end;

class function TIteratorDataSetFactory.Get(const pDataSet: TDataSet; const pDestroyDataSet: Boolean): IIteratorDataSet;
begin
  Result := TIteratorDataSet.Create(pDataSet, pDestroyDataSet);
end;

end.
