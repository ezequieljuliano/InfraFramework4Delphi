unit InfraFwk4D.Persistence.Base;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Rtti,
  System.Generics.Collections,
  Data.DB,
  Data.DBCommon,
  InfraFwk4D.Persistence,
  InfraFwk4D.DataSet.Iterator,
  SQLBuilder4D,
  SQLBuilder4D.Parser,
  SQLBuilder4D.Parser.GaSQLParser;

type

  TDriverAdapterBase = class(TInterfacedObject)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  TDriverConnectionAdapter<T: TComponent> = class(TDriverAdapterBase, IDBConnection<T>)
  private
    fComponent: T;
  protected
    function GetComponent: T;
  public
    constructor Create(const component: T);
  end;

  TDriverStatementAdapter<T: TDataSet; C: TComponent> = class(TDriverAdapterBase, IDBStatement<T>)
  private
    fConnection: IDBConnection<C>;
    fQuery: string;
    fParams: TDictionary<string, TValue>;
  protected
    function GetQuery: string;
    function GetConnection: IDBConnection<C>;
    function GetParams: TDictionary<string, TValue>;

    function Build(const query: string): IDBStatement<T>; overload;
    function Build(const query: ISQL): IDBStatement<T>; overload;

    function AddOrSetParam(const name: string; const value: TValue): IDBStatement<T>; overload;
    function AddOrSetParam(const name: string; const value: ISQLValue): IDBStatement<T>; overload;
    function ClearParams: IDBStatement<T>;
    function Prepare(const dataSet: T): IDBStatement<T>; virtual; abstract;

    procedure Open(const dataSet: T); overload; virtual; abstract;
    procedure Open(const iterator: IDataSetIterator<T>); overload;

    procedure Execute; overload;
    procedure Execute(const commit: Boolean); overload; virtual; abstract;

    function AsDataSet: T; overload;
    function AsDataSet(const fetchRows: Integer): T; overload; virtual; abstract;

    function AsIterator: IDataSetIterator<T>; overload;
    function AsIterator(const fetchRows: Integer): IDataSetIterator<T>; overload;

    function AsField: TField;
  public
    constructor Create(const connection: IDBConnection<C>);
    destructor Destroy; override;
  end;

  TDriverSessionAdapter<C: TComponent; T: TDataSet> = class(TDriverAdapterBase, IDBSession<C, T>)
  private
    fConnection: IDBConnection<C>;
  protected
    function GetConnection: IDBConnection<C>;
    function NewStatement: IDBStatement<T>; virtual; abstract;
  public
    constructor Create(const connection: IDBConnection<C>);
  end;

  TDriverQueryChangerAdapter<T: TDataSet> = class(TDriverAdapterBase, IDBQueryChanger<T>)
  private
    fDataSet: T;
    fParser: ISQLParserSelect;
    fQuery: string;
    function ConditionIs(const condition: string; const token: TSQLToken): Boolean;
  protected
    function IsOrderBy(const condition: string): Boolean;
    function IsHaving(const condition: string): Boolean;
    function IsGroupBy(const condition: string): Boolean;
    function IsWhere(const condition: string): Boolean;

    function GetParser: ISQLParserSelect;
    function GetDataSet: T;

    function GetDataSetQueryText: string; virtual; abstract;
    procedure SetDataSetQueryText(const value: string); virtual; abstract;

    function Initialize(const query: string): IDBQueryChanger<T>; overload;
    function Initialize(const query: ISQL): IDBQueryChanger<T>; overload;

    function Add(const condition: string): IDBQueryChanger<T>; overload;
    function Add(const condition: ISQLClause): IDBQueryChanger<T>; overload;

    function Restore: IDBQueryChanger<T>;

    procedure Activate;
  public
    constructor Create(const dataSet: T);
  end;

  TDriverMetaDataInfoAdapter<T: TDataSet; C: TComponent> = class(TDriverAdapterBase, IDBMetaDataInfo<T>)
  private
    fSession: IDBSession<C, T>;
  protected
    function GetSession: IDBSession<C, T>;

    function GetTables: IDataSetIterator<T>; virtual; abstract;
    function GetFields(const tableName: string): IDataSetIterator<T>; virtual; abstract;
    function GetPrimaryKeys(const tableName: string): IDataSetIterator<T>; virtual; abstract;
    function GetIndexes(const tableName: string): IDataSetIterator<T>; virtual; abstract;
    function GetForeignKeys(const tableName: string): IDataSetIterator<T>; virtual; abstract;
    function GetGenerators: IDataSetIterator<T>; virtual; abstract;

    function TableExists(const tableName: string): Boolean;
    function FieldExists(const tableName, fieldName: string): Boolean;
    function PrimaryKeyExists(const tableName, primaryKeyName: string): Boolean;
    function IndexExists(const tableName, indexName: string): Boolean;
    function ForeignKeyExists(const tableName, foreignKeyName: string): Boolean;
    function GeneratorExists(const generatorName: string): Boolean;
  public
    constructor Create(const session: IDBSession<C, T>);
  end;

