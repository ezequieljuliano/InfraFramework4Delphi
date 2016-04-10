unit InfraFwk4D.Driver;

interface

uses
  Classes,
  SysUtils,
  Generics.Collections,
  SyncObjs,
  DB,
  SQLBuilder4D,
  InfraFwk4D.Iterator.DataSet;

type

  TDriverComponent<TConnection: TComponent> = class abstract
  strict private
    FConnection: TConnection;
    function GetConnection(): TConnection;
  public
    constructor Create(pConnection: TConnection);

    property Connection: TConnection read GetConnection;
  end;

  TDriverStatement<TDrvDataSet: TDataSet; TDrvConnection: class> = class abstract
  strict private
    FConnection: TDrvConnection;
    FQuery: string;
  strict protected
    function GetConnection(): TDrvConnection;

    procedure DoExecute(const pQuery: string; pDataSet: TDrvDataSet; const pAutoCommit: Boolean); virtual; abstract;

    function DoAsDataSet(const pQuery: string; const pFetchRows: Integer): TDrvDataSet; virtual; abstract;
    function DoAsIterator(const pQuery: string; const pFetchRows: Integer): IIteratorDataSet; virtual; abstract;
    function DoAsInteger(const pQuery: string): Integer; virtual; abstract;
    function DoAsFloat(const pQuery: string): Double; virtual; abstract;
    function DoAsString(const pQuery: string): string; virtual; abstract;
    function DoAsVariant(const pQuery: string): Variant; virtual; abstract;

    procedure DoInDataSet(const pQuery: string; pDataSet: TDrvDataSet); virtual; abstract;
    procedure DoInIterator(const pQuery: string; pIterator: IIteratorDataSet); virtual; abstract;
  public
    constructor Create(pConnection: TDrvConnection);

    function Build(pSelect: ISQLSelect): TDriverStatement<TDrvDataSet, TDrvConnection>; overload;
    function Build(pInsert: ISQLInsert): TDriverStatement<TDrvDataSet, TDrvConnection>; overload;
    function Build(pUpdate: ISQLUpdate): TDriverStatement<TDrvDataSet, TDrvConnection>; overload;
    function Build(pDelete: ISQLDelete): TDriverStatement<TDrvDataSet, TDrvConnection>; overload;
    function Build(pWhere: ISQLWhere): TDriverStatement<TDrvDataSet, TDrvConnection>; overload;
    function Build(pGroupBy: ISQLGroupBy): TDriverStatement<TDrvDataSet, TDrvConnection>; overload;
    function Build(pHaving: ISQLHaving): TDriverStatement<TDrvDataSet, TDrvConnection>; overload;
    function Build(pOrderBy: ISQLOrderBy): TDriverStatement<TDrvDataSet, TDrvConnection>; overload;
    function Build(const pQuery: string): TDriverStatement<TDrvDataSet, TDrvConnection>; overload;

    procedure Execute(const pAutoCommit: Boolean = False); overload;
    procedure Execute(pDataSet: TDrvDataSet; const pAutoCommit: Boolean = False); overload;

    function AsDataSet(const pFetchRows: Integer = 0): TDrvDataSet;
    function AsIterator(const pFetchRows: Integer = 0): IIteratorDataSet;
    function AsInteger(): Integer;
    function AsFloat(): Double;
    function AsString(): string;
    function AsVariant(): Variant;

    procedure InDataSet(pDataSet: TDrvDataSet);
    procedure InIterator(pIterator: IIteratorDataSet);
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

    procedure Build(pComponent: TDrvComponent); overload;
    procedure Build(pComponent: TDrvComponent; const pOwnsComponent: Boolean); overload;

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
      constructor Create(pObj: TDrvConnection; const pOwnsObj: Boolean);
      destructor Destroy(); override;

      property Obj: TDrvConnection read FObj;
      property OwnsObj: Boolean read FOwnsObj;
    end;
  strict private
    FConnections: TObjectDictionary<TKey, TConnectionProperties>;
    procedure InternalRegisterConnection(pKey: TKey; pConnectionProperties: TConnectionProperties);
    function GetCount: Integer;
  public
    constructor Create();
    destructor Destroy(); override;

    procedure RegisterConnection(pKey: TKey; pConnection: TDrvConnection); overload;
    procedure RegisterConnection(pKey: TKey; pConnectionClass: TDriverClass); overload;

    procedure UnregisterConnection(pKey: TKey);
    procedure UnregisterAllConnections();

    function ConnectionIsRegistered(pKey: TKey): Boolean;

    function GetConnection(pKey: TKey): TDrvConnection;

    property Count: Integer read GetCount;
  end;

  IDriverQueryBuilder<TDrvDataSet: TDataSet> = interface
    ['{EFA518A7-79BE-475D-8991-7A59A8D6685B}']
    function Initialize(pSelect: ISQLSelect): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Initialize(pWhere: ISQLWhere): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Initialize(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Initialize(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Initialize(pHaving: ISQLHaving): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Initialize(const pQuery: string): IDriverQueryBuilder<TDrvDataSet>; overload;

    function Restore(): IDriverQueryBuilder<TDrvDataSet>;

    function Build(pWhere: ISQLWhere): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Build(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Build(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Build(pHaving: ISQLHaving): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Build(const pQuery: string): IDriverQueryBuilder<TDrvDataSet>; overload;

    function Add(pWhere: ISQLWhere): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Add(pGroupBy: ISQLGroupBy): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Add(pOrderBy: ISQLOrderBy): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Add(pHaving: ISQLHaving): IDriverQueryBuilder<TDrvDataSet>; overload;
    function Add(const pQuery: string): IDriverQueryBuilder<TDrvDataSet>; overload;

    procedure Activate;
  end;

  TDriverPersistenceClass = class of TDataModule;

  TDriverBusiness<TDrvPersistence: TDataModule> = class abstract
  strict private
    FPersistence: TDrvPersistence;
    FOwnsPersistence: Boolean;
    procedure InternalCreate(pPersistence: TDrvPersistence; const pOwnsPersistence: Boolean);
    function GetPersistence(): TDrvPersistence;
  strict protected

  public
    constructor Create(); overload;
    constructor Create(pPersistence: TDrvPersistence); overload;
    constructor Create(pPersistence: TDrvPersistence; const pOwnsPersistence: Boolean); overload;
    constructor Create(pPersistence: TDriverPersistenceClass); overload;

    destructor Destroy; override;

    property Persistence: TDrvPersistence read GetPersistence;
  end;

  TBusinessAdapter<TDrvPersistence: TDataModule> = class(TDriverBusiness<TDrvPersistence>);

  IDriverMetaDataInfoAdapter = interface
    ['{100DD476-009C-4D8A-B9DB-8400819CDC41}']
    /// <summary>DataSet Structure</summary>
    /// <remarks>
    /// Column Name	    Data Type	      Description
    /// RECNO	          dtInt32
    /// CATALOG_NAME	  dtWideString	  Catalog name.
    /// SCHEMA_NAME	    dtWideString	  Schema name.
    /// TABLE_NAME	    dtWideString	  Table name.
    /// TABLE_TYPE	    dtInt32	        Table type. Cast value to FireDAC.Phys.Intf.TFDPhysTableKind.
    /// </remarks>
    function GetTables(): IIteratorDataSet;

    /// <summary>DataSet Structure</summary>
    /// <remarks>
    /// Column Name	      Data Type	    Description
    /// RECNO	            dtInt32
    /// CATALOG_NAME	    dtWideString	Catalog name.
    /// SCHEMA_NAME	      dtWideString	Schema name.
    /// TABLE_NAME	      dtWideString	Table name.
    /// COLUMN_NAME	      dtWideString	Column name.
    /// COLUMN_POSITION	  dtInt32	      Column position.
    /// COLUMN_DATATYPE	  dtInt32	      Column data type. Cast value to FireDAC.Stan.Intf.TFDDataType.
    /// COLUMN_TYPENAME	  dtWideString	DBMS native column type name.
    /// COLUMN_ATTRIBUTES	dtUInt32	    Column attributes. Cast value to FireDAC.Stan.Intf.TFDDataAttributes.
    /// COLUMN_PRECISION	dtInt32	      Numeric and date/time column precision.
    /// COLUMN_SCALE	    dtInt32	      Numeric and date/time column scale.
    /// COLUMN_LENGTH	    dtInt32	      Character and byte string column length.
    /// </remarks>
    function GetFields(const pTableName: string): IIteratorDataSet;

    /// <summary>DataSet Structure</summary>
    /// <remarks>
    /// Column Name	        Data Type	      Description
    /// RECNO	              dtInt32
    /// CATALOG_NAME	      dtWideString	  Catalog name.
    /// SCHEMA_NAME	        dtWideString	  Schema name.
    /// TABLE_NAME	        dtWideString	  Table name.
    /// INDEX_NAME	        dtWideString	  Index name.
    /// PKEY_NAME	          dtWideString	  Primary key constraint name.
    /// INDEX_TYPE	        dtInt32	        Index type. Cast value to FireDAC.Phys.Intf.TFDPhysIndexKind.
    /// </remarks>
    function GetPrimaryKey(const pTableName: string): IIteratorDataSet;

    /// <summary>DataSet Structure</summary>
    /// <remarks>
    /// Column Name	        Data Type	      Description
    /// RECNO	              dtInt32
    /// CATALOG_NAME	      dtWideString	  Catalog name.
    /// SCHEMA_NAME	        dtWideString	  Schema name.
    /// TABLE_NAME	        dtWideString	  Table name.
    /// INDEX_NAME	        dtWideString	  Index name.
    /// PKEY_NAME	          dtWideString	  Primary key constraint name.
    /// INDEX_TYPE	        dtInt32	        Index type. Cast value to FireDAC.Phys.Intf.TFDPhysIndexKind.
    /// </remarks>
    function GetIndexes(const pTableName: string): IIteratorDataSet;

    /// <summary>DataSet Structure</summary>
    /// <remarks>
    /// Column Name	      Data Type	      Description
    /// RECNO	            dtInt32
    /// CATALOG_NAME	    dtWideString	  Catalog name.
    /// SCHEMA_NAME	      dtWideString	  Schema name.
    /// TABLE_NAME	      dtWideString	  Table name.
    /// FKEY_NAME	        dtWideString	  Foreign key constraint name.
    /// PKEY_CATALOG_NAME	dtWideString	  Referenced table catalog name.
    /// PKEY_SCHEMA_NAME	dtWideString	  Referenced table schema name.
    /// PKEY_TABLE_NAME	  dtWideString	  Referenced table name.
    /// DELETE_RULE	      dtInt32	        Foreign key delete rule. Cast value to FireDAC.Phys.Intf.TFDPhysCascadeRuleKind.
    /// UPDATE_RULE	      dtInt32	        Foreign key update rule. Cast value to FireDAC.Phys.Intf.TFDPhysCascadeRuleKind.
    /// </remarks>
    function GetForeignKeys(const pTableName: string): IIteratorDataSet;

    /// <summary>DataSet Structure</summary>
    /// <remarks>
    /// Column Name	      Data Type	    Description
    /// RECNO	            dtInt32
    /// CATALOG_NAME	    dtWideString	Catalog name.
    /// SCHEMA_NAME	      dtWideString	Schema name.
    /// GENERATOR_NAME	  dtWideString	Generator / sequence name.
    /// GENERATOR_SCOPE	  dtInt32	      Generator / sequence scope. Cast value to FireDAC.Phys.Intf.TFDPhysObjectScope.
    /// </remarks>
    function GetGenerators(): IIteratorDataSet;

    function TableExists(const pTableName: string): Boolean;
    function FieldExists(const pTableName, pFieldName: string): Boolean;
    function PrimaryKeyExists(const pTableName, pPrimaryKeyName: string): Boolean;
    function IndexExists(const pTableName, pIndexName: string): Boolean;
    function ForeignKeyExists(const pTableName, pForeignKeyName: string): Boolean;
    function GeneratorExists(const pGeneratorName: string): Boolean;
  end;

implementation

uses
  InfraFwk4D;

{ TDriverComponent<TConnection> }

constructor TDriverComponent<TConnection>.Create(pConnection: TConnection);
begin
  FConnection := pConnection;
end;

function TDriverComponent<TConnection>.GetConnection: TConnection;
begin
  Result := FConnection;
end;

{ TDriverStatement<TDrvDataSet, TDrvConnection> }

function TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  pDelete: ISQLDelete): TDriverStatement<TDrvDataSet, TDrvConnection>;
begin
  FQuery := pDelete.ToString;
  Result := Self;
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  pWhere: ISQLWhere): TDriverStatement<TDrvDataSet, TDrvConnection>;
begin
  FQuery := pWhere.ToString;
  Result := Self;
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  pInsert: ISQLInsert): TDriverStatement<TDrvDataSet, TDrvConnection>;
begin
  FQuery := pInsert.ToString;
  Result := Self;
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  pUpdate: ISQLUpdate): TDriverStatement<TDrvDataSet, TDrvConnection>;
begin
  FQuery := pUpdate.ToString;
  Result := Self;
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  pOrderBy: ISQLOrderBy): TDriverStatement<TDrvDataSet, TDrvConnection>;
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
  pSelect: ISQLSelect): TDriverStatement<TDrvDataSet, TDrvConnection>;
