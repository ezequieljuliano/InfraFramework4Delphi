unit InfraFwk4D.Driver;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.SyncObjs,
  Data.DB,
  SQLBuilder4D,
  InfraFwk4D.Iterator.DataSet;

type

  TDriverComponent<TConnection: TComponent> = class abstract
  strict private
    FConnection: TConnection;
    function GetConnection(): TConnection;
  public
    constructor Create(const pConnection: TConnection);

    property Connection: TConnection read GetConnection;
  end;

  TDriverStatement<TDrvDataSet: TDataSet; TDrvConnection: class> = class abstract
  strict private
    FConnection: TDrvConnection;
    FQuery: string;
  strict protected
    function GetConnection(): TDrvConnection;

    procedure DoExecute(const pQuery: string; const pDataSet: TDrvDataSet; const pAutoCommit: Boolean); virtual; abstract;

    function DoAsDataSet(const pQuery: string; const pFetchRows: Integer): TDrvDataSet; virtual; abstract;
    function DoAsIterator(const pQuery: string; const pFetchRows: Integer): IIteratorDataSet; virtual; abstract;
    function DoAsInteger(const pQuery: string): Integer; virtual; abstract;
    function DoAsFloat(const pQuery: string): Double; virtual; abstract;
    function DoAsString(const pQuery: string): string; virtual; abstract;
    function DoAsVariant(const pQuery: string): Variant; virtual; abstract;

    procedure DoInDataSet(const pQuery: string; const pDataSet: TDrvDataSet); virtual; abstract;
    procedure DoInIterator(const pQuery: string; const pIterator: IIteratorDataSet); virtual; abstract;
  public
    constructor Create(const pConnection: TDrvConnection);

    function Build(const pInsert: ISQLInsert): TDriverStatement<TDrvDataSet, TDrvConnection>; overload;
    function Build(const pUpdate: ISQLUpdate): TDriverStatement<TDrvDataSet, TDrvConnection>; overload;
    function Build(const pDelete: ISQLDelete): TDriverStatement<TDrvDataSet, TDrvConnection>; overload;
    function Build(const pWhere: ISQLWhere): TDriverStatement<TDrvDataSet, TDrvConnection>; overload;
    function Build(const pGroupBy: ISQLGroupBy): TDriverStatement<TDrvDataSet, TDrvConnection>; overload;
    function Build(const pHaving: ISQLHaving): TDriverStatement<TDrvDataSet, TDrvConnection>; overload;
    function Build(const pOrderBy: ISQLOrderBy): TDriverStatement<TDrvDataSet, TDrvConnection>; overload;
    function Build(const pQuery: string): TDriverStatement<TDrvDataSet, TDrvConnection>; overload;

    procedure Execute(const pAutoCommit: Boolean = False); overload;
    procedure Execute(const pDataSet: TDrvDataSet; const pAutoCommit: Boolean = False); overload;

    function AsDataSet(const pFetchRows: Integer = 0): TDrvDataSet;
    function AsIterator(const pFetchRows: Integer = 0): IIteratorDataSet;
    function AsInteger(): Integer;
    function AsFloat(): Double;
    function AsString(): string;
    function AsVariant(): Variant;

    procedure InDataSet(const pDataSet: TDrvDataSet);
    procedure InIterator(const pIterator: IIteratorDataSet);
  end;

  TDriverConnection<TDrvComponent, TDrvStatement: class> = class abstract
  strict private
    FComponent: TDrvComponent;
    FOwnsComponent: Boolean;
    FStatement: TDrvStatement;
    procedure DestroyComponent();
    function GetComponent(): TDrvComponent;
    function GetStatement(): TDrvStatement;
  strict protected
    function DoCreateStatement(): TDrvStatement; virtual; abstract;

    procedure DoConnect(); virtual; abstract;
    procedure DoDisconect(); virtual; abstract;

    function DoInTransaction(): Boolean; virtual; abstract;
    procedure DoStartTransaction(); virtual; abstract;
    procedure DoCommit(); virtual; abstract;
    procedure DoRollback(); virtual; abstract;

    procedure DoAfterBuild(); virtual; abstract;
  public
    constructor Create();
    destructor Destroy(); override;

    procedure Connect();
    procedure Disconect();

    function InTransaction(): Boolean;
    procedure StartTransaction();
    procedure Commit();
    procedure Rollback();

    procedure Build(const pComponent: TDrvComponent); overload;
    procedure Build(const pComponent: TDrvComponent; const pOwnsComponent: Boolean); overload;

    property Component: TDrvComponent read GetComponent;
    property Statement: TDrvStatement read GetStatement;
  end;

  IDriverSingletonConnection<TDrvConnection: class> = interface
    ['{41DD3466-534A-40E0-91DF-747483359CEE}']
    function GetInstance(): TDrvConnection;

    property Instance: TDrvConnection read GetInstance;
  end;

  TDriverClass = class of TObject;

  TDriverConnectionManager<TKey; TDrvConnection: class> = class abstract
  strict private
  type
    TConnectionProperties = class
    strict private
      FObj: TDrvConnection;
      FOwnsObj: Boolean;
    public
      constructor Create(const pObj: TDrvConnection; const pOwnsObj: Boolean);
      destructor Destroy(); override;

      property Obj: TDrvConnection read FObj;
      property OwnsObj: Boolean read FOwnsObj;
    end;
  strict private
    FConnections: TObjectDictionary<TKey, TConnectionProperties>;
    procedure InternalRegisterConnection(const pKey: TKey; pConnectionProperties: TConnectionProperties);
    function GetCount: Integer;
  public
    constructor Create();
    destructor Destroy(); override;

    procedure RegisterConnection(const pKey: TKey; const pConnection: TDrvConnection); overload;
    procedure RegisterConnection(const pKey: TKey; const pConnectionClass: TDriverClass); overload;

    procedure UnregisterConnection(const pKey: TKey);
    procedure UnregisterAllConnections();

    function ConnectionIsRegistered(const pKey: TKey): Boolean;

    function GetConnection(const pKey: TKey): TDrvConnection;

    property Count: Integer read GetCount;
  end;

  IDriverQueryBuilder<TDrvDataSet: TDataSet> = interface
    ['{EFA518A7-79BE-475D-8991-7A59A8D6685B}']
    function Initialize(const pSelect: ISQLSelect): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Initialize(const pWhere: ISQLWhere): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Initialize(const pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Initialize(const pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Initialize(const pHaving: ISQLHaving): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Initialize(const pQuery: string): IDriverQueryBuilder<TDrvDataSet>; overload;

    function Restore(): IDriverQueryBuilder<TDrvDataSet>;

    function Build(const pWhere: ISQLWhere): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Build(const pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Build(const pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Build(const pHaving: ISQLHaving): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Build(const pQuery: string): IDriverQueryBuilder<TDrvDataSet>; overload;

    procedure Activate;
  end;

  TDriverPersistenceClass = class of TDataModule;

  TDriverBusiness<TDrvPersistence: TDataModule> = class abstract
  strict private
    FPersistence: TDrvPersistence;
    FOwnsPersistence: Boolean;
    procedure InternalCreate(const pPersistence: TDrvPersistence; const pOwnsPersistence: Boolean);
    function GetPersistence(): TDrvPersistence;
  strict protected

  public
    constructor Create(const pPersistence: TDrvPersistence); overload;
    constructor Create(const pPersistence: TDriverPersistenceClass); overload;
    constructor Create(const pPersistence: TDrvPersistence; const pOwnsPersistence: Boolean); overload;

    destructor Destroy; override;

    property Persistence: TDrvPersistence read GetPersistence;
  end;

implementation

uses
  InfraFwk4D;

{ TDriverComponent<TConnection> }

constructor TDriverComponent<TConnection>.Create(const pConnection: TConnection);
begin
  FConnection := pConnection;
end;

function TDriverComponent<TConnection>.GetConnection: TConnection;
begin
  Result := FConnection;
end;

{ TDriverStatement<TDrvDataSet, TDrvConnection> }

function TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pDelete: ISQLDelete): TDriverStatement<TDrvDataSet, TDrvConnection>;
begin
  FQuery := pDelete.ToString;
  Result := Self;
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pWhere: ISQLWhere): TDriverStatement<TDrvDataSet, TDrvConnection>;
begin
  FQuery := pWhere.ToString;
  Result := Self;
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pInsert: ISQLInsert): TDriverStatement<TDrvDataSet, TDrvConnection>;
begin
  FQuery := pInsert.ToString;
  Result := Self;
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pUpdate: ISQLUpdate): TDriverStatement<TDrvDataSet, TDrvConnection>;
begin
  FQuery := pUpdate.ToString;
  Result := Self;
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pOrderBy: ISQLOrderBy): TDriverStatement<TDrvDataSet, TDrvConnection>;
begin
  FQuery := pOrderBy.ToString;
  Result := Self;
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.AsDataSet(
  const pFetchRows: Integer): TDrvDataSet;
