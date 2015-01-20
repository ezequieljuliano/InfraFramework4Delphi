unit InfraFwk4D.Driver.IBX.Persistence;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  IBX.IBCustomDataSet,
  InfraFwk4D.Driver,
  InfraFwk4D.Driver.IBX,
  InfraFwk4D.Iterator.DataSet;

type

  TIBXPersistenceAdapter = class(TDataModule)
  strict private
    FQueryDictionary: TDictionary<string, IDriverQueryBuilder<TIBDataSet>>;
  strict protected
    function GetConnection(): TIBXConnectionAdapter; virtual; abstract;
    procedure ConfigureDataSetsConnection(); virtual; abstract;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    function QueryBuilder(const pDataSet: TIBDataSet): IDriverQueryBuilder<TIBDataSet>; overload;
    function QueryBuilder(const pDataSetName: string): IDriverQueryBuilder<TIBDataSet>; overload;

    function BuildIterator(const pDataSet: TIBDataSet): IIteratorDataSet; overload;
    function BuildIterator(const pDataSetName: string): IIteratorDataSet; overload;

    property Connection: TIBXConnectionAdapter read GetConnection;
  end;

implementation

{ %CLASSGROUP 'System.Classes.TPersistent' }

{$R *.dfm}

{ TIBXPersistenceAdapter }

procedure TIBXPersistenceAdapter.AfterConstruction;
begin
  inherited AfterConstruction;
  FQueryDictionary := TDictionary<string, IDriverQueryBuilder<TIBDataSet>>.Create();
  ConfigureDataSetsConnection();
end;

procedure TIBXPersistenceAdapter.BeforeDestruction;
begin
  FreeAndNil(FQueryDictionary);
  inherited BeforeDestruction;
end;

function TIBXPersistenceAdapter.BuildIterator(const pDataSetName: string): IIteratorDataSet;
begin
  Result := BuildIterator(TIBDataSet(FindComponent(pDataSetName)));
end;

function TIBXPersistenceAdapter.BuildIterator(const pDataSet: TIBDataSet): IIteratorDataSet;
begin
  Result := IteratorDataSetFactory.Build(pDataSet, False);
end;

function TIBXPersistenceAdapter.QueryBuilder(
  const pDataSet: TIBDataSet): IDriverQueryBuilder<TIBDataSet>;
begin
  if not FQueryDictionary.ContainsKey(pDataSet.Name) then
    FQueryDictionary.AddOrSetValue(pDataSet.Name, CreateIBXQueryBuilder(pDataSet));
  Result := FQueryDictionary.Items[pDataSet.Name];
end;

function TIBXPersistenceAdapter.QueryBuilder(
  const pDataSetName: string): IDriverQueryBuilder<TIBDataSet>;
begin
  Result := QueryBuilder(TIBDataSet(FindComponent(pDataSetName)));
end;

end.