begin
  FQuery := pSelect.ToString;
  Result := Self;
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  pGroupBy: ISQLGroupBy): TDriverStatement<TDrvDataSet, TDrvConnection>;
begin
  FQuery := pGroupBy.ToString;
  Result := Self;
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  pHaving: ISQLHaving): TDriverStatement<TDrvDataSet, TDrvConnection>;
begin
  FQuery := pHaving.ToString;
  Result := Self;
end;

constructor TDriverStatement<TDrvDataSet, TDrvConnection>.Create(pConnection: TDrvConnection);
begin
  FConnection := pConnection;
  FQuery := EmptyStr;
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Execute(const pAutoCommit: Boolean);
begin
{$IFDEF VER210}
  DoExecute(FQuery, TDataSet, pAutoCommit);
{$ELSE}
  DoExecute(FQuery, nil, pAutoCommit);
{$ENDIF}
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Execute(pDataSet: TDrvDataSet;
  const pAutoCommit: Boolean);
begin
  DoExecute(FQuery, pDataSet, pAutoCommit);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.GetConnection: TDrvConnection;
begin
  Result := FConnection;
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.InDataSet(pDataSet: TDrvDataSet);
begin
  DoInDataSet(FQuery, pDataSet);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.InIterator(
  pIterator: IIteratorDataSet);
