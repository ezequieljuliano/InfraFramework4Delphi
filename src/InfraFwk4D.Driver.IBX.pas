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
    procedure DoExecute(const pQuery: string; pDataSet: TIBDataSet; const pAutoCommit: Boolean; const pParams: TDictionary<string, Variant>); override;

    function DoAsDataSet(const pQuery: string; const pFetchRows: Integer; const pParams: TDictionary<string, Variant>): TIBDataSet; override;
    function DoAsIterator(const pQuery: string; const pFetchRows: Integer; const pParams: TDictionary<string, Variant>): IIteratorDataSet; override;
    function DoAsInteger(const pQuery: string; const pParams: TDictionary<string, Variant>): Integer; override;
    function DoAsFloat(const pQuery: string; const pParams: TDictionary<string, Variant>): Double; override;
    function DoAsString(const pQuery: string; const pParams: TDictionary<string, Variant>): string; override;
    function DoAsVariant(const pQuery: string; const pParams: TDictionary<string, Variant>): Variant; override;

    procedure DoInDataSet(const pQuery: string; pDataSet: TIBDataSet; const pParams: TDictionary<string, Variant>); override;
    procedure DoInIterator(const pQuery: string; pIterator: IIteratorDataSet; const pParams: TDictionary<string, Variant>); override;
    procedure DoAddParamByname(const pParam: string; const pValue: Variant); override;
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

  IBXAdapter = class sealed
  strict private
  const
    CanNotBeInstantiatedException = 'This class can not be instantiated!';
  strict private

    {$HINTS OFF}

    constructor Create;

    {$HINTS ON}

  public
    class function SingletonConnection(): IIBXSingletonConnectionAdapter; static;
    class function NewQueryBuilder(pDataSet: TIBDataSet): IDriverQueryBuilder<TIBDataSet>; static;
  end;

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

    function Initialize(pSelect: ISQLSelect): IDriverQueryBuilder<TIBDataSet>; overload;
    function Initialize(pWhere: ISQLWhere): IDriverQueryBuilder<TIBDataSet>; overload;
    function Initialize(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TIBDataSet>; overload;
    function Initialize(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TIBDataSet>; overload;
    function Initialize(pHaving: ISQLHaving): IDriverQueryBuilder<TIBDataSet>; overload;
    function Initialize(const pQuery: string): IDriverQueryBuilder<TIBDataSet>; overload;

    function Restore(): IDriverQueryBuilder<TIBDataSet>;

    function Build(pWhere: ISQLWhere): IDriverQueryBuilder<TIBDataSet>; overload;
    function Build(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TIBDataSet>; overload;
    function Build(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TIBDataSet>; overload;
    function Build(pHaving: ISQLHaving): IDriverQueryBuilder<TIBDataSet>; overload;
    function Build(const pQuery: string): IDriverQueryBuilder<TIBDataSet>; overload;

    function Add(pWhere: ISQLWhere): IDriverQueryBuilder<TIBDataSet>; overload;
    function Add(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TIBDataSet>; overload;
    function Add(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TIBDataSet>; overload;
    function Add(pHaving: ISQLHaving): IDriverQueryBuilder<TIBDataSet>; overload;
    function Add(const pQuery: string): IDriverQueryBuilder<TIBDataSet>; overload;

    function AddParamByName(const pParam: string; const pValue: Variant): IDriverQueryBuilder<TIBDataSet>;

    procedure Activate;
  end;

  { TIBXStatementAdapter }

procedure TIBXStatementAdapter.DoAddParamByname(const pParam: string; const pValue: Variant);
begin
  inherited;
end;

function TIBXStatementAdapter.DoAsDataSet(const pQuery: string;
  const pFetchRows: Integer; const pParams: TDictionary<string, Variant>): TIBDataSet;
begin
  Result := TIBDataSet.Create(nil);
  Result.Database := GetConnection.Component.Connection;
  Result.SelectSQL.Add(pQuery);
  Result.Prepare;
  Result.Open;
end;

function TIBXStatementAdapter.DoAsFloat(const pQuery: string; const pParams: TDictionary<string, Variant>): Double;
var
  vIterator: IIteratorDataSet;
begin
  Result := 0;
  vIterator := DoAsIterator(pQuery, 0, pParams);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsFloat;
end;

function TIBXStatementAdapter.DoAsInteger(const pQuery: string; const pParams: TDictionary<string, Variant>): Integer;
var
  vIterator: IIteratorDataSet;
begin
  Result := 0;
  vIterator := DoAsIterator(pQuery, 0, pParams);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsInteger;
end;

function TIBXStatementAdapter.DoAsIterator(const pQuery: string;
  const pFetchRows: Integer; const pParams: TDictionary<string, Variant>): IIteratorDataSet;
begin
  Result := IteratorDataSetFactory.Build(DoAsDataSet(pQuery, pFetchRows, pParams), True);
end;

function TIBXStatementAdapter.DoAsString(const pQuery: string; const pParams: TDictionary<string, Variant>): string;
var
  vIterator: IIteratorDataSet;
begin
  Result := EmptyStr;
  vIterator := DoAsIterator(pQuery, 0, pParams);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsString;
end;

function TIBXStatementAdapter.DoAsVariant(const pQuery: string; const pParams: TDictionary<string, Variant>): Variant;
var
  vIterator: IIteratorDataSet;
begin
  Result := varNull;
  vIterator := DoAsIterator(pQuery, 0, pParams);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsVariant;
end;

procedure TIBXStatementAdapter.DoExecute(const pQuery: string; pDataSet: TIBDataSet;
  const pAutoCommit: Boolean; const pParams: TDictionary<string, Variant>);
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

procedure TIBXStatementAdapter.DoInDataSet(const pQuery: string; pDataSet: TIBDataSet; const pParams: TDictionary<string, Variant>);
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
  pIterator: IIteratorDataSet; const pParams: TDictionary<string, Variant>);
begin
  inherited;
  DoInDataSet(pQuery, TIBDataSet(pIterator.GetDataSet), pParams);
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
  Critical.Section.Enter;
  try
    SingletonConnection := TIBXSingletonConnectionAdapter.Create;
  finally
    Critical.Section.Leave;
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

function TIBXQueryBuilder.Build(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TIBDataSet>;
begin
  Restore();
  FQueryParserSelect.AddOrderBy(pOrderBy.ToString);
  FDataSet.SelectSQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TIBXQueryBuilder.Build(pHaving: ISQLHaving): IDriverQueryBuilder<TIBDataSet>;
begin
  Restore();
  FQueryParserSelect.AddHaving(pHaving.ToString);
  FDataSet.SelectSQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TIBXQueryBuilder.Add(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TIBDataSet>;
begin
  Result := Build(pGroupBy);
end;

function TIBXQueryBuilder.Add(pWhere: ISQLWhere): IDriverQueryBuilder<TIBDataSet>;
begin
  Result := Build(pWhere);
end;

function TIBXQueryBuilder.Add(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TIBDataSet>;
begin
  Result := Build(pOrderBy);
end;

function TIBXQueryBuilder.Add(const pQuery: string): IDriverQueryBuilder<TIBDataSet>;
begin
  Result := Build(pQuery);
end;

function TIBXQueryBuilder.AddParamByName(const pParam: string; const pValue: Variant): IDriverQueryBuilder<TIBDataSet>;
begin
  FDataSet.Params.ByName(pParam).Value := pValue;
  Result := Self;
end;

function TIBXQueryBuilder.Add(pHaving: ISQLHaving): IDriverQueryBuilder<TIBDataSet>;
begin
  Result := Build(pHaving);
end;

function TIBXQueryBuilder.Build(const pQuery: string): IDriverQueryBuilder<TIBDataSet>;
begin
  Result := Initialize(pQuery);
end;

function TIBXQueryBuilder.Build(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TIBDataSet>;
begin
  Restore();
  FQueryParserSelect.AddGroupBy(pGroupBy.ToString);
  FDataSet.SelectSQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TIBXQueryBuilder.Build(pWhere: ISQLWhere): IDriverQueryBuilder<TIBDataSet>;
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

function TIBXQueryBuilder.Initialize(pSelect: ISQLSelect): IDriverQueryBuilder<TIBDataSet>;
begin
  Result := Initialize(pSelect.ToString);
end;

function TIBXQueryBuilder.Initialize(pHaving: ISQLHaving): IDriverQueryBuilder<TIBDataSet>;
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

function TIBXQueryBuilder.Initialize(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TIBDataSet>;
begin
  Result := Initialize(pOrderBy.ToString);
end;

function TIBXQueryBuilder.Initialize(pWhere: ISQLWhere): IDriverQueryBuilder<TIBDataSet>;
begin
  Result := Initialize(pWhere.ToString);
end;

function TIBXQueryBuilder.Initialize(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TIBDataSet>;
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

{ IBXAdapter }

constructor IBXAdapter.Create;
begin
  raise EInfraException.Create(CanNotBeInstantiatedException);
end;

class function IBXAdapter.NewQueryBuilder(pDataSet: TIBDataSet): IDriverQueryBuilder<TIBDataSet>;
begin
  Result := TIBXQueryBuilder.Create(pDataSet);
end;

class function IBXAdapter.SingletonConnection: IIBXSingletonConnectionAdapter;
begin
  Result := TIBXSingletonConnectionAdapter.SingletonConnection;
end;

end.
