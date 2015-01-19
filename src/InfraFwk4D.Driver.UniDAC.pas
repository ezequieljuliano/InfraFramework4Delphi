unit InfraFwk4D.Driver.UniDAC;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.SyncObjs,
  Data.DB,
  Uni,
  SQLBuilder4D,
  SQLBuilder4D.Parser,
  InfraFwk4D.Driver,
  InfraFwk4D.Iterator.DataSet;

type

  TUniDACComponentAdapter = class(TDriverComponent<TUniConnection>);

  TUniDACConnectionAdapter = class;

  TUniDACStatementAdapter = class(TDriverStatement<TUniQuery, TUniDACConnectionAdapter>)
  strict protected
    procedure DoExecute(const pQuery: string; const pDataSet: TUniQuery; const pAutoCommit: Boolean); override;

    function DoAsDataSet(const pQuery: string; const pFetchRows: Integer): TUniQuery; override;
    function DoAsIterator(const pQuery: string; const pFetchRows: Integer): IIteratorDataSet; override;
    function DoAsInteger(const pQuery: string): Integer; override;
    function DoAsFloat(const pQuery: string): Double; override;
    function DoAsString(const pQuery: string): string; override;
    function DoAsVariant(const pQuery: string): Variant; override;

    procedure DoInDataSet(const pQuery: string; const pDataSet: TUniQuery); override;
    procedure DoInIterator(const pQuery: string; const pIterator: IIteratorDataSet); override;
  end;

  TUniDACConnectionAdapter = class(TDriverConnection<TUniDACComponentAdapter, TUniDACStatementAdapter>)
  strict private
  const
    cInterBaseProviderName = 'InterBase';
  strict private
    FDefaultAutoCommit: Boolean;
  strict protected
    function DoCreateStatement(): TUniDACStatementAdapter; override;

    procedure DoConnect(); override;
    procedure DoDisconect(); override;

    function DoInTransaction(): Boolean; override;
    procedure DoStartTransaction(); override;
    procedure DoCommit(); override;
    procedure DoRollback(); override;

    procedure DoAfterBuild(); override;
  end;

  TUniDACConnectionManagerAdapter = class(TDriverConnectionManager<string, TUniDACConnectionAdapter>);

  TUniDACBusinessAdapter<TUniDACPersistence: TDataModule> = class(TDriverBusiness<TUniDACPersistence>);

  IUniDACSingletonConnectionAdapter = interface(IDriverSingletonConnection<TUniDACConnectionAdapter>)
    ['{1D4996C4-ADAD-489A-84FC-1D1279F5ED95}']
  end;

function UniDACSingletonConnectionAdapter(): IUniDACSingletonConnectionAdapter;
function CreateUniDACQueryBuilder(const pDataSet: TUniQuery): IDriverQueryBuilder<TUniQuery>;

implementation

uses
  InfraFwk4D;

