unit InfraFwk4D.Driver.ADO;

interface

uses
  Classes,
  SysUtils,
  Generics.Collections,
  SyncObjs,
  DB,

  {$IFDEF VER210}

  ADODB,

  {$ELSE}

  Data.Win.ADODB,

  {$ENDIF}

  SQLBuilder4D,
  SQLBuilder4D.Parser,
  SQLBuilder4D.Parser.GaSQLParser,
  InfraFwk4D.Driver,
  InfraFwk4D.Iterator.DataSet;

type

  TADOComponentAdapter = class(TDriverComponent<TADOConnection>);

  TADOConnectionAdapter = class;

  TADOStatementAdapter = class(TDriverStatement<TADOQuery, TADOConnectionAdapter>)
  strict protected
    procedure DoExecute(const pQuery: string; pDataSet: TADOQuery; const pAutoCommit: Boolean); override;

    function DoAsDataSet(const pQuery: string; const pFetchRows: Integer): TADOQuery; override;
    function DoAsIterator(const pQuery: string; const pFetchRows: Integer): IIteratorDataSet; override;
    function DoAsInteger(const pQuery: string): Integer; override;
    function DoAsFloat(const pQuery: string): Double; override;
    function DoAsString(const pQuery: string): string; override;
    function DoAsVariant(const pQuery: string): Variant; override;

    procedure DoInDataSet(const pQuery: string; pDataSet: TADOQuery); override;
    procedure DoInIterator(const pQuery: string; pIterator: IIteratorDataSet); override;
  end;

  TADOConnectionAdapter = class(TDriverConnection<TADOComponentAdapter, TADOStatementAdapter>)
  strict protected
    function DoCreateStatement(): TADOStatementAdapter; override;

    procedure DoConnect(); override;
    procedure DoDisconect(); override;

    function DoInTransaction(): Boolean; override;
    procedure DoStartTransaction(); override;
    procedure DoCommit(); override;
    procedure DoRollback(); override;

    procedure DoAfterBuild(); override;
  end;

  TADOConnectionManagerAdapter = class(TDriverConnectionManager<string, TADOConnectionAdapter>);

  IADOSingletonConnectionAdapter = interface(IDriverSingletonConnection<TADOConnectionAdapter>)
    ['{BD8FED5F-99C9-4DF1-9FF0-8EF576F48317}']
  end;

  ADOAdapter = class sealed
  strict private
  const
    CanNotBeInstantiatedException = 'This class can not be instantiated!';
  strict private

    {$HINTS OFF}

    constructor Create;

    {$HINTS ON}

  public
    class function SingletonConnection(): IADOSingletonConnectionAdapter; static;
    class function NewQueryBuilder(pDataSet: TADOQuery): IDriverQueryBuilder<TADOQuery>; static;
  end;

implementation

uses
  InfraFwk4D;

