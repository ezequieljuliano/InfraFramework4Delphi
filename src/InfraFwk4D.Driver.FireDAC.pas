unit InfraFwk4D.Driver.FireDAC;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.SyncObjs,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Option,
  SQLBuilder4D,
  SQLBuilder4D.Parser,
  SQLBuilder4D.Parser.GaSQLParser,
  InfraFwk4D.Driver,
  InfraFwk4D.Iterator.DataSet;

type

  TFireDACComponentAdapter = class(TDriverComponent<TFDConnection>);

  TFireDACConnectionAdapter = class;

  TFireDACStatementAdapter = class(TDriverStatement<TFDQuery, TFireDACConnectionAdapter>)
  strict protected
    procedure DoExecute(const pQuery: string; pDataSet: TFDQuery; const pAutoCommit: Boolean); override;

    function DoAsDataSet(const pQuery: string; const pFetchRows: Integer): TFDQuery; override;
    function DoAsIterator(const pQuery: string; const pFetchRows: Integer): IIteratorDataSet; override;
    function DoAsInteger(const pQuery: string): Integer; override;
    function DoAsFloat(const pQuery: string): Double; override;
    function DoAsString(const pQuery: string): string; override;
    function DoAsVariant(const pQuery: string): Variant; override;

    procedure DoInDataSet(const pQuery: string; pDataSet: TFDQuery); override;
    procedure DoInIterator(const pQuery: string; pIterator: IIteratorDataSet); override;
  end;

  TFireDACConnectionAdapter = class(TDriverConnection<TFireDACComponentAdapter, TFireDACStatementAdapter>)
  strict protected
    function DoCreateStatement(): TFireDACStatementAdapter; override;

    procedure DoConnect(); override;
    procedure DoDisconect(); override;

    function DoInTransaction(): Boolean; override;
    procedure DoStartTransaction(); override;
    procedure DoCommit(); override;
    procedure DoRollback(); override;

    procedure DoAfterBuild(); override;
  end;

  TFireDACConnectionManagerAdapter = class(TDriverConnectionManager<string, TFireDACConnectionAdapter>);

  IFireDACSingletonConnectionAdapter = interface(IDriverSingletonConnection<TFireDACConnectionAdapter>)
    ['{1D4996C4-ADAD-489A-84FC-1D1279F5ED95}']
  end;

  FireDACAdapter = class sealed
  strict private
  const
    CanNotBeInstantiatedException = 'This class can not be instantiated!';
  strict private

    {$HINTS OFF}

    constructor Create;

    {$HINTS ON}

  public
    class function SingletonConnection(): IFireDACSingletonConnectionAdapter; static;
    class function NewQueryBuilder(pDataSet: TFDQuery): IDriverQueryBuilder<TFDQuery>; static;
  end;

implementation

uses
  InfraFwk4D;