implementation

{ TDriverConnectionAdapter<T> }

constructor TDriverConnectionAdapter<T>.Create(const component: T);
begin
  inherited Create;
  fComponent := component;
end;

function TDriverConnectionAdapter<T>.GetComponent: T;
begin
  if not Assigned(fComponent) then
    raise EPersistenceException.CreateFmt('Connection component with database not defined in %s!', [Self.ClassName]);
  Result := fComponent;
end;

{ TDriverStatementAdapter<T, C> }

function TDriverStatementAdapter<T, C>.AsDataSet: T;
begin
  Result := AsDataSet(0);
end;

function TDriverStatementAdapter<T, C>.AsField: TField;
var
  it: IDataSetIterator<T>;
begin
  Result := nil;
  it := TDataSetIterator<T>.Create(AsDataSet);
  if not it.IsEmpty then
    Result := it.Fields[0];
end;

function TDriverStatementAdapter<T, C>.AsIterator(const fetchRows: Integer): IDataSetIterator<T>;
begin
  Result := TDataSetIterator<T>.Create(AsDataSet(fetchRows));
end;

function TDriverStatementAdapter<T, C>.AsIterator: IDataSetIterator<T>;
begin
  Result := AsIterator(0);
end;

function TDriverStatementAdapter<T, C>.Build(const query: ISQL): IDBStatement<T>;
begin
  Result := Build(query.ToString);
end;

function TDriverStatementAdapter<T, C>.Build(const query: string): IDBStatement<T>;
begin
  fQuery := query;
  Result := Self;
end;

function TDriverStatementAdapter<T, C>.ClearParams: IDBStatement<T>;
begin
  fParams.Clear;
  Result := Self;
end;

constructor TDriverStatementAdapter<T, C>.Create(const connection: IDBConnection<C>);
begin
  inherited Create;
  fConnection := connection;
  fQuery := EmptyStr;
  fParams := TDictionary<string, TValue>.Create;
end;

destructor TDriverStatementAdapter<T, C>.Destroy;
begin
  fParams.Free;
  inherited Destroy;
end;

procedure TDriverStatementAdapter<T, C>.Execute;
begin
  Execute(False);
end;

procedure TDriverStatementAdapter<T, C>.Open(const iterator: IDataSetIterator<T>);
begin
  Open(iterator.GetDataSet);
end;

function TDriverStatementAdapter<T, C>.GetConnection: IDBConnection<C>;
begin
  if not Assigned(fConnection) then
    raise EPersistenceException.CreateFmt('Connection not defined in %s!', [Self.ClassName]);
  Result := fConnection;
end;

function TDriverStatementAdapter<T, C>.GetParams: TDictionary<string, TValue>;
begin
  Result := fParams;
end;

function TDriverStatementAdapter<T, C>.GetQuery: string;
begin
  Result := fQuery;
end;

function TDriverStatementAdapter<T, C>.AddOrSetParam(const name: string; const value: TValue): IDBStatement<T>;
begin
  fParams.AddOrSetValue(name, value);
  Result := Self;
end;

function TDriverStatementAdapter<T, C>.AddOrSetParam(const name: string; const value: ISQLValue): IDBStatement<T>;
begin
  Result := AddOrSetParam(name, value.ToString);
end;

{ TDriverSessionAdapter<C, T> }

function TDriverSessionAdapter<C, T>.GetConnection: IDBConnection<C>;
begin
  if not Assigned(fConnection) then
    raise EPersistenceException.CreateFmt('Connection not defined in %s!', [Self.ClassName]);
  Result := fConnection;
end;

constructor TDriverSessionAdapter<C, T>.Create(const connection: IDBConnection<C>);
begin
  inherited Create;
  fConnection := connection;
end;

{ TDriverQueryChangerAdapter<T> }

procedure TDriverQueryChangerAdapter<T>.Activate;
begin
  fDataSet.Open;
  fParser.Parse(fQuery);
end;

function TDriverQueryChangerAdapter<T>.Add(const condition: ISQLClause): IDBQueryChanger<T>;
begin
  Result := Add(condition.ToString);
end;

function TDriverQueryChangerAdapter<T>.Add(const condition: string): IDBQueryChanger<T>;
begin
  if IsOrderBy(condition) then
    fParser.AddOrderBy(condition)
  else if IsHaving(condition) then
    fParser.AddHaving(condition)
  else if IsGroupBy(condition) then
    fParser.AddGroupBy(condition)
  else if IsWhere(condition) then
    fParser.AddWhere(condition)
  else
    raise EPersistenceException.CreateFmt('SQL query condition is not valid for %s!', [Self.ClassName]);
  SetDataSetQueryText(fParser.ToString);
  Result := Self;
end;

function TDriverQueryChangerAdapter<T>.ConditionIs(const condition: string; const token: TSQLToken): Boolean;
var
  sqlToken: TSQLToken;
  curSection: TSQLToken;
  start: PWideChar;
  s: string;
  idOption: IDENTIFIEROption;
