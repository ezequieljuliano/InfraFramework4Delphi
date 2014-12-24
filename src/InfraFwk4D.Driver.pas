unit InfraFwk4D.Driver;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.SyncObjs,
  System.Rtti,
  Data.DB,
  SQLBuilder4D,
  SQLBuilder4D.Parser,
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

  IDriverPersistence<TDrvConnection: class> = interface
    ['{23D9C938-499A-4E62-8404-8ADA73FFDF5A}']
    function GetConnection(): TDrvConnection;

    property Connection: TDrvConnection read GetConnection;
  end;

  TDriverPersistenceClass = class of TDataModule;

  TDriverBusiness<TDrvPersistence: TDataModule; TDrvDataSet: TDataSet; TDrvConnection, TDrvDetails: class> = class abstract
  strict private
    FPersistence: TDrvPersistence;
    FOwnsPersistence: Boolean;
    FDataSet: TDrvDataSet;
    FIterator: IIteratorDataSet;
    FConnection: TDrvConnection;
    FDetails: TDrvDetails;
    FQueryBegin: string;
    FQueryParserSelect: ISQLParserSelect;
    procedure InternalCreate(const pPersistence: TDrvPersistence; const pOwnsPersistence: Boolean);
    function FindDataSetOnPersistence(): TDrvDataSet;
    function FindConnectionOnPersistence(): TDrvConnection;
    function GetPersistence(): TDrvPersistence;
    function GetDataSet(): TDrvDataSet;
    function GetIterator(): IIteratorDataSet;
    function GetDetails(): TDrvDetails;
  strict protected
    function GetConnection(): TDrvConnection;
    function GetQueryBegin(): string;
    function GetQueryParserSelect(): ISQLParserSelect;

    function DoCreateDetails(): TDrvDetails; virtual; abstract;
    function DoGetDataSetQuery(): string; virtual; abstract;
    procedure DoDataSetChangeQuery(); virtual; abstract;
    procedure DoDataSetConfigureConnection(); virtual; abstract;
    procedure DoDataSetOpen(); virtual; abstract;
    procedure DoDataSetClose(); virtual; abstract;
  public
    constructor Create(const pPersistence: TDrvPersistence); overload;
    constructor Create(const pPersistence: TDriverPersistenceClass); overload;
    constructor Create(const pPersistence: TDrvPersistence; const pOwnsPersistence: Boolean); overload;

    destructor Destroy; override;

    procedure QueryInitialize(const pQuery: string);

    procedure QueryRestore(); overload;
    procedure QueryRestore(const pOpen: Boolean); overload;

    procedure QueryBuild(const pWhere: ISQLWhere); overload;
    procedure QueryBuild(const pWhere: ISQLWhere; const pOpen: Boolean); overload;

    procedure QueryBuild(const pGroupBy: ISQLGroupBy); overload;
    procedure QueryBuild(const pGroupBy: ISQLGroupBy; const pOpen: Boolean); overload;

    procedure QueryBuild(const pOrderBy: ISQLOrderBy); overload;
    procedure QueryBuild(const pOrderBy: ISQLOrderBy; const pOpen: Boolean); overload;

    procedure QueryBuild(const pHaving: ISQLHaving); overload;
    procedure QueryBuild(const pHaving: ISQLHaving; const pOpen: Boolean); overload;

    property Persistence: TDrvPersistence read GetPersistence;
    property DataSet: TDrvDataSet read GetDataSet;
    property Iterator: IIteratorDataSet read GetIterator;
    property Details: TDrvDetails read GetDetails;
  end;

  TDriverDetails<TKey; TDrvBusiness: class> = class abstract
  strict protected
  type
    TDetailProperties = class
    strict private
      FObj: TDrvBusiness;
      FOwnsObj: Boolean;
    public
      constructor Create(const pObj: TDrvBusiness; const pOwnsObj: Boolean);
      destructor Destroy(); override;

      property Obj: TDrvBusiness read FObj;
      property OwnsObj: Boolean read FOwnsObj;
    end;
  strict private
    FDetails: TObjectDictionary<TKey, TDetailProperties>;
    FMasterBusiness: TDrvBusiness;
    FMasterDataSource: TDataSource;
    function GetCount: Integer;
  strict protected
    function GetMasterBusiness(): TDrvBusiness;
    function GetMasterDataSource(): TDataSource;
    function GetDetailDictionary(): TDictionary<TKey, TDetailProperties>;

    procedure DoOpenAll(); virtual; abstract;
    procedure DoCloseAll(); virtual; abstract;
    procedure DoDisableAllControls(); virtual; abstract;
    procedure DoEnableAllControls(); virtual; abstract;
    procedure DoLinkMasterDataSource(const pMasterController: TDrvBusiness); virtual; abstract;
    procedure DoLinkDetailOnMasterDataSource(const pDetail: TDrvBusiness); virtual; abstract;
  public
    constructor Create(const pMasterBusiness: TDrvBusiness);
    destructor Destroy(); override;

    procedure RegisterDetail(const pKey: TKey; const pDetail: TDrvBusiness; const pOwnsDetail: Boolean = True);
    procedure UnregisterDetail(const pKey: TKey);
    procedure UnregisterAllDetails();

    function DetailIsRegistered(const pKey: TKey): Boolean;

    function GetDetail(const pKey: TKey): TDrvBusiness;
    function GetDetailAs<T: class>(const pKey: TKey): T;
    function GetDetailByClass<T: class>(): T;

    procedure OpenAll();
    procedure CloseAll();
    procedure DisableAllControls();
    procedure EnableAllControls();

    property Count: Integer read GetCount;
  end;

