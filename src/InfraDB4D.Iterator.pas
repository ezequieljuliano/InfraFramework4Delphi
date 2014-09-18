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

  TIteratorDataSetFactory = class sealed
  public
    class function Get(const pDataSet: TDataSet): IIteratorDataSet; overload; static;
    class function Get(const pDataSet: TDataSet; const pDestroyDataSet: Boolean): IIteratorDataSet; overload; static;
  end;

implementation

type

  TIteratorDataSet = class sealed(TInterfacedObject, IIteratorDataSet)
  strict private
    CurrentCount: Integer;
    DataSet: TDataSet;
    DestroyDataSet: Boolean;

    function HasNext(): Boolean;
    function Fields: TFields;
    function FieldByName(const pFieldName: string): TField;

    function RecIndex: Integer;

    function GetDataSet: TDataSet;

    destructor Destroy(); override;
    function IsEmpty(): Boolean;
  private
    constructor Create(const pDataSet: TDataSet; const pDestroyDataSet: Boolean); overload;
  end;

{ TIteratorDataSet }

constructor TIteratorDataSet.Create(const pDataSet: TDataSet; const pDestroyDataSet: Boolean);
begin
  DataSet := pDataSet;

  if (not(DataSet.Active)) then
    DataSet.Open;

  DataSet.First();
  CurrentCount := 0;

  DestroyDataSet := False;
  DestroyDataSet := pDestroyDataSet;
end;

function TIteratorDataSet.GetDataSet: TDataSet;
begin
  Result := DataSet;
end;

destructor TIteratorDataSet.Destroy;
begin
  if (DestroyDataSet) then
    FreeAndNil(DataSet);
  inherited;
end;

function TIteratorDataSet.FieldByName(const pFieldName: string): TField;
begin
  Result := DataSet.FieldByName(pFieldName);
end;

function TIteratorDataSet.Fields: TFields;
begin
  Result := DataSet.Fields;
end;

function TIteratorDataSet.HasNext: Boolean;
begin
  if (CurrentCount = 0) then
    CurrentCount := 1
  else
    Inc(CurrentCount);

  if (CurrentCount > 1) then
    DataSet.Next();

  Result := not DataSet.Eof;
end;

function TIteratorDataSet.IsEmpty: Boolean;
begin
  Result := DataSet.IsEmpty();
end;

function TIteratorDataSet.RecIndex: Integer;
begin
  Result := CurrentCount;
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
