unit InfraFwk4D.Iterator.DataSet;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB;

type

  IIteratorDataSet = interface
    ['{A9FC32EB-0436-435B-82A2-61497C77845A}']
    function HasNext(): Boolean;
    function RecIndex: Integer;
    function IsEmpty(): Boolean;
    function Fields: TFields;
    function FieldByName(const pFieldName: string): TField;

    procedure FillSameFields(const pTarget: TDataSet); overload;
    procedure FillSameFields(const pTarget: IIteratorDataSet); overload;
    procedure SetSameFieldsValues(const pProvider: TDataSet); overload;
    procedure SetSameFieldsValues(const pProvider: IIteratorDataSet); overload;

    function GetDataSet(): TDataSet;
  end;

  IIteratorDataSetFactory = interface
    ['{F2B3487F-80CF-40D4-A6D1-91E5985E0EC9}']
    function Build(const pDataSet: TDataSet): IIteratorDataSet; overload;
    function Build(const pDataSet: TDataSet; const pOwnsDataSet: Boolean): IIteratorDataSet; overload;
  end;

function IteratorDataSetFactory(): IIteratorDataSetFactory;

implementation

type

  TIteratorDataSet = class(TInterfacedObject, IIteratorDataSet)
  strict private
    FDataSet: TDataSet;
    FCurrentCount: Integer;
    FOwnsDataSet: Boolean;
  public
    constructor Create(const pDataSet: TDataSet; const pOwnsDataSet: Boolean);
    destructor Destroy(); override;

    function HasNext(): Boolean;
    function RecIndex: Integer;
    function IsEmpty(): Boolean;
    function Fields: TFields;
    function FieldByName(const pFieldName: string): TField;

    procedure FillSameFields(const pTarget: TDataSet); overload;
    procedure FillSameFields(const pTarget: IIteratorDataSet); overload;
    procedure SetSameFieldsValues(const pProvider: TDataSet); overload;
    procedure SetSameFieldsValues(const pProvider: IIteratorDataSet); overload;

    function GetDataSet(): TDataSet;
  end;

  TIteratorDataSetFactory = class(TInterfacedObject, IIteratorDataSetFactory)
  public
    function Build(const pDataSet: TDataSet): IIteratorDataSet; overload;
    function Build(const pDataSet: TDataSet; const pOwnsDataSet: Boolean): IIteratorDataSet; overload;
  end;

function IteratorDataSetFactory(): IIteratorDataSetFactory;
begin
  Result := TIteratorDataSetFactory.Create();
end;

{ TIteratorDataSet }

constructor TIteratorDataSet.Create(const pDataSet: TDataSet; const pOwnsDataSet: Boolean);
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

procedure TIteratorDataSet.FillSameFields(const pTarget: TDataSet);
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

procedure TIteratorDataSet.FillSameFields(const pTarget: IIteratorDataSet);
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

procedure TIteratorDataSet.SetSameFieldsValues(const pProvider: IIteratorDataSet);
begin
  SetSameFieldsValues(pProvider.GetDataSet);
end;

procedure TIteratorDataSet.SetSameFieldsValues(const pProvider: TDataSet);
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

{ TIteratorDataSetFactory }

function TIteratorDataSetFactory.Build(const pDataSet: TDataSet): IIteratorDataSet;
begin
  Result := TIteratorDataSet.Create(pDataSet, False);
end;

function TIteratorDataSetFactory.Build(const pDataSet: TDataSet;
  const pOwnsDataSet: Boolean): IIteratorDataSet;
begin
  Result := TIteratorDataSet.Create(pDataSet, pOwnsDataSet);
end;

end.