implementation

uses
  InfraFwk4D,
  InfraFwk4D.Attributes;

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

{ TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails> }

constructor TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.Create(
  const pPersistence: TDrvPersistence);
begin
  InternalCreate(pPersistence, True);
end;

constructor TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.Create(
  const pPersistence: TDrvPersistence; const pOwnsPersistence: Boolean);
begin
  InternalCreate(pPersistence, pOwnsPersistence);
end;

constructor TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.Create(
  const pPersistence: TDriverPersistenceClass);
begin
  InternalCreate(pPersistence.Create(nil), True);
end;

destructor TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.Destroy;
begin
  if (FDetails <> nil) then
    FreeAndNil(FDetails);
  if FOwnsPersistence and (FPersistence <> nil) then
    FreeAndNil(FPersistence);
  FIterator := nil;
  FQueryParserSelect := nil;
  inherited Destroy();
end;

function TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.FindConnectionOnPersistence: TDrvConnection;
var
  vCtx: TRttiContext;
  vType: TRttiType;
  vProp: TRttiProperty;
  vConnection: TValue;
begin
  Result := nil;
  vCtx := TRttiContext.Create();
  try
    vType := vCtx.GetType(GetPersistence.ClassType);
    vProp := vType.GetProperty('Connection');
    if (vProp <> nil) then
    begin
      vConnection := vProp.GetValue(Pointer(GetPersistence));
      Result := vConnection.AsType<TDrvConnection>;
    end;
  finally
    vCtx.Free;
  end;
end;

function TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.FindDataSetOnPersistence: TDrvDataSet;
var
  vBusinessCtx, vPersistenceCtx: TRttiContext;
  vBusinessType, vPersistenceType: TRttiType;
  vBusinessAttr: TCustomAttribute;
  vDataSet: TValue;
begin
  Result := nil;
  vBusinessCtx := TRttiContext.Create();
  try
    vBusinessType := vBusinessCtx.GetType(Self.ClassType);
    for vBusinessAttr in vBusinessType.GetAttributes() do
      if vBusinessAttr is DataSetComponentAttribute then
      begin
        if not DataSetComponentAttribute(vBusinessAttr).ComponentName.IsEmpty then
        begin
          vPersistenceCtx := TRttiContext.Create();
          try
            vPersistenceType := vPersistenceCtx.GetType(Persistence.ClassType);
            vDataSet := vPersistenceType.GetField(DataSetComponentAttribute(vBusinessAttr).ComponentName).GetValue(Pointer(Persistence));
            Result := vDataSet.AsType<TDrvDataSet>;
          finally
            vPersistenceCtx.Free;
          end;
        end;
        Break;
      end;
  finally
    vBusinessCtx.Free;
  end;
end;

function TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.GetConnection: TDrvConnection;
begin
  if (FConnection = nil) then
    raise EConnectionDoesNotExist.Create('Connection does not exist or Persistence Class ' + GetPersistence.ClassName +
      ' not implements IDriverPersistence!');
  Result := FConnection;
end;

function TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.GetDataSet: TDrvDataSet;
begin
  if (FDataSet = nil) then
    raise EDataSetDoesNotExist.Create('DataSet does not exist or DataSetComponent attribute not set in Business Class ' + Self.ClassName);
  Result := FDataSet;
end;

function TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.GetDetails: TDrvDetails;
begin
  if (FDetails = nil) then
    raise EDetailUnregistered.Create('Details unregistered!');
  Result := FDetails;
end;

function TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.GetIterator: IIteratorDataSet;
begin
  if (FIterator = nil) then
    FIterator := IteratorDataSetFactory.Build(GetDataSet, False);
  Result := FIterator;
end;

function TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.GetPersistence: TDrvPersistence;
begin
  if (FPersistence = nil) then
    raise EPersistenceDoesNotExist.Create('Persistence does not exist!');
  Result := FPersistence;
end;

function TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.GetQueryBegin: string;
begin
  Result := FQueryBegin;
end;

function TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.GetQueryParserSelect: ISQLParserSelect;
begin
  Result := FQueryParserSelect;
end;

procedure TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.InternalCreate(
  const pPersistence: TDrvPersistence; const pOwnsPersistence: Boolean);
begin
  FPersistence := pPersistence;
  FOwnsPersistence := pOwnsPersistence;
  FDataSet := FindDataSetOnPersistence();
  FIterator := nil;
  FConnection := FindConnectionOnPersistence();
  DoDataSetConfigureConnection();
  FQueryBegin := EmptyStr;
  FQueryParserSelect := TSQLParserFactory.GetSelectInstance(prGaSQLParser);
  QueryInitialize(DoGetDataSetQuery);
  FDetails := DoCreateDetails();
end;

procedure TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.QueryBuild(
  const pGroupBy: ISQLGroupBy);
begin
  QueryBuild(pGroupBy, True);
end;

procedure TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.QueryBuild(
  const pGroupBy: ISQLGroupBy; const pOpen: Boolean);
begin
  QueryRestore(False);
  DoDataSetClose();
  FQueryParserSelect.AddOrSetGroupBy(pGroupBy.ToString);
  DoDataSetChangeQuery();
  if pOpen then
    DoDataSetOpen();
end;

procedure TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.QueryBuild(
  const pWhere: ISQLWhere);
begin
  QueryBuild(pWhere, True);
end;

procedure TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.QueryBuild(
  const pWhere: ISQLWhere; const pOpen: Boolean);
begin
  QueryRestore(False);
  DoDataSetClose();
  FQueryParserSelect.AddOrSetWhere(pWhere.ToString);
  DoDataSetChangeQuery();
  if pOpen then
    DoDataSetOpen();
end;

procedure TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.QueryBuild(
  const pOrderBy: ISQLOrderBy);
begin
  QueryBuild(pOrderBy, True);
end;

procedure TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.QueryBuild(
  const pHaving: ISQLHaving; const pOpen: Boolean);
begin
  QueryRestore(False);
  DoDataSetClose();
  FQueryParserSelect.AddOrSetHaving(pHaving.ToString);
  DoDataSetChangeQuery();
  if pOpen then
    DoDataSetOpen();
end;

procedure TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.QueryBuild(
  const pHaving: ISQLHaving);
begin
  QueryBuild(pHaving, True);
end;

procedure TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.QueryBuild(
  const pOrderBy: ISQLOrderBy; const pOpen: Boolean);
begin
  QueryRestore(False);
  DoDataSetClose();
  FQueryParserSelect.AddOrSetOrderBy(pOrderBy.ToString);
  DoDataSetChangeQuery();
  if pOpen then
    DoDataSetOpen();
end;

procedure TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.QueryInitialize(
  const pQuery: string);
begin
  if not pQuery.IsEmpty then
  begin
    DoDataSetClose();
    FQueryBegin := pQuery;
    FQueryParserSelect.Parse(FQueryBegin);
    DoDataSetChangeQuery();
  end;
end;

procedure TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.QueryRestore;
begin
  QueryRestore(True);
end;

procedure TDriverBusiness<TDrvPersistence, TDrvDataSet, TDrvConnection, TDrvDetails>.QueryRestore(
  const pOpen: Boolean);
begin
  DoDataSetClose();
  FQueryParserSelect.Parse(FQueryBegin);
  DoDataSetChangeQuery();
  if pOpen then
    DoDataSetOpen();
end;

