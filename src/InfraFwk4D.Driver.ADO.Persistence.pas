unit InfraFwk4D.Driver.ADO.Persistence;

interface

uses
  SysUtils,
  Classes,
  Generics.Collections,
  ADODB,
  InfraFwk4D.Driver,
  InfraFwk4D.Driver.ADO,
  InfraFwk4D.Iterator.DataSet;

type

  TADOPersistenceAdapter = class(TDataModule)
  strict private
    FQueryDictionary: TDictionary<string, IDriverQueryBuilder<TADOQuery>>;
  strict protected
    function GetConnection(): TADOConnectionAdapter; virtual; abstract;
    procedure ConfigureDataSetsConnection(); virtual; abstract;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    function QueryBuilder(const pDataSet: TADOQuery): IDriverQueryBuilder<TADOQuery>; overload;
    function QueryBuilder(const pDataSetName: string): IDriverQueryBuilder<TADOQuery>; overload;

    function BuildIterator(const pDataSet: TADOQuery): IIteratorDataSet; overload;
    function BuildIterator(const pDataSetName: string): IIteratorDataSet; overload;

    property Connection: TADOConnectionAdapter read GetConnection;
  end;

implementation

{ %CLASSGROUP 'System.Classes.TPersistent' }

{$R *.dfm}

{ TADOPersistenceAdapter }

procedure TADOPersistenceAdapter.AfterConstruction;
begin
  inherited AfterConstruction;
  FQueryDictionary := TDictionary<string, IDriverQueryBuilder<TADOQuery>>.Create();
  ConfigureDataSetsConnection();
end;

procedure TADOPersistenceAdapter.BeforeDestruction;
begin
  FreeAndNil(FQueryDictionary);
  inherited BeforeDestruction;
end;

function TADOPersistenceAdapter.BuildIterator(const pDataSetName: string): IIteratorDataSet;
begin
  Result := BuildIterator(TADOQuery(FindComponent(pDataSetName)));
end;

function TADOPersistenceAdapter.BuildIterator(const pDataSet: TADOQuery): IIteratorDataSet;
begin
  Result := IteratorDataSetFactory.Build(pDataSet, False);
end;

function TADOPersistenceAdapter.QueryBuilder(
  const pDataSet: TADOQuery): IDriverQueryBuilder<TADOQuery>;
begin
  if not FQueryDictionary.ContainsKey(pDataSet.Name) then
    FQueryDictionary.AddOrSetValue(pDataSet.Name, ADOAdapter.NewQueryBuilder(pDataSet));
  Result := FQueryDictionary.Items[pDataSet.Name];
end;

function TADOPersistenceAdapter.QueryBuilder(
  const pDataSetName: string): IDriverQueryBuilder<TADOQuery>;
begin
  Result := QueryBuilder(TADOQuery(FindComponent(pDataSetName)));
end;

end.
