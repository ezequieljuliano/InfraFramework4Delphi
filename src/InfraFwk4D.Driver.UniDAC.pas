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
  SQLBuilder4D.Parser.GaSQLParser,
  InfraFwk4D.Driver,
  InfraFwk4D.Iterator.DataSet;

type

  TUniDACComponentAdapter = class(TDriverComponent<TUniConnection>);

  TUniDACConnectionAdapter = class;

  TUniDACStatementAdapter = class(TDriverStatement<TUniQuery, TUniDACConnectionAdapter>)
  strict protected
    procedure DoExecute(const pQuery: string; pDataSet: TUniQuery; const pAutoCommit: Boolean; const pParams: TDictionary<string, Variant>); override;

    function DoAsDataSet(const pQuery: string; const pFetchRows: Integer; const pParams: TDictionary<string, Variant>): TUniQuery; override;
    function DoAsIterator(const pQuery: string; const pFetchRows: Integer; const pParams: TDictionary<string, Variant>): IIteratorDataSet; override;
    function DoAsInteger(const pQuery: string; const pParams: TDictionary<string, Variant>): Integer; override;
    function DoAsFloat(const pQuery: string; const pParams: TDictionary<string, Variant>): Double; override;
    function DoAsString(const pQuery: string; const pParams: TDictionary<string, Variant>): string; override;
    function DoAsVariant(const pQuery: string; const pParams: TDictionary<string, Variant>): Variant; override;

    procedure DoInDataSet(const pQuery: string; pDataSet: TUniQuery; const pParams: TDictionary<string, Variant>); override;
    procedure DoInIterator(const pQuery: string; pIterator: IIteratorDataSet; const pParams: TDictionary<string, Variant>); override;
    procedure DoAddParamByname(const pParam: string; const pValue: Variant); override;
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

  IUniDACSingletonConnectionAdapter = interface(IDriverSingletonConnection<TUniDACConnectionAdapter>)
    ['{1D4996C4-ADAD-489A-84FC-1D1279F5ED95}']
  end;

  UniDACAdapter = class sealed
  strict private
  const
    CanNotBeInstantiatedException = 'This class can not be instantiated!';
  strict private

    {$HINTS OFF}

    constructor Create;

    {$HINTS ON}

  public
    class function SingletonConnection(): IUniDACSingletonConnectionAdapter; static;
    class function NewQueryBuilder(pDataSet: TUniQuery): IDriverQueryBuilder<TUniQuery>; static;
  end;

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

    function Initialize(pSelect: ISQLSelect): IDriverQueryBuilder<TUniQuery>; overload;
    function Initialize(pWhere: ISQLWhere): IDriverQueryBuilder<TUniQuery>; overload;
    function Initialize(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TUniQuery>; overload;
    function Initialize(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TUniQuery>; overload;
    function Initialize(pHaving: ISQLHaving): IDriverQueryBuilder<TUniQuery>; overload;
    function Initialize(const pQuery: string): IDriverQueryBuilder<TUniQuery>; overload;

    function Restore(): IDriverQueryBuilder<TUniQuery>;

    function Build(pWhere: ISQLWhere): IDriverQueryBuilder<TUniQuery>; overload;
    function Build(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TUniQuery>; overload;
    function Build(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TUniQuery>; overload;
    function Build(pHaving: ISQLHaving): IDriverQueryBuilder<TUniQuery>; overload;
    function Build(const pQuery: string): IDriverQueryBuilder<TUniQuery>; overload;

    function Add(pWhere: ISQLWhere): IDriverQueryBuilder<TUniQuery>; overload;
    function Add(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TUniQuery>; overload;
    function Add(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TUniQuery>; overload;
    function Add(pHaving: ISQLHaving): IDriverQueryBuilder<TUniQuery>; overload;
    function Add(const pQuery: string): IDriverQueryBuilder<TUniQuery>; overload;

    function AddParamByName(const pParam: string; const pValue: Variant): IDriverQueryBuilder<TUniQuery>;

    procedure Activate;
  end;

  { TUniDACStatementAdapter }

procedure TUniDACStatementAdapter.DoAddParamByname(const pParam: string; const pValue: Variant);
begin
  inherited;
end;

function TUniDACStatementAdapter.DoAsDataSet(const pQuery: string;
  const pFetchRows: Integer; const pParams: TDictionary<string, Variant>): TUniQuery;
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

function TUniDACStatementAdapter.DoAsFloat(const pQuery: string; const pParams: TDictionary<string, Variant>): Double;
var
  vIterator: IIteratorDataSet;
begin
  Result := 0;
  vIterator := DoAsIterator(pQuery, 0, pParams);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsFloat;
end;

function TUniDACStatementAdapter.DoAsInteger(const pQuery: string; const pParams: TDictionary<string, Variant>): Integer;
var
  vIterator: IIteratorDataSet;
begin
  Result := 0;
  vIterator := DoAsIterator(pQuery, 0, pParams);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsInteger;
end;

function TUniDACStatementAdapter.DoAsIterator(const pQuery: string;
  const pFetchRows: Integer; const pParams: TDictionary<string, Variant>): IIteratorDataSet;
begin
  Result := IteratorDataSetFactory.Build(DoAsDataSet(pQuery, pFetchRows, pParams), True);
end;

function TUniDACStatementAdapter.DoAsString(const pQuery: string; const pParams: TDictionary<string, Variant>): string;
var
  vIterator: IIteratorDataSet;
begin
  Result := EmptyStr;
  vIterator := DoAsIterator(pQuery, 0, pParams);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsString;
end;

function TUniDACStatementAdapter.DoAsVariant(const pQuery: string; const pParams: TDictionary<string, Variant>): Variant;
var
  vIterator: IIteratorDataSet;
begin
  Result := varNull;
  vIterator := DoAsIterator(pQuery, 0, pParams);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsVariant;
end;

procedure TUniDACStatementAdapter.DoExecute(const pQuery: string; pDataSet: TUniQuery;
  const pAutoCommit: Boolean; const pParams: TDictionary<string, Variant>);
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

procedure TUniDACStatementAdapter.DoInDataSet(const pQuery: string; pDataSet: TUniQuery; const pParams: TDictionary<string, Variant>);
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
  pIterator: IIteratorDataSet; const pParams: TDictionary<string, Variant>);
begin
  inherited;
  DoInDataSet(pQuery, TUniQuery(pIterator.GetDataSet), pParams);
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
  Critical.Section.Enter;
  try
    SingletonConnection := TUniDACSingletonConnectionAdapter.Create;
  finally
    Critical.Section.Leave;
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

function TUniDACQueryBuilder.Build(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TUniQuery>;
begin
  Restore();
  FQueryParserSelect.AddOrderBy(pOrderBy.ToString);
  FDataSet.SQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TUniDACQueryBuilder.Build(pHaving: ISQLHaving): IDriverQueryBuilder<TUniQuery>;
begin
  Restore();
  FQueryParserSelect.AddHaving(pHaving.ToString);
  FDataSet.SQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TUniDACQueryBuilder.Add(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TUniQuery>;
begin
  Result := Build(pGroupBy);
end;

function TUniDACQueryBuilder.Add(pWhere: ISQLWhere): IDriverQueryBuilder<TUniQuery>;
begin
  Result := Build(pWhere);
end;

function TUniDACQueryBuilder.Add(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TUniQuery>;
begin
  Result := Build(pOrderBy);
end;

function TUniDACQueryBuilder.Add(const pQuery: string): IDriverQueryBuilder<TUniQuery>;
begin
  Result := Build(pQuery);
end;

function TUniDACQueryBuilder.AddParamByName(const pParam: string; const pValue: Variant): IDriverQueryBuilder<TUniQuery>;
begin
  Result := nil;
end;

function TUniDACQueryBuilder.Add(pHaving: ISQLHaving): IDriverQueryBuilder<TUniQuery>;
begin
  Result := Build(pHaving);
end;

function TUniDACQueryBuilder.Build(const pQuery: string): IDriverQueryBuilder<TUniQuery>;
begin
  Result := Initialize(pQuery);
end;

function TUniDACQueryBuilder.Build(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TUniQuery>;
begin
  Restore();
  FQueryParserSelect.AddGroupBy(pGroupBy.ToString);
  FDataSet.SQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TUniDACQueryBuilder.Build(pWhere: ISQLWhere): IDriverQueryBuilder<TUniQuery>;
begin
  Restore();
  FQueryParserSelect.AddWhere(pWhere.ToString);
  FDataSet.SQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

constructor TUniDACQueryBuilder.Create(const pDataSet: TUniQuery);
begin
  if (pDataSet = nil) then
    raise EDataSetDoesNotExist.Create('DataSet does not exist in Class ' + Self.ClassName);
  FDataSet := pDataSet;
  FQueryParserSelect := TGaSQLParserFactory.Select();
  Initialize(pDataSet.SQL.Text);
end;

destructor TUniDACQueryBuilder.Destroy;
begin
  FQueryParserSelect := nil;
  inherited;
end;

function TUniDACQueryBuilder.Initialize(pSelect: ISQLSelect): IDriverQueryBuilder<TUniQuery>;
begin
  Result := Initialize(pSelect.ToString);
end;

function TUniDACQueryBuilder.Initialize(pHaving: ISQLHaving): IDriverQueryBuilder<TUniQuery>;
begin
  Result := Initialize(pHaving.ToString);
end;

function TUniDACQueryBuilder.Initialize(const pQuery: string): IDriverQueryBuilder<TUniQuery>;
begin
  FDataSet.Close;
  FQueryBegin := pQuery;
  FQueryParserSelect.Parse(FQueryBegin);
  FDataSet.SQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TUniDACQueryBuilder.Initialize(
  pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TUniQuery>;
begin
  Result := Initialize(pOrderBy.ToString);
end;

function TUniDACQueryBuilder.Initialize(pWhere: ISQLWhere): IDriverQueryBuilder<TUniQuery>;
begin
  Result := Initialize(pWhere.ToString);
end;

function TUniDACQueryBuilder.Initialize(
  pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TUniQuery>;
begin
  Result := Initialize(pGroupBy.ToString);
end;

function TUniDACQueryBuilder.Restore: IDriverQueryBuilder<TUniQuery>;
begin
  FDataSet.Close;
  FQueryParserSelect.Parse(FQueryBegin);
  FDataSet.SQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

{ UniDACAdapter }

constructor UniDACAdapter.Create;
begin
  raise EInfraException.Create(CanNotBeInstantiatedException);
end;

class function UniDACAdapter.NewQueryBuilder(pDataSet: TUniQuery): IDriverQueryBuilder<TUniQuery>;
begin
  Result := TUniDACQueryBuilder.Create(pDataSet);
end;

class function UniDACAdapter.SingletonConnection: IUniDACSingletonConnectionAdapter;
begin
  Result := TUniDACSingletonConnectionAdapter.SingletonConnection;
end;

end.