begin
  DoInIterator(FQuery, pIterator);
end;

{ TDriverConnection<TDrvComponent, TDrvStatement> }

procedure TDriverConnection<TDrvComponent, TDrvStatement>.Build(pComponent: TDrvComponent; const pOwnsComponent: Boolean);
begin
  DestroyComponent();
  FComponent := pComponent;
  FOwnsComponent := pOwnsComponent;
  DoAfterBuild();
end;

procedure TDriverConnection<TDrvComponent, TDrvStatement>.Build(pComponent: TDrvComponent);
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
  pObj: TDrvConnection; const pOwnsObj: Boolean);
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
  pKey: TKey): Boolean;
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
  pKey: TKey): TDrvConnection;
begin
  if ConnectionIsRegistered(pKey) then
  begin
    Critical.Section.Enter;
    try
      Result := FConnections.Items[pKey].Obj;
    finally
      Critical.Section.Leave;
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
  pKey: TKey; pConnectionProperties: TConnectionProperties);
begin
  if not ConnectionIsRegistered(pKey) then
  begin
    Critical.Section.Enter;
    try
      FConnections.Add(pKey, pConnectionProperties);
    finally
      Critical.Section.Leave;
    end;
  end
  else
    raise EConnectionAlreadyRegistered.Create('Database already registered!');
