unit InfraFwk4D.Driver.FireDAC.Persistence;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  InfraFwk4D.Driver,
  InfraFwk4D.Driver.FireDAC,
  InfraFwk4D.Iterator.DataSet;

type

  TFireDACPersistenceAdapter = class(TDataModule)
  strict private
    FQueryDictionary: TDictionary<string, IDriverQueryBuilder<TFDQuery>>;
  strict protected
    function GetConnection(): TFireDACConnectionAdapter; virtual; abstract;
    procedure ConfigureDataSetsConnection(); virtual; abstract;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    function QueryBuilder(const pDataSet: TFDQuery): IDriverQueryBuilder<TFDQuery>; overload;
    function QueryBuilder(const pDataSetName: string): IDriverQueryBuilder<TFDQuery>; overload;

    function BuildIterator(const pDataSet: TFDQuery): IIteratorDataSet; overload;
    function BuildIterator(const pDataSetName: string): IIteratorDataSet; overload;

    property Connection: TFireDACConnectionAdapter read GetConnection;
  end;

implementation

{ %CLASSGROUP 'System.Classes.TPersistent' }

{$R *.dfm}

{ TFireDACPersistenceAdapter }

function TFireDACPersistenceAdapter.QueryBuilder(
  const pDataSet: TFDQuery): IDriverQueryBuilder<TFDQuery>;
begin
  if not FQueryDictionary.ContainsKey(pDataSet.Name) then
    FQueryDictionary.AddOrSetValue(pDataSet.Name, CreateFireDACQueryBuilder(pDataSet));
  Result := FQueryDictionary.Items[pDataSet.Name];
end;

procedure TFireDACPersistenceAdapter.AfterConstruction;
begin
  inherited AfterConstruction;
  FQueryDictionary := TDictionary<string, IDriverQueryBuilder<TFDQuery>>.Create();
  ConfigureDataSetsConnection();
end;

procedure TFireDACPersistenceAdapter.BeforeDestruction;
begin
  FreeAndNil(FQueryDictionary);
  inherited BeforeDestruction;
end;

function TFireDACPersistenceAdapter.BuildIterator(const pDataSet: TFDQuery): IIteratorDataSet;
begin
  Result := IteratorDataSetFactory.Build(pDataSet, False);
end;

function TFireDACPersistenceAdapter.BuildIterator(const pDataSetName: string): IIteratorDataSet;
begin
  Result := BuildIterator(TFDQuery(FindComponent(pDataSetName)));
end;

function TFireDACPersistenceAdapter.QueryBuilder(
  const pDataSetName: string): IDriverQueryBuilder<TFDQuery>;
begin
  Result := QueryBuilder(TFDQuery(FindComponent(pDataSetName)));
end;

end.