type

  TADOSingletonConnectionAdapter = class(TInterfacedObject, IADOSingletonConnectionAdapter)
  private
    class var SingletonConnection: IADOSingletonConnectionAdapter;
    class constructor Create;
    {$HINTS OFF}
    class destructor Destroy;
    {$HINTS ON}
  private
    FConnectionAdapter: TADOConnectionAdapter;

    function GetInstance(): TADOConnectionAdapter;
  public
    constructor Create;
    destructor Destroy; override;

    property Instance: TADOConnectionAdapter read GetInstance;
  end;

  TADOQueryBuilder = class(TInterfacedObject, IDriverQueryBuilder<TADOQuery>)
  private
    FDataSet: TADOQuery;
    FQueryBegin: string;
    FQueryParserSelect: ISQLParserSelect;
  public
    constructor Create(const pDataSet: TADOQuery);
    destructor Destroy; override;

    function Initialize(pSelect: ISQLSelect): IDriverQueryBuilder<TADOQuery>; overload;
    function Initialize(pWhere: ISQLWhere): IDriverQueryBuilder<TADOQuery>; overload;
    function Initialize(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TADOQuery>; overload;
    function Initialize(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TADOQuery>; overload;
    function Initialize(pHaving: ISQLHaving): IDriverQueryBuilder<TADOQuery>; overload;
    function Initialize(const pQuery: string): IDriverQueryBuilder<TADOQuery>; overload;

    function Restore(): IDriverQueryBuilder<TADOQuery>;

    function Build(pWhere: ISQLWhere): IDriverQueryBuilder<TADOQuery>; overload;
    function Build(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TADOQuery>; overload;
    function Build(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TADOQuery>; overload;
    function Build(pHaving: ISQLHaving): IDriverQueryBuilder<TADOQuery>; overload;
    function Build(const pQuery: string): IDriverQueryBuilder<TADOQuery>; overload;

    function Add(pWhere: ISQLWhere): IDriverQueryBuilder<TADOQuery>; overload;
    function Add(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TADOQuery>; overload;
    function Add(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TADOQuery>; overload;
    function Add(pHaving: ISQLHaving): IDriverQueryBuilder<TADOQuery>; overload;
    function Add(const pQuery: string): IDriverQueryBuilder<TADOQuery>; overload;

    function AddParamByName(const pParam: string; const pValue: Variant):IDriverQueryBuilder<TADOQuery>;

    procedure Activate;
  end;

  { TADOStatementAdapter }

function TADOStatementAdapter.DoAsDataSet(const pQuery: string;
  const pFetchRows: Integer): TADOQuery;
begin
  Result := TADOQuery.Create(nil);
  Result.Connection := GetConnection.Component.Connection;
  Result.SQL.Add(pQuery);
  Result.CommandTimeout := 0;
  Result.Prepared := True;
  Result.Open;
end;

function TADOStatementAdapter.DoAsFloat(const pQuery: string): Double;
var
  vIterator: IIteratorDataSet;
begin
  Result := 0;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsFloat;
end;

function TADOStatementAdapter.DoAsInteger(const pQuery: string): Integer;
var
  vIterator: IIteratorDataSet;
begin
  Result := 0;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsInteger;
end;

function TADOStatementAdapter.DoAsIterator(const pQuery: string;
  const pFetchRows: Integer): IIteratorDataSet;
begin
  Result := IteratorDataSetFactory.Build(DoAsDataSet(pQuery, pFetchRows), True);
end;

function TADOStatementAdapter.DoAsString(const pQuery: string): string;
var
  vIterator: IIteratorDataSet;
begin
  Result := EmptyStr;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsString;
end;

function TADOStatementAdapter.DoAsVariant(const pQuery: string): Variant;
var
  vIterator: IIteratorDataSet;
begin
  Result := varNull;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsVariant;
end;

procedure TADOStatementAdapter.DoExecute(const pQuery: string;
  pDataSet: TADOQuery; const pAutoCommit: Boolean);
var
  vDataSet: TADOQuery;
  vOwnsDataSet: Boolean;
begin
  inherited;
  if (pDataSet = nil) then
  begin
    vDataSet := TADOQuery.Create(nil);
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
        vDataSet.Prepared := True;
        vDataSet.ExecSQL;
        GetConnection.Commit;
      except
        GetConnection.Rollback;
        raise;
      end;
    end
    else
    begin
      vDataSet.Prepared := True;
      vDataSet.ExecSQL;
    end;
  finally
    vDataSet.Close;
    vDataSet.Connection := nil;
    if vOwnsDataSet then
      FreeAndNil(vDataSet);
  end;
end;

procedure TADOStatementAdapter.DoInDataSet(const pQuery: string;
  pDataSet: TADOQuery);
begin
  inherited;
  if (pDataSet = nil) then
    raise EDataSetDoesNotExist.Create('DataSet does not exist!');
  pDataSet.Close;
  pDataSet.Connection := GetConnection.Component.Connection;
  pDataSet.SQL.Clear;
  pDataSet.SQL.Add(pQuery);
  pDataSet.Prepared := True;
  pDataSet.Open;
end;

procedure TADOStatementAdapter.DoInIterator(const pQuery: string;
  pIterator: IIteratorDataSet);
begin
  inherited;
  DoInDataSet(pQuery, TADOQuery(pIterator.GetDataSet));
end;

{ TADOConnectionAdapter }

procedure TADOConnectionAdapter.DoAfterBuild;
begin
  inherited;

end;

procedure TADOConnectionAdapter.DoCommit;
begin
  inherited;
  Component.Connection.CommitTrans();
end;

procedure TADOConnectionAdapter.DoConnect;
begin
  inherited;
  Component.Connection.Open();
end;

function TADOConnectionAdapter.DoCreateStatement: TADOStatementAdapter;
begin
  Result := TADOStatementAdapter.Create(Self);
end;

procedure TADOConnectionAdapter.DoDisconect;
begin
  inherited;
  Component.Connection.Close();
end;

function TADOConnectionAdapter.DoInTransaction: Boolean;
begin
  Result := Component.Connection.InTransaction;
end;

procedure TADOConnectionAdapter.DoRollback;
begin
  inherited;
  Component.Connection.RollbackTrans;
end;

procedure TADOConnectionAdapter.DoStartTransaction;
begin
  inherited;
  Component.Connection.BeginTrans;
end;

{ TADOSingletonConnectionAdapter }

class constructor TADOSingletonConnectionAdapter.Create;
begin
  Critical.Section.Enter;
  try
    SingletonConnection := TADOSingletonConnectionAdapter.Create;
  finally
    Critical.Section.Leave;
  end;
end;

class destructor TADOSingletonConnectionAdapter.Destroy;
begin
  SingletonConnection := nil;
end;

constructor TADOSingletonConnectionAdapter.Create;
begin
  FConnectionAdapter := TADOConnectionAdapter.Create;
end;

destructor TADOSingletonConnectionAdapter.Destroy;
begin
  FreeAndNil(FConnectionAdapter);
  inherited Destroy();
end;

function TADOSingletonConnectionAdapter.GetInstance: TADOConnectionAdapter;
begin
  Result := FConnectionAdapter;
end;

{ TADOQueryBuilder }

procedure TADOQueryBuilder.Activate;
begin
  FDataSet.Open();
end;

function TADOQueryBuilder.Build(pOrderBy: ISQLOrderBy)
  : IDriverQueryBuilder<TADOQuery>;
begin
  Restore();
  FQueryParserSelect.AddOrderBy(pOrderBy.ToString);
  FDataSet.SQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TADOQueryBuilder.Build(pHaving: ISQLHaving)
  : IDriverQueryBuilder<TADOQuery>;
begin
  Restore();
  FQueryParserSelect.AddHaving(pHaving.ToString);
  FDataSet.SQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TADOQueryBuilder.Add(pGroupBy: ISQLGroupBy)
  : IDriverQueryBuilder<TADOQuery>;
begin
  Result := Build(pGroupBy);
end;

function TADOQueryBuilder.Add(pWhere: ISQLWhere)
  : IDriverQueryBuilder<TADOQuery>;
begin
  Result := Build(pWhere);
end;

function TADOQueryBuilder.Add(pOrderBy: ISQLOrderBy)
  : IDriverQueryBuilder<TADOQuery>;
begin
  Result := Build(pOrderBy);
end;

function TADOQueryBuilder.Add(const pQuery: string)
  : IDriverQueryBuilder<TADOQuery>;
begin
  Result := Build(pQuery);
end;

function TADOQueryBuilder.AddParamByName(const pParam: string; const pValue: Variant): IDriverQueryBuilder<TADOQuery>;
begin
  FDataSet.Parameters.ParamByName(pParam).Value := pValue;
  Result := Self;
end;

function TADOQueryBuilder.Add(pHaving: ISQLHaving)
  : IDriverQueryBuilder<TADOQuery>;
begin
  Result := Build(pHaving);
end;

function TADOQueryBuilder.Build(const pQuery: string)
  : IDriverQueryBuilder<TADOQuery>;
begin
  Result := Initialize(pQuery);
end;

function TADOQueryBuilder.Build(pGroupBy: ISQLGroupBy)
  : IDriverQueryBuilder<TADOQuery>;
begin
  Restore();
  FQueryParserSelect.AddGroupBy(pGroupBy.ToString);
  FDataSet.SQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TADOQueryBuilder.Build(pWhere: ISQLWhere)
  : IDriverQueryBuilder<TADOQuery>;
begin
  Restore();
  FQueryParserSelect.AddWhere(pWhere.ToString);
  FDataSet.SQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

constructor TADOQueryBuilder.Create(const pDataSet: TADOQuery);
begin
  if (pDataSet = nil) then
    raise EDataSetDoesNotExist.Create('DataSet does not exist in Class ' +
      Self.ClassName);
  FDataSet := pDataSet;
  FQueryParserSelect := TGaSQLParserFactory.Select();
  Initialize(pDataSet.SQL.Text);
end;

destructor TADOQueryBuilder.Destroy;
begin
  FQueryParserSelect := nil;
  inherited;
end;

function TADOQueryBuilder.Initialize(pSelect: ISQLSelect)
  : IDriverQueryBuilder<TADOQuery>;
begin
  Result := Initialize(pSelect.ToString);
end;

function TADOQueryBuilder.Initialize(pHaving: ISQLHaving)
  : IDriverQueryBuilder<TADOQuery>;
begin
  Result := Initialize(pHaving.ToString);
end;

function TADOQueryBuilder.Initialize(const pQuery: string)
  : IDriverQueryBuilder<TADOQuery>;
begin
  FDataSet.Close;
  FQueryBegin := pQuery;
  FQueryParserSelect.Parse(FQueryBegin);
  FDataSet.SQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

function TADOQueryBuilder.Initialize(pOrderBy: ISQLOrderBy)
  : IDriverQueryBuilder<TADOQuery>;
begin
  Result := Initialize(pOrderBy.ToString);
end;

function TADOQueryBuilder.Initialize(pWhere: ISQLWhere)
  : IDriverQueryBuilder<TADOQuery>;
begin
  Result := Initialize(pWhere.ToString);
end;

function TADOQueryBuilder.Initialize(pGroupBy: ISQLGroupBy)
  : IDriverQueryBuilder<TADOQuery>;
begin
  Result := Initialize(pGroupBy.ToString);
end;

function TADOQueryBuilder.Restore: IDriverQueryBuilder<TADOQuery>;
begin
  FDataSet.Close;
  FQueryParserSelect.Parse(FQueryBegin);
  FDataSet.SQL.Text := FQueryParserSelect.ToString();
  Result := Self;
end;

{ ADOAdapter }

constructor ADOAdapter.Create;
begin
  raise EInfraException.Create(CanNotBeInstantiatedException);
end;

class function ADOAdapter.NewQueryBuilder(pDataSet: TADOQuery): IDriverQueryBuilder<TADOQuery>;
begin
  Result := TADOQueryBuilder.Create(pDataSet);
end;

class function ADOAdapter.SingletonConnection: IADOSingletonConnectionAdapter;
begin
  Result := TADOSingletonConnectionAdapter.SingletonConnection;
end;

end.