{ TDriverDetails<TKey, TDrvBusiness>.TDetailProperties }

constructor TDriverDetails<TKey, TDrvBusiness>.TDetailProperties.Create(const pObj: TDrvBusiness;
  const pOwnsObj: Boolean);
begin
  FObj := pObj;
  FOwnsObj := pOwnsObj;
end;

destructor TDriverDetails<TKey, TDrvBusiness>.TDetailProperties.Destroy;
begin
  if (FOwnsObj) then
    FreeAndNil(FObj);
  inherited Destroy();
end;

{ TDriverDetails<TKey, TDrvBusiness> }

procedure TDriverDetails<TKey, TDrvBusiness>.CloseAll;
begin
  DoCloseAll();
end;

constructor TDriverDetails<TKey, TDrvBusiness>.Create(const pMasterBusiness: TDrvBusiness);
begin
  FDetails := TObjectDictionary<TKey, TDetailProperties>.Create([doOwnsValues]);;
  FMasterBusiness := pMasterBusiness;
  FMasterDataSource := TDataSource.Create(nil);
  DoLinkMasterDataSource(FMasterBusiness);
end;

destructor TDriverDetails<TKey, TDrvBusiness>.Destroy;
begin
  UnregisterAllDetails();
  FreeAndNil(FDetails);
  FreeAndNil(FMasterDataSource);
  inherited Destroy();
end;

function TDriverDetails<TKey, TDrvBusiness>.DetailIsRegistered(const pKey: TKey): Boolean;
begin
  Result := FDetails.ContainsKey(pKey);
end;

procedure TDriverDetails<TKey, TDrvBusiness>.DisableAllControls;
begin
  DoDisableAllControls();
end;

procedure TDriverDetails<TKey, TDrvBusiness>.EnableAllControls;
begin
  DoEnableAllControls();
end;

function TDriverDetails<TKey, TDrvBusiness>.GetCount: Integer;
begin
  Result := FDetails.Count;
end;

function TDriverDetails<TKey, TDrvBusiness>.GetDetail(const pKey: TKey): TDrvBusiness;
begin
  if DetailIsRegistered(pKey) then
    Result := FDetails.Items[pKey].Obj
  else
    raise EDetailUnregistered.Create('Detail unregistered!');
end;

function TDriverDetails<TKey, TDrvBusiness>.GetDetailAs<T>(const pKey: TKey): T;
begin
  Result := (Self.GetDetail(pKey) as T);
end;

function TDriverDetails<TKey, TDrvBusiness>.GetDetailByClass<T>: T;
var
  vDetailPair: TPair<TKey, TDetailProperties>;
begin
  Result := nil;
  for vDetailPair in FDetails do
  begin
    if (vDetailPair.Value.Obj is T) then
    begin
      Result := (vDetailPair.Value.Obj as T);
      Exit;
    end;
  end;
end;

function TDriverDetails<TKey, TDrvBusiness>.GetDetailDictionary: TDictionary<TKey, TDetailProperties>;
begin
  Result := FDetails;
end;

function TDriverDetails<TKey, TDrvBusiness>.GetMasterBusiness: TDrvBusiness;
begin
  Result := FMasterBusiness;
end;

function TDriverDetails<TKey, TDrvBusiness>.GetMasterDataSource: TDataSource;
begin
  Result := FMasterDataSource;
end;

procedure TDriverDetails<TKey, TDrvBusiness>.OpenAll;
begin
  DoOpenAll();
end;

procedure TDriverDetails<TKey, TDrvBusiness>.RegisterDetail(const pKey: TKey;
  const pDetail: TDrvBusiness; const pOwnsDetail: Boolean);
begin
  if not DetailIsRegistered(pKey) then
  begin
    FDetails.Add(pKey, TDetailProperties.Create(pDetail, pOwnsDetail));
    DoLinkDetailOnMasterDataSource(pDetail);
  end
  else
    raise EDetailAlreadyRegistered.Create('Detail already registered!');
end;

procedure TDriverDetails<TKey, TDrvBusiness>.UnregisterAllDetails;
begin
  FDetails.Clear;
end;

procedure TDriverDetails<TKey, TDrvBusiness>.UnregisterDetail(const pKey: TKey);
begin
  if DetailIsRegistered(pKey) then
    FDetails.Remove(pKey)
  else
    raise EDetailUnregistered.Create('Detail unregistered!');
end;

end.