end;

procedure TDriverConnectionManager<TKey, TDrvConnection>.RegisterConnection(pKey: TKey;
  pConnection: TDrvConnection);
begin
  InternalRegisterConnection(pKey, TConnectionProperties.Create(pConnection, False));
end;

procedure TDriverConnectionManager<TKey, TDrvConnection>.RegisterConnection(pKey: TKey;
  pConnectionClass: TDriverClass);
begin
  InternalRegisterConnection(pKey, TConnectionProperties.Create(pConnectionClass.Create(), True));
end;

procedure TDriverConnectionManager<TKey, TDrvConnection>.UnregisterAllConnections;
begin
  Critical.Section.Enter;
  try
    FConnections.Clear;
  finally
    Critical.Section.Leave;
  end;
end;

procedure TDriverConnectionManager<TKey, TDrvConnection>.UnregisterConnection(pKey: TKey);
begin
  if ConnectionIsRegistered(pKey) then
  begin
    Critical.Section.Enter;
    try
      FConnections.Remove(pKey);
    finally
      Critical.Section.Leave;
    end;
  end
  else
    raise EConnectionUnregistered.Create('Database connection unregistered!');
end;

{ TDriverBusiness<TDrvPersistence> }

constructor TDriverBusiness<TDrvPersistence>.Create(pPersistence: TDrvPersistence);
begin
  InternalCreate(pPersistence, True);
end;

constructor TDriverBusiness<TDrvPersistence>.Create(
  pPersistence: TDrvPersistence; const pOwnsPersistence: Boolean);
begin
  InternalCreate(pPersistence, pOwnsPersistence);
end;

constructor TDriverBusiness<TDrvPersistence>.Create(pPersistence: TDriverPersistenceClass);
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
  pPersistence: TDrvPersistence; const pOwnsPersistence: Boolean);
begin
  FPersistence := pPersistence;
  FOwnsPersistence := pOwnsPersistence;
end;

constructor TDriverBusiness<TDrvPersistence>.Create;
begin
  InternalCreate(TDriverPersistenceClass(TDrvPersistence).Create(nil), True);
end;

end.