begin
  Result := DoAsDataSet(FQuery, pFetchRows);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.AsFloat: Double;
begin
  Result := DoAsFloat(FQuery);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.AsInteger: Integer;
begin
  Result := DoAsInteger(FQuery);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.AsIterator(
  const pFetchRows: Integer): IIteratorDataSet;
begin
  Result := DoAsIterator(FQuery, pFetchRows);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.AsString: string;
begin
  Result := DoAsString(FQuery);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.AsVariant: Variant;
begin
  Result := DoAsVariant(FQuery);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pQuery: string): TDriverStatement<TDrvDataSet, TDrvConnection>;
begin
  FQuery := pQuery;
  Result := Self;
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pGroupBy: ISQLGroupBy): TDriverStatement<TDrvDataSet, TDrvConnection>;
begin
  FQuery := pGroupBy.ToString;
  Result := Self;
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pHaving: ISQLHaving): TDriverStatement<TDrvDataSet, TDrvConnection>;
begin
  FQuery := pHaving.ToString;
  Result := Self;
end;

constructor TDriverStatement<TDrvDataSet, TDrvConnection>.Create(const pConnection: TDrvConnection);
begin
  FConnection := pConnection;
  FQuery := EmptyStr;
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Execute(const pAutoCommit: Boolean);
begin
  DoExecute(FQuery, nil, pAutoCommit);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Execute(const pDataSet: TDrvDataSet;
  const pAutoCommit: Boolean);
