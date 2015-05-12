unit InfraFwk4D.Driver.IBX;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.SyncObjs,
  Data.DB,
  IBX.IBDatabase,
  IBX.IBCustomDataSet,
  SQLBuilder4D,
  SQLBuilder4D.Parser,
  SQLBuilder4D.Parser.GaSQLParser,
  InfraFwk4D.Driver,
  InfraFwk4D.Iterator.DataSet;

type

  TIBXComponentAdapter = class(TDriverComponent<TIBDatabase>);

  TIBXConnectionAdapter = class;

  TIBXStatementAdapter = class(TDriverStatement<TIBDataSet, TIBXConnectionAdapter>)
  strict protected
    procedure DoExecute(const pQuery: string; const pDataSet: TIBDataSet; const pAutoCommit: Boolean); override;

    function DoAsDataSet(const pQuery: string; const pFetchRows: Integer): TIBDataSet; override;
    function DoAsIterator(const pQuery: string; const pFetchRows: Integer): IIteratorDataSet; override;
    function DoAsInteger(const pQuery: string): Integer; override;
    function DoAsFloat(const pQuery: string): Double; override;
    function DoAsString(const pQuery: string): string; override;
    function DoAsVariant(const pQuery: string): Variant; override;

    procedure DoInDataSet(const pQuery: string; const pDataSet: TIBDataSet); override;
    procedure DoInIterator(const pQuery: string; const pIterator: IIteratorDataSet); override;
  end;

  TIBXConnectionAdapter = class(TDriverConnection<TIBXComponentAdapter, TIBXStatementAdapter>)
  strict protected
    function DoCreateStatement(): TIBXStatementAdapter; override;

    procedure DoConnect(); override;
    procedure DoDisconect(); override;

    function DoInTransaction(): Boolean; override;
    procedure DoStartTransaction(); override;
    procedure DoCommit(); override;
    procedure DoRollback(); override;

    procedure DoAfterBuild(); override;
  end;

  TIBXConnectionManagerAdapter = class(TDriverConnectionManager<string, TIBXConnectionAdapter>);

  IIBXSingletonConnectionAdapter = interface(IDriverSingletonConnection<TIBXConnectionAdapter>)
    ['{1D4996C4-ADAD-489A-84FC-1D1279F5ED95}']
  end;

function IBXSingletonConnectionAdapter(): IIBXSingletonConnectionAdapter;
function CreateIBXQueryBuilder(const pDataSet: TIBDataSet): IDriverQueryBuilder<TIBDataSet>;

implementation

uses
  InfraFwk4D;