type

  TFireDACSingletonConnectionAdapter = class(TInterfacedObject, IFireDACSingletonConnectionAdapter)
  private
    class var SingletonConnection: IFireDACSingletonConnectionAdapter;
    class constructor Create;
    class destructor Destroy;
  private
    FConnectionAdapter: TFireDACConnectionAdapter;
    function GetInstance(): TFireDACConnectionAdapter;
  public
    constructor Create;
    destructor Destroy; override;

    property Instance: TFireDACConnectionAdapter read GetInstance;
  end;

  TFireDACQueryBuilder = class(TInterfacedObject, IDriverQueryBuilder<TFDQuery>)
  private
    FDataSet: TFDQuery;
    FQueryBegin: string;
    FQueryParserSelect: ISQLParserSelect;
  public
    constructor Create(pDataSet: TFDQuery);
    destructor Destroy; override;

    function Initialize(pSelect: ISQLSelect): IDriverQueryBuilder<TFDQuery>; overload;
    function Initialize(pWhere: ISQLWhere): IDriverQueryBuilder<TFDQuery>; overload;
    function Initialize(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TFDQuery>; overload;
    function Initialize(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TFDQuery>; overload;
    function Initialize(pHaving: ISQLHaving): IDriverQueryBuilder<TFDQuery>; overload;
    function Initialize(const pQuery: string): IDriverQueryBuilder<TFDQuery>; overload;

    function Restore(): IDriverQueryBuilder<TFDQuery>;

    function Build(pWhere: ISQLWhere): IDriverQueryBuilder<TFDQuery>; overload;
    function Build(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TFDQuery>; overload;
    function Build(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TFDQuery>; overload;
    function Build(pHaving: ISQLHaving): IDriverQueryBuilder<TFDQuery>; overload;
    function Build(const pQuery: string): IDriverQueryBuilder<TFDQuery>; overload;

    procedure Activate;
  end;

  { TFireDACStatementAdapter }

function TFireDACStatementAdapter.DoAsDataSet(const pQuery: string;
  const pFetchRows: Integer): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := GetConnection.Component.Connection;
  if (pFetchRows > 0) then
  begin
    Result.FetchOptions.Mode := fmOnDemand;
    Result.FetchOptions.RowsetSize := pFetchRows;
  end
  else
  begin
    Result.FetchOptions.Mode := fmAll;
    Result.FetchOptions.RowsetSize := -1;
  end;
  Result.SQL.Add(pQuery);
  Result.Prepare;
  Result.Open;
end;

function TFireDACStatementAdapter.DoAsFloat(const pQuery: string): Double;
var
  vIterator: IIteratorDataSet;
begin
  Result := 0;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsFloat;
end;

function TFireDACStatementAdapter.DoAsInteger(const pQuery: string): Integer;
var
  vIterator: IIteratorDataSet;
begin
  Result := 0;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsInteger;
end;

function TFireDACStatementAdapter.DoAsIterator(const pQuery: string;
  const pFetchRows: Integer): IIteratorDataSet;
begin
  Result := IteratorDataSetFactory.Build(DoAsDataSet(pQuery, pFetchRows), True);
end;

function TFireDACStatementAdapter.DoAsString(const pQuery: string): string;
var
  vIterator: IIteratorDataSet;
begin
  Result := EmptyStr;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsString;
end;

function TFireDACStatementAdapter.DoAsVariant(const pQuery: string): Variant;
var
  vIterator: IIteratorDataSet;
begin
  Result := varNull;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsVariant;
end;

procedure TFireDACStatementAdapter.DoExecute(const pQuery: string; pDataSet: TFDQuery;
  const pAutoCommit: Boolean);
var
  vDataSet: TFDQuery;
  vOwnsDataSet: Boolean;
begin
  inherited;
  if (pDataSet = nil) then
  begin
    vDataSet := TFDQuery.Create(nil);
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

procedure TFireDACStatementAdapter.DoInDataSet(const pQuery: string; pDataSet: TFDQuery);
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

procedure TFireDACStatementAdapter.DoInIterator(const pQuery: string;
  pIterator: IIteratorDataSet);
begin
  inherited;
  DoInDataSet(pQuery, TFDQuery(pIterator.GetDataSet));
end;

{ TFireDACConnectionAdapter }

procedure TFireDACConnectionAdapter.DoAfterBuild;
begin
  inherited;

end;

procedure TFireDACConnectionAdapter.DoCommit;
begin
  inherited;
  Component.Connection.Commit();
end;

procedure TFireDACConnectionAdapter.DoConnect;
begin
  inherited;
  Component.Connection.Open();
end;

function TFireDACConnectionAdapter.DoCreateStatement: TFireDACStatementAdapter;
begin
  Result := TFireDACStatementAdapter.Create(Self);
end;

procedure TFireDACConnectionAdapter.DoDisconect;
begin
  inherited;
  Component.Connection.Close();
end;

function TFireDACConnectionAdapter.DoInTransaction: Boolean;
begin
  Result := Component.Connection.InTransaction;
end;

procedure TFireDACConnectionAdapter.DoRollback;
begin
  inherited;
  Component.Connection.Rollback();
end;

procedure TFireDACConnectionAdapter.DoStartTransaction;
begin
  inherited;
  Component.Connection.StartTransaction();
end;

{ TFireDACSingletonConnectionAdapter }

constructor TFireDACSingletonConnectionAdapter.Create;
begin
  FConnectionAdapter := TFireDACConnectionAdapter.Create;
end;

destructor TFireDACSingletonConnectionAdapter.Destroy;
begin
  FreeAndNil(FConnectionAdapter);
  inherited Destroy();
end;

function TFireDACSingletonConnectionAdapter.GetInstance: TFireDACConnectionAdapter;
begin
  Result := FConnectionAdapter;
end;

class constructor TFireDACSingletonConnectionAdapter.Create;
begin
  Critical.Section.Enter;
  try
    SingletonConnection := TFireDACSingletonConnectionAdapter.Create;
  finally
    Critical.Section.Leave;
  end;
end;

class destructor TFireDACSingletonConnectionAdapter.Destroy;
begin
  SingletonConnection := nil;
end;

{ TFireDACQueryBuilder }

procedure TFireDACQueryBuilder.Activate;
begin
  FDataSet.Open();
end;

function TFireDACQueryBuilder.Build(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TFDQuery>;
begin
  Restore();
  FQueryParserSelect.AddOrderBy(pOrderBy.ToString);
  FDataSet.SQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TFireDACQueryBuilder.Build(pHaving: ISQLHaving): IDriverQueryBuilder<TFDQuery>;
begin
  Restore();
  FQueryParserSelect.AddHaving(pHaving.ToString);
  FDataSet.SQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TFireDACQueryBuilder.Build(const pQuery: string): IDriverQueryBuilder<TFDQuery>;
begin
  Result := Initialize(pQuery);
end;

constructor TFireDACQueryBuilder.Create(pDataSet: TFDQuery);
begin
  if (pDataSet = nil) then
    raise EDataSetDoesNotExist.Create('DataSet does not exist in Class ' + Self.ClassName);
  FDataSet := pDataSet;
  FQueryParserSelect := TGaSQLParserFactory.Select();
  Initialize(pDataSet.SQL.Text);
end;

destructor TFireDACQueryBuilder.Destroy;
begin
  FQueryParserSelect := nil;
  inherited;
end;

function TFireDACQueryBuilder.Build(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TFDQuery>;
begin
  Restore();
  FQueryParserSelect.AddGroupBy(pGroupBy.ToString);
  FDataSet.SQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TFireDACQueryBuilder.Build(pWhere: ISQLWhere): IDriverQueryBuilder<TFDQuery>;
begin
  Restore();
  FQueryParserSelect.AddWhere(pWhere.ToString);
  FDataSet.SQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TFireDACQueryBuilder.Initialize(
  pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TFDQuery>;
begin
  Result := Initialize(pOrderBy.ToString);
end;

function TFireDACQueryBuilder.Initialize(pHaving: ISQLHaving): IDriverQueryBuilder<TFDQuery>;
begin
  Result := Initialize(pHaving.ToString);
end;

function TFireDACQueryBuilder.Initialize(const pQuery: string): IDriverQueryBuilder<TFDQuery>;
begin
  FDataSet.Close;
  FQueryBegin := pQuery;
  FQueryParserSelect.Parse(FQueryBegin);
  FDataSet.SQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TFireDACQueryBuilder.Initialize(pSelect: ISQLSelect): IDriverQueryBuilder<TFDQuery>;
begin
  Result := Initialize(pSelect.ToString);
end;

function TFireDACQueryBuilder.Initialize(pWhere: ISQLWhere): IDriverQueryBuilder<TFDQuery>;
begin
  Result := Initialize(pWhere.ToString);
end;

function TFireDACQueryBuilder.Initialize(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TFDQuery>;
begin
  Result := Initialize(pGroupBy.ToString);
end;

function TFireDACQueryBuilder.Restore: IDriverQueryBuilder<TFDQuery>;
begin
  FDataSet.Close;
  FQueryParserSelect.Parse(FQueryBegin);
  FDataSet.SQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

{ FireDACAdapter }

constructor FireDACAdapter.Create;
begin
  raise EInfraException.Create(CanNotBeInstantiatedException);
end;

class function FireDACAdapter.NewQueryBuilder(pDataSet: TFDQuery): IDriverQueryBuilder<TFDQuery>;
begin
  Result := TFireDACQueryBuilder.Create(pDataSet);
end;

class function FireDACAdapter.SingletonConnection: IFireDACSingletonConnectionAdapter;
begin
  Result := TFireDACSingletonConnectionAdapter.SingletonConnection;
end;

end.