begin
  DoExecute(FQuery, pDataSet, pAutoCommit);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.GetConnection: TDrvConnection;
begin
  Result := FConnection;
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.InDataSet(const pDataSet: TDrvDataSet);
begin
  DoInDataSet(FQuery, pDataSet);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.InIterator(
  const pIterator: IIteratorDataSet);
begin
  DoInIterator(FQuery, pIterator);
end;

{ TDriverConnection<TDrvComponent, TDrvStatement> }

procedure TDriverConnection<TDrvComponent, TDrvStatement>.Build(const pComponent: TDrvComponent;
  const pOwnsComponent: Boolean);
begin
  DestroyComponent();
  FComponent := pComponent;
  FOwnsComponent := pOwnsComponent;
  DoAfterBuild();
end;

procedure TDriverConnection<TDrvComponent, TDrvStatement>.Build(const pComponent: TDrvComponent);
begin
  Build(pComponent, True);
end;

procedure TDriverConnection<TDrvComponent, TDrvStatement>.Commit;
begin
  DoCommit();
end;

procedure TDriverConnection<TDrvComponent, TDrvStatement>.Connect;
begin
  DoConnect();
end;

constructor TDriverConnection<TDrvComponent, TDrvStatement>.Create;
begin
  FComponent := nil;
  FOwnsComponent := True;
  FStatement := DoCreateStatement();
end;

destructor TDriverConnection<TDrvComponent, TDrvStatement>.Destroy;
begin
  DestroyComponent();
  if (FStatement <> nil) then
    FreeAndNil(FStatement);
  inherited Destroy();
end;

procedure TDriverConnection<TDrvComponent, TDrvStatement>.DestroyComponent;
begin
  if (FOwnsComponent) and (FComponent <> nil) then
    FreeAndNil(FComponent);
end;

procedure TDriverConnection<TDrvComponent, TDrvStatement>.Disconect;
begin
  DoDisconect();
end;

function TDriverConnection<TDrvComponent, TDrvStatement>.GetComponent: TDrvComponent;
begin
  if (FComponent = nil) then
    raise EComponentDoesNotExist.Create('Database Component does not exist!');

  Result := FComponent;
end;

function TDriverConnection<TDrvComponent, TDrvStatement>.GetStatement: TDrvStatement;
begin
  if (FStatement = nil) then
    raise EStatementDoesNotExist.Create('Database Statement does not exist!');

  Result := FStatement;
end;

function TDriverConnection<TDrvComponent, TDrvStatement>.InTransaction: Boolean;
begin
  Result := DoInTransaction();
end;

procedure TDriverConnection<TDrvComponent, TDrvStatement>.Rollback;
begin
  DoRollback();
end;

procedure TDriverConnection<TDrvComponent, TDrvStatement>.StartTransaction;
begin
  DoStartTransaction();
end;

{ TDriverConnectionManager<TKey, TDrvConnection>.TConnectionProperties }

constructor TDriverConnectionManager<TKey, TDrvConnection>.TConnectionProperties.Create(
  const pObj: TDrvConnection; const pOwnsObj: Boolean);
begin
  FObj := pObj;
  FOwnsObj := pOwnsObj;
end;