begin
  Result := False;
  idOption := idMixCase;
  start := PWideChar(condition);
  curSection := stUnknown;
  repeat
    sqlToken := NextSQLTokenEx(start, s, curSection, idOption);
    if (sqlToken = token) then
      Exit(True);
    curSection := sqlToken;
  until sqlToken in [stEnd];
end;

constructor TDriverQueryChangerAdapter<T>.Create(const dataSet: T);
begin
  inherited Create;
  fDataSet := dataSet;
  fParser := TGaSQLParserFactory.Select;
  fQuery := EmptyStr;
  Initialize(GetDataSetQueryText);
end;

function TDriverQueryChangerAdapter<T>.GetDataSet: T;
begin
  Result := fDataSet;
end;

function TDriverQueryChangerAdapter<T>.GetParser: ISQLParserSelect;
begin
  Result := fParser;
end;

function TDriverQueryChangerAdapter<T>.Initialize(const query: string): IDBQueryChanger<T>;
begin
  fDataSet.Close;
  fQuery := query;
  fParser.Parse(fQuery);
  SetDataSetQueryText(fParser.ToString);
  Result := Self;
end;

function TDriverQueryChangerAdapter<T>.Initialize(const query: ISQL): IDBQueryChanger<T>;
begin
  Result := Initialize(query.ToString);
end;

function TDriverQueryChangerAdapter<T>.IsGroupBy(const condition: string): Boolean;
begin
  Result := ConditionIs(condition, stGroupBy);
end;

function TDriverQueryChangerAdapter<T>.IsHaving(const condition: string): Boolean;
begin
  Result := ConditionIs(condition, stHaving);
end;

function TDriverQueryChangerAdapter<T>.IsOrderBy(const condition: string): Boolean;
begin
  Result := ConditionIs(condition, stOrderBy);
end;

function TDriverQueryChangerAdapter<T>.IsWhere(const condition: string): Boolean;
begin
  Result := ConditionIs(condition, stWhere);
end;

function TDriverQueryChangerAdapter<T>.Restore: IDBQueryChanger<T>;
begin
  fDataSet.Close;
  fParser.Parse(fQuery);
  SetDataSetQueryText(fParser.ToString);
  Result := Self;
end;

{ TDriverMetaDataInfoAdapter<T, C> }

constructor TDriverMetaDataInfoAdapter<T, C>.Create(const session: IDBSession<C, T>);
begin
  inherited Create;
  fSession := session;
end;

function TDriverMetaDataInfoAdapter<T, C>.FieldExists(const tableName, fieldName: string): Boolean;
var
  it: IDataSetIterator<T>;
begin
  Result := False;
  it := GetFields(tableName);
  while it.HasNext do
    if it.FieldByName('COLUMN_NAME').AsString.Equals(fieldName) then
      Exit(True);
end;

function TDriverMetaDataInfoAdapter<T, C>.ForeignKeyExists(const tableName, foreignKeyName: string): Boolean;
var
  it: IDataSetIterator<T>;
begin
  Result := False;
  it := GetForeignKeys(tableName);
  while it.HasNext do
    if it.FieldByName('FKEY_NAME').AsString.Equals(foreignKeyName) then
      Exit(True);
end;

function TDriverMetaDataInfoAdapter<T, C>.GeneratorExists(const generatorName: string): Boolean;
var
  it: IDataSetIterator<T>;
begin
  Result := False;
  it := GetGenerators;
  while it.HasNext do
    if it.FieldByName('GENERATOR_NAME').AsString.Equals(generatorName) then
      Exit(True);
end;

function TDriverMetaDataInfoAdapter<T, C>.GetSession: IDBSession<C, T>;
begin
  if not Assigned(fSession) then
    raise EPersistenceException.CreateFmt('Session not defined in %s!', [Self.ClassName]);
  Result := fSession;
end;

function TDriverMetaDataInfoAdapter<T, C>.IndexExists(const tableName, indexName: string): Boolean;
var
  it: IDataSetIterator<T>;
begin
  Result := False;
  it := GetIndexes(tableName);
  while it.HasNext do
    if it.FieldByName('INDEX_NAME').AsString.Equals(indexName) then
      Exit(True);
end;

function TDriverMetaDataInfoAdapter<T, C>.PrimaryKeyExists(const tableName, primaryKeyName: string): Boolean;
var
  it: IDataSetIterator<T>;
begin
  Result := False;
  it := GetPrimaryKeys(tableName);
  while it.HasNext do
    if it.FieldByName('PKEY_NAME').AsString.Equals(primaryKeyName) then
      Exit(True);
end;

function TDriverMetaDataInfoAdapter<T, C>.TableExists(const tableName: string): Boolean;
var
  it: IDataSetIterator<T>;
begin
  Result := False;
  it := GetTables;
  while it.HasNext do
    if it.FieldByName('TABLE_NAME').AsString.Equals(tableName) then
      Exit(True);
end;

end.
