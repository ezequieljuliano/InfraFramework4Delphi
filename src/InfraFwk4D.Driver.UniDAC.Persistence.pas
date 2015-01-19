unit InfraFwk4D.Driver.UniDAC.Persistence;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Uni,
  InfraFwk4D.Driver,
  InfraFwk4D.Driver.UniDAC,
  InfraFwk4D.Iterator.DataSet;

type

  TUniDACPersistenceAdapter = class(TDataModule)
  strict private
    FQueryDictionary: TDictionary<string, IDriverQueryBuilder<TUniQuery>>;
  strict protected
    function GetConnection(): TUniDACConnectionAdapter; virtual; abstract;
    procedure ConfigureDataSetsConnection(); virtual; abstract;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    function QueryBuilder(const pDataSet: TUniQuery): IDriverQueryBuilder<TUniQuery>; overload;
    function QueryBuilder(const pDataSetName: string): IDriverQueryBuilder<TUniQuery>; overload;

    function BuildIterator(const pDataSet: TUniQuery): IIteratorDataSet; overload;
    function BuildIterator(const pDataSetName: string): IIteratorDataSet; overload;

    property Connection: TUniDACConnectionAdapter read GetConnection;
  end;

implementation

{ %CLASSGROUP 'System.Classes.TPersistent' }

{$R *.dfm}

{ TUniDACPersistenceAdapter }

procedure TUniDACPersistenceAdapter.AfterConstruction;
begin
  inherited AfterConstruction;
  FQueryDictionary := TDictionary<string, IDriverQueryBuilder<TUniQuery>>.Create();
  ConfigureDataSetsConnection();
end;

procedure TUniDACPersistenceAdapter.BeforeDestruction;
begin
  FreeAndNil(FQueryDictionary);
  inherited BeforeDestruction;
end;

function TUniDACPersistenceAdapter.BuildIterator(const pDataSetName: string): IIteratorDataSet;
begin
  Result := BuildIterator(TUniQuery(FindComponent(pDataSetName)));
end;

function TUniDACPersistenceAdapter.BuildIterator(const pDataSet: TUniQuery): IIteratorDataSet;
begin
  Result := IteratorDataSetFactory.Build(pDataSet, False);
end;

function TUniDACPersistenceAdapter.QueryBuilder(
  const pDataSet: TUniQuery): IDriverQueryBuilder<TUniQuery>;
begin
  if not FQueryDictionary.ContainsKey(pDataSet.Name) then
    FQueryDictionary.AddOrSetValue(pDataSet.Name, CreateUniDACQueryBuilder(pDataSet));
  Result := FQueryDictionary.Items[pDataSet.Name];
end;

function TUniDACPersistenceAdapter.QueryBuilder(
  const pDataSetName: string): IDriverQueryBuilder<TUniQuery>;
begin
  Result := QueryBuilder(TUniQuery(FindComponent(pDataSetName)));
end;

end.