destructor TDriverConnectionManager<TKey, TDrvConnection>.TConnectionProperties.Destroy;
begin
  if (FOwnsObj) then
    FreeAndNil(FObj);
  inherited Destroy();
end;

{ TDriverConnectionManager<TKey, TDrvConnection> }

function TDriverConnectionManager<TKey, TDrvConnection>.ConnectionIsRegistered(
  const pKey: TKey): Boolean;
begin
  Result := FConnections.ContainsKey(pKey);
end;

constructor TDriverConnectionManager<TKey, TDrvConnection>.Create;
begin
  FConnections := TObjectDictionary<TKey, TConnectionProperties>.Create([doOwnsValues]);
end;

destructor TDriverConnectionManager<TKey, TDrvConnection>.Destroy;
begin
  UnregisterAllConnections();
  FreeAndNil(FConnections);
  inherited Destroy();
end;

function TDriverConnectionManager<TKey, TDrvConnection>.GetConnection(
  const pKey: TKey): TDrvConnection;
begin
  if ConnectionIsRegistered(pKey) then
  begin
    GlobalCriticalSection.Enter;
    try
      Result := FConnections.Items[pKey].Obj;
    finally
      GlobalCriticalSection.Leave;
    end;
  end
  else
    raise EConnectionUnregistered.Create('Database connection unregistered!');
end;

function TDriverConnectionManager<TKey, TDrvConnection>.GetCount: Integer;
begin
  Result := FConnections.Count;
end;

procedure TDriverConnectionManager<TKey, TDrvConnection>.InternalRegisterConnection(
  const pKey: TKey; pConnectionProperties: TConnectionProperties);
begin
  if not ConnectionIsRegistered(pKey) then
  begin
    GlobalCriticalSection.Enter;
    try
      FConnections.Add(pKey, pConnectionProperties);
    finally
      GlobalCriticalSection.Leave;
    end;
  end
  else
    raise EConnectionAlreadyRegistered.Create('Database already registered!');
end;

procedure TDriverConnectionManager<TKey, TDrvConnection>.RegisterConnection(const pKey: TKey;
  const pConnection: TDrvConnection);
begin
  InternalRegisterConnection(pKey, TConnectionProperties.Create(pConnection, False));
end;

procedure TDriverConnectionManager<TKey, TDrvConnection>.RegisterConnection(const pKey: TKey;
  const pConnectionClass: TDriverClass);
begin
  InternalRegisterConnection(pKey, TConnectionProperties.Create(pConnectionClass.Create(), True));
end;

procedure TDriverConnectionManager<TKey, TDrvConnection>.UnregisterAllConnections;
begin
  GlobalCriticalSection.Enter;
  try
    FConnections.Clear;
  finally
    GlobalCriticalSection.Leave;
  end;
end;

procedure TDriverConnectionManager<TKey, TDrvConnection>.UnregisterConnection(const pKey: TKey);
begin
  if ConnectionIsRegistered(pKey) then
  begin
    GlobalCriticalSection.Enter;
    try
      FConnections.Remove(pKey);
    finally
      GlobalCriticalSection.Leave;
    end;
  end
  else
    raise EConnectionUnregistered.Create('Database connection unregistered!');
end;

{ TDriverBusiness<TDrvPersistence> }

constructor TDriverBusiness<TDrvPersistence>.Create(const pPersistence: TDrvPersistence);
begin
  InternalCreate(pPersistence, True);
end;

constructor TDriverBusiness<TDrvPersistence>.Create(
  const pPersistence: TDrvPersistence; const pOwnsPersistence: Boolean);
begin
  InternalCreate(pPersistence, pOwnsPersistence);
end;

constructor TDriverBusiness<TDrvPersistence>.Create(const pPersistence: TDriverPersistenceClass);
begin
  InternalCreate(pPersistence.Create(nil), True);
end;

destructor TDriverBusiness<TDrvPersistence>.Destroy;
begin
  if FOwnsPersistence and (FPersistence <> nil) then
    FreeAndNil(FPersistence);
  inherited Destroy();
end;

function TDriverBusiness<TDrvPersistence>.GetPersistence: TDrvPersistence;
begin
  if (FPersistence = nil) then
    raise EPersistenceDoesNotExist.Create('Persistence does not exist!');
  Result := FPersistence;
end;

procedure TDriverBusiness<TDrvPersistence>.InternalCreate(
  const pPersistence: TDrvPersistence; const pOwnsPersistence: Boolean);
begin
  FPersistence := pPersistence;
  FOwnsPersistence := pOwnsPersistence;
end;

end.