type

  TUniDACSingletonConnectionAdapter = class(TInterfacedObject, IUniDACSingletonConnectionAdapter)
  private
    class var SingletonConnection: IUniDACSingletonConnectionAdapter;
    class constructor Create;
    class destructor Destroy;
  private
    FConnectionAdapter: TUniDACConnectionAdapter;

    function GetInstance(): TUniDACConnectionAdapter;
  public
    constructor Create;
    destructor Destroy; override;

    property Instance: TUniDACConnectionAdapter read GetInstance;
  end;

  TUniDACQueryBuilder = class(TInterfacedObject, IDriverQueryBuilder<TUniQuery>)
  private
    FDataSet: TUniQuery;
    FQueryBegin: string;
    FQueryParserSelect: ISQLParserSelect;
  public
    constructor Create(const pDataSet: TUniQuery);
    destructor Destroy; override;

    function Initialize(const pSelect: ISQLSelect): IDriverQueryBuilder<TUniQuery>; overload;
    function Initialize(const pWhere: ISQLWhere): IDriverQueryBuilder<TUniQuery>; overload;
    function Initialize(const pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TUniQuery>; overload;
    function Initialize(const pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TUniQuery>; overload;
    function Initialize(const pHaving: ISQLHaving): IDriverQueryBuilder<TUniQuery>; overload;
    function Initialize(const pQuery: string): IDriverQueryBuilder<TUniQuery>; overload;

    function Restore(): IDriverQueryBuilder<TUniQuery>;

    function Build(const pWhere: ISQLWhere): IDriverQueryBuilder<TUniQuery>; overload;
    function Build(const pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TUniQuery>; overload;
    function Build(const pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TUniQuery>; overload;
    function Build(const pHaving: ISQLHaving): IDriverQueryBuilder<TUniQuery>; overload;
    function Build(const pQuery: string): IDriverQueryBuilder<TUniQuery>; overload;

    procedure Activate;
  end;

function UniDACSingletonConnectionAdapter(): IUniDACSingletonConnectionAdapter;
begin
  Result := TUniDACSingletonConnectionAdapter.SingletonConnection;
end;

function CreateUniDACQueryBuilder(const pDataSet: TUniQuery): IDriverQueryBuilder<TUniQuery>;
begin
  Result := TUniDACQueryBuilder.Create(pDataSet);
end;

{ TUniDACStatementAdapter }

function TUniDACStatementAdapter.DoAsDataSet(const pQuery: string;
  const pFetchRows: Integer): TUniQuery;
begin
  Result := TUniQuery.Create(nil);
  Result.Connection := GetConnection.Component.Connection;
  if (pFetchRows > 0) then
  begin
    Result.SpecificOptions.Values['FetchAll'] := 'False';
    Result.FetchRows := pFetchRows;
  end;
  Result.SQL.Add(pQuery);
  Result.Prepare;
  Result.Open;
end;

function TUniDACStatementAdapter.DoAsFloat(const pQuery: string): Double;
var
  vIterator: IIteratorDataSet;
begin
  Result := 0;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsFloat;
end;

function TUniDACStatementAdapter.DoAsInteger(const pQuery: string): Integer;
var
  vIterator: IIteratorDataSet;
begin
  Result := 0;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsInteger;
end;

function TUniDACStatementAdapter.DoAsIterator(const pQuery: string;
  const pFetchRows: Integer): IIteratorDataSet;
begin
  Result := IteratorDataSetFactory.Build(DoAsDataSet(pQuery, pFetchRows), True);
end;

function TUniDACStatementAdapter.DoAsString(const pQuery: string): string;
var
  vIterator: IIteratorDataSet;
begin
  Result := EmptyStr;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsString;
end;

function TUniDACStatementAdapter.DoAsVariant(const pQuery: string): Variant;
var
  vIterator: IIteratorDataSet;
begin
  Result := varNull;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsVariant;
end;

procedure TUniDACStatementAdapter.DoExecute(const pQuery: string; const pDataSet: TUniQuery;
  const pAutoCommit: Boolean);
var
  vDataSet: TUniQuery;
  vOwnsDataSet: Boolean;
begin
  inherited;
  if (pDataSet = nil) then
  begin
    vDataSet := TUniQuery.Create(nil);
    vOwnsDataSet := True;
  end
  else
  begin
    vDataSet := pDataSet;
    vOwnsDataSet := False;
  end;
  try
    vDataSet.Close;
    vDataSet.SQL.Clear;
    vDataSet.Connection := GetConnection.Component.Connection;
    vDataSet.SQL.Add(pQuery);
    if pAutoCommit then
    begin
      try
        GetConnection.StartTransaction;
        vDataSet.Prepare;
        vDataSet.ExecSQL;
        GetConnection.Commit;
      except
        GetConnection.Rollback;
        raise;
      end;
    end
    else
    begin
      vDataSet.Prepare;
      vDataSet.ExecSQL;
    end;
  finally
    vDataSet.Close;
    vDataSet.Connection := nil;
    if vOwnsDataSet then
      FreeAndNil(vDataSet);
  end;
end;

procedure TUniDACStatementAdapter.DoInDataSet(const pQuery: string; const pDataSet: TUniQuery);
begin
  inherited;
  if (pDataSet = nil) then
    raise EDataSetDoesNotExist.Create('DataSet does not exist!');
  pDataSet.Close;
  pDataSet.Connection := GetConnection.Component.Connection;
  pDataSet.SQL.Add(pQuery);
  pDataSet.Prepare;
  pDataSet.Open;
end;

procedure TUniDACStatementAdapter.DoInIterator(const pQuery: string;
  const pIterator: IIteratorDataSet);
begin
  inherited;
  DoInDataSet(pQuery, TUniQuery(pIterator.GetDataSet));
end;

{ TUniDACConnectionAdapter }

procedure TUniDACConnectionAdapter.DoAfterBuild;
begin
  inherited;
  FDefaultAutoCommit := Component.Connection.AutoCommit;
end;

procedure TUniDACConnectionAdapter.DoCommit;
begin
  inherited;
  if (Component.Connection.ProviderName = cInterBaseProviderName) then
    Component.Connection.CommitRetaining()
  else
    Component.Connection.Commit();
  Component.Connection.AutoCommit := FDefaultAutoCommit;
end;

procedure TUniDACConnectionAdapter.DoConnect;
begin
  inherited;
  Component.Connection.Open();
end;

function TUniDACConnectionAdapter.DoCreateStatement: TUniDACStatementAdapter;
begin
  Result := TUniDACStatementAdapter.Create(Self);
end;

procedure TUniDACConnectionAdapter.DoDisconect;
begin
  inherited;
  Component.Connection.Close();
end;

function TUniDACConnectionAdapter.DoInTransaction: Boolean;
begin
  Result := Component.Connection.InTransaction;
end;

procedure TUniDACConnectionAdapter.DoRollback;
begin
  inherited;
  if (Component.Connection.ProviderName = cInterBaseProviderName) then
    Component.Connection.RollbackRetaining()
  else
    Component.Connection.Rollback;
  Component.Connection.AutoCommit := FDefaultAutoCommit;
end;

procedure TUniDACConnectionAdapter.DoStartTransaction;
begin
  inherited;
  Component.Connection.AutoCommit := False;
  if not InTransaction then
    Component.Connection.StartTransaction();
end;

{ TUniDACSingletonConnectionAdapter }

constructor TUniDACSingletonConnectionAdapter.Create;
begin
  FConnectionAdapter := TUniDACConnectionAdapter.Create;
end;

destructor TUniDACSingletonConnectionAdapter.Destroy;
begin
  FreeAndNil(FConnectionAdapter);
  inherited Destroy();
end;

function TUniDACSingletonConnectionAdapter.GetInstance: TUniDACConnectionAdapter;
begin
  Result := FConnectionAdapter;
end;

class constructor TUniDACSingletonConnectionAdapter.Create;
begin
  GlobalCriticalSection.Enter;
  try
    SingletonConnection := TUniDACSingletonConnectionAdapter.Create;
  finally
    GlobalCriticalSection.Leave;
  end;
end;

class destructor TUniDACSingletonConnectionAdapter.Destroy;
begin
  SingletonConnection := nil;
end;

{ TUniDACQueryBuilder }

procedure TUniDACQueryBuilder.Activate;
begin
  FDataSet.Open();
end;

function TUniDACQueryBuilder.Build(const pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TUniQuery>;
begin
  Restore();
  FQueryParserSelect.AddOrSetOrderBy(pOrderBy.ToString);
  FDataSet.SQL.Text := FQueryParserSelect.GetSQLText;
  Result := Self;
end;

function TUniDACQueryBuilder.Build(const pHaving: ISQLHaving): IDriverQueryBuilder<TUniQuery>;
begin
  Restore();
  FQueryParserSelect.AddOrSetHaving(pHaving.ToString);
  FDataSet.SQL.Text := FQueryParserSelect.GetSQLText;
  Result := Self;
end;

function TUniDACQueryBuilder.Build(const pQuery: string): IDriverQueryBuilder<TUniQuery>;
begin
  Result := Initialize(pQuery);
end;

function TUniDACQueryBuilder.Build(const pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TUniQuery>;
begin
  Restore();
  FQueryParserSelect.AddOrSetGroupBy(pGroupBy.ToString);
  FDataSet.SQL.Text := FQueryParserSelect.GetSQLText;
  Result := Self;
end;

function TUniDACQueryBuilder.Build(const pWhere: ISQLWhere): IDriverQueryBuilder<TUniQuery>;
begin
  Restore();
  FQueryParserSelect.AddOrSetWhere(pWhere.ToString);
  FDataSet.SQL.Text := FQueryParserSelect.GetSQLText;
  Result := Self;
end;

constructor TUniDACQueryBuilder.Create(const pDataSet: TUniQuery);
begin
  if (pDataSet = nil) then
    raise EDataSetDoesNotExist.Create('DataSet does not exist in Class ' + Self.ClassName);
  FDataSet := pDataSet;
  FQueryParserSelect := TSQLParserFactory.GetSelectInstance(prGaSQLParser);
  Initialize(pDataSet.SQL.Text);
end;

destructor TUniDACQueryBuilder.Destroy;
begin
  FQueryParserSelect := nil;
  inherited;
end;

function TUniDACQueryBuilder.Initialize(const pSelect: ISQLSelect): IDriverQueryBuilder<TUniQuery>;
begin
  Result := Initialize(pSelect.ToString);
end;

function TUniDACQueryBuilder.Initialize(const pHaving: ISQLHaving): IDriverQueryBuilder<TUniQuery>;
begin
  Result := Initialize(pHaving.ToString);
end;

function TUniDACQueryBuilder.Initialize(const pQuery: string): IDriverQueryBuilder<TUniQuery>;
begin
  FDataSet.Close;
  FQueryBegin := pQuery;
  FQueryParserSelect.Parse(FQueryBegin);
  FDataSet.SQL.Text := FQueryParserSelect.GetSQLText;
  Result := Self;
end;

function TUniDACQueryBuilder.Initialize(
  const pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TUniQuery>;
begin
  Result := Initialize(pOrderBy.ToString);
end;

function TUniDACQueryBuilder.Initialize(const pWhere: ISQLWhere): IDriverQueryBuilder<TUniQuery>;
begin
  Result := Initialize(pWhere.ToString);
end;

function TUniDACQueryBuilder.Initialize(
  const pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TUniQuery>;
begin
  Result := Initialize(pGroupBy.ToString);
end;

function TUniDACQueryBuilder.Restore: IDriverQueryBuilder<TUniQuery>;
begin
  FDataSet.Close;
  FQueryParserSelect.Parse(FQueryBegin);
  FDataSet.SQL.Text := FQueryParserSelect.GetSQLText;
  Result := Self;
end;

end.