type

  TIBXSingletonConnectionAdapter = class(TInterfacedObject, IIBXSingletonConnectionAdapter)
  private
    class var SingletonConnection: IIBXSingletonConnectionAdapter;
    class constructor Create;
    class destructor Destroy;
  private
    FConnectionAdapter: TIBXConnectionAdapter;

    function GetInstance(): TIBXConnectionAdapter;
  public
    constructor Create;
    destructor Destroy; override;

    property Instance: TIBXConnectionAdapter read GetInstance;
  end;

  TIBXQueryBuilder = class(TInterfacedObject, IDriverQueryBuilder<TIBDataSet>)
  private
    FDataSet: TIBDataSet;
    FQueryBegin: string;
    FQueryParserSelect: ISQLParserSelect;
  public
    constructor Create(const pDataSet: TIBDataSet);
    destructor Destroy; override;

    function Initialize(const pSelect: ISQLSelect): IDriverQueryBuilder<TIBDataSet>; overload;
    function Initialize(const pWhere: ISQLWhere): IDriverQueryBuilder<TIBDataSet>; overload;
    function Initialize(const pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TIBDataSet>; overload;
    function Initialize(const pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TIBDataSet>; overload;
    function Initialize(const pHaving: ISQLHaving): IDriverQueryBuilder<TIBDataSet>; overload;
    function Initialize(const pQuery: string): IDriverQueryBuilder<TIBDataSet>; overload;

    function Restore(): IDriverQueryBuilder<TIBDataSet>;

    function Build(const pWhere: ISQLWhere): IDriverQueryBuilder<TIBDataSet>; overload;
    function Build(const pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TIBDataSet>; overload;
    function Build(const pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TIBDataSet>; overload;
    function Build(const pHaving: ISQLHaving): IDriverQueryBuilder<TIBDataSet>; overload;
    function Build(const pQuery: string): IDriverQueryBuilder<TIBDataSet>; overload;

    procedure Activate;
  end;

function IBXSingletonConnectionAdapter(): IIBXSingletonConnectionAdapter;
begin
  Result := TIBXSingletonConnectionAdapter.SingletonConnection;
end;

function CreateIBXQueryBuilder(const pDataSet: TIBDataSet): IDriverQueryBuilder<TIBDataSet>;
begin
  Result := TIBXQueryBuilder.Create(pDataSet);
end;

{ TIBXStatementAdapter }

function TIBXStatementAdapter.DoAsDataSet(const pQuery: string;
  const pFetchRows: Integer): TIBDataSet;
begin
  Result := TIBDataSet.Create(nil);
  Result.Database := GetConnection.Component.Connection;
  Result.SelectSQL.Add(pQuery);
  Result.Prepare;
  Result.Open;
end;

function TIBXStatementAdapter.DoAsFloat(const pQuery: string): Double;
var
  vIterator: IIteratorDataSet;
begin
  Result := 0;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsFloat;
end;

function TIBXStatementAdapter.DoAsInteger(const pQuery: string): Integer;
var
  vIterator: IIteratorDataSet;
begin
  Result := 0;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsInteger;
end;

function TIBXStatementAdapter.DoAsIterator(const pQuery: string;
  const pFetchRows: Integer): IIteratorDataSet;
begin
  Result := IteratorDataSetFactory.Build(DoAsDataSet(pQuery, pFetchRows), True);
end;

function TIBXStatementAdapter.DoAsString(const pQuery: string): string;
var
  vIterator: IIteratorDataSet;
begin
  Result := EmptyStr;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsString;
end;

function TIBXStatementAdapter.DoAsVariant(const pQuery: string): Variant;
var
  vIterator: IIteratorDataSet;
begin
  Result := varNull;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsVariant;
end;

procedure TIBXStatementAdapter.DoExecute(const pQuery: string; const pDataSet: TIBDataSet;
  const pAutoCommit: Boolean);
var
  vDataSet: TIBDataSet;
  vOwnsDataSet: Boolean;
begin
  inherited;
  if (pDataSet = nil) then
  begin
    vDataSet := TIBDataSet.Create(nil);
    vOwnsDataSet := True;
  end
  else
  begin
    vDataSet := pDataSet;
    vOwnsDataSet := False;
  end;
  try
    vDataSet.Close;
    vDataSet.SelectSQL.Clear;
    vDataSet.Database := GetConnection.Component.Connection;
    vDataSet.SelectSQL.Add(pQuery);
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
    vDataSet.Database := nil;
    if vOwnsDataSet then
      FreeAndNil(vDataSet);
  end;
end;

procedure TIBXStatementAdapter.DoInDataSet(const pQuery: string; const pDataSet: TIBDataSet);
begin
  inherited;
  if (pDataSet = nil) then
    raise EDataSetDoesNotExist.Create('DataSet does not exist!');
  pDataSet.Close;
  pDataSet.Database := GetConnection.Component.Connection;
  pDataSet.SelectSQL.Add(pQuery);
  pDataSet.Prepare;
  pDataSet.Open;
end;

procedure TIBXStatementAdapter.DoInIterator(const pQuery: string;
  const pIterator: IIteratorDataSet);
begin
  inherited;
  DoInDataSet(pQuery, TIBDataSet(pIterator.GetDataSet));
end;

{ TIBXConnectionAdapter }

procedure TIBXConnectionAdapter.DoAfterBuild;
begin
  inherited;

end;

procedure TIBXConnectionAdapter.DoCommit;
begin
  inherited;
  Component.Connection.DefaultTransaction.Commit();
end;

procedure TIBXConnectionAdapter.DoConnect;
begin
  inherited;
  Component.Connection.Open();
end;

function TIBXConnectionAdapter.DoCreateStatement: TIBXStatementAdapter;
begin
  Result := TIBXStatementAdapter.Create(Self);
end;

procedure TIBXConnectionAdapter.DoDisconect;
begin
  inherited;
  Component.Connection.Close();
end;

function TIBXConnectionAdapter.DoInTransaction: Boolean;
begin
  Result := (Component.Connection.TransactionCount > 0);
end;

procedure TIBXConnectionAdapter.DoRollback;
begin
  inherited;
  Component.Connection.DefaultTransaction.RollbackRetaining;
end;

procedure TIBXConnectionAdapter.DoStartTransaction;
begin
  inherited;
  Component.Connection.DefaultTransaction.StartTransaction;
end;

{ TIBXSingletonConnectionAdapter }

class constructor TIBXSingletonConnectionAdapter.Create;
begin
  GlobalCriticalSection.Enter;
  try
    SingletonConnection := TIBXSingletonConnectionAdapter.Create;
  finally
    GlobalCriticalSection.Leave;
  end;
end;

class destructor TIBXSingletonConnectionAdapter.Destroy;
begin
  SingletonConnection := nil;
end;

constructor TIBXSingletonConnectionAdapter.Create;
begin
  FConnectionAdapter := TIBXConnectionAdapter.Create;
end;

destructor TIBXSingletonConnectionAdapter.Destroy;
begin
  FreeAndNil(FConnectionAdapter);
  inherited Destroy();
end;

function TIBXSingletonConnectionAdapter.GetInstance: TIBXConnectionAdapter;
begin
  Result := FConnectionAdapter;
end;

{ TIBXQueryBuilder }

procedure TIBXQueryBuilder.Activate;
begin
  FDataSet.Open();
end;

function TIBXQueryBuilder.Build(const pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TIBDataSet>;
begin
  Restore();
  FQueryParserSelect.AddOrderBy(pOrderBy.ToString);
  FDataSet.SelectSQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TIBXQueryBuilder.Build(const pHaving: ISQLHaving): IDriverQueryBuilder<TIBDataSet>;
begin
  Restore();
  FQueryParserSelect.AddHaving(pHaving.ToString);
  FDataSet.SelectSQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TIBXQueryBuilder.Build(const pQuery: string): IDriverQueryBuilder<TIBDataSet>;
begin
  Result := Initialize(pQuery);
end;

function TIBXQueryBuilder.Build(const pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TIBDataSet>;
begin
  Restore();
  FQueryParserSelect.AddGroupBy(pGroupBy.ToString);
  FDataSet.SelectSQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TIBXQueryBuilder.Build(const pWhere: ISQLWhere): IDriverQueryBuilder<TIBDataSet>;
begin
  Restore();
  FQueryParserSelect.AddWhere(pWhere.ToString);
  FDataSet.SelectSQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

constructor TIBXQueryBuilder.Create(const pDataSet: TIBDataSet);
begin
  if (pDataSet = nil) then
    raise EDataSetDoesNotExist.Create('DataSet does not exist in Class ' + Self.ClassName);
  FDataSet := pDataSet;
  FQueryParserSelect := TGaSQLParserFactory.Select();
  Initialize(pDataSet.SelectSQL.Text);
end;

destructor TIBXQueryBuilder.Destroy;
begin
  FQueryParserSelect := nil;
  inherited;
end;

function TIBXQueryBuilder.Initialize(const pSelect: ISQLSelect): IDriverQueryBuilder<TIBDataSet>;
begin
  Result := Initialize(pSelect.ToString);
end;

function TIBXQueryBuilder.Initialize(const pHaving: ISQLHaving): IDriverQueryBuilder<TIBDataSet>;
begin
  Result := Initialize(pHaving.ToString);
end;

function TIBXQueryBuilder.Initialize(const pQuery: string): IDriverQueryBuilder<TIBDataSet>;
begin
  FDataSet.Close;
  FQueryBegin := pQuery;
  FQueryParserSelect.Parse(FQueryBegin);
  FDataSet.SelectSQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TIBXQueryBuilder.Initialize(const pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TIBDataSet>;
begin
  Result := Initialize(pOrderBy.ToString);
end;

function TIBXQueryBuilder.Initialize(const pWhere: ISQLWhere): IDriverQueryBuilder<TIBDataSet>;
begin
  Result := Initialize(pWhere.ToString);
end;

function TIBXQueryBuilder.Initialize(const pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TIBDataSet>;
begin
  Result := Initialize(pGroupBy.ToString);
end;

function TIBXQueryBuilder.Restore: IDriverQueryBuilder<TIBDataSet>;
begin
  FDataSet.Close;
  FQueryParserSelect.Parse(FQueryBegin);
  FDataSet.SelectSQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

end.
