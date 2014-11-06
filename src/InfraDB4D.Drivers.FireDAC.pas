unit InfraDB4D.Drivers.FireDAC;

interface

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.Generics.Collections,
  InfraDB4D,
  InfraDB4D.Drivers.Base,
  InfraDB4D.Iterator,
  SQLBuilder4D,
  FireDAC.Comp.Client,
  FireDAC.Stan.Option,
  Data.DB;

type

  TFireDACComponentAdapter = class(TDriverComponent<TFDConnection>);

  TFireDACConnectionAdapter = class;

  TFireDACStatementAdapter = class(TDriverStatement<TFDQuery, TFireDACConnectionAdapter>)
  strict protected
    procedure DoInternalBuild(const pSQL: string; const pDataSet: TFDQuery; const pAutoCommit: Boolean = False); override;

    function DoInternalBuildAsDataSet(const pSQL: string; const pFetchRows: Integer): TFDQuery; override;
    procedure DoInternalBuildInDataSet(const pSQL: string; const pDataSet: TFDQuery); override;

    function DoInternalBuildAsInteger(const pSQL: string): Integer; override;
    function DoInternalBuildAsFloat(const pSQL: string): Double; override;
    function DoInternalBuildAsString(const pSQL: string): string; override;
  end;

  TFireDACConnectionAdapter = class(TDriverConnection<TFireDACComponentAdapter, TFireDACStatementAdapter>)
  strict protected
    procedure DoCreateStatement(); override;

    procedure DoConnect(); override;
    procedure DoDisconect(); override;

    function DoInTransaction(): Boolean; override;
    procedure DoStartTransaction(); override;
    procedure DoCommit(); override;
    procedure DoRollback(); override;

    procedure DoAfterBuild(); override;
  end;

  TFireDACSingletonConnectionAdapter = class(TDriverSingletonConnection<TFireDACConnectionAdapter>)
  strict private
    class var SingletonConnectionAdapter: TFireDACConnectionAdapter;
    class constructor Create;
    class destructor Destroy;
  public
    class function Get(): TFireDACConnectionAdapter; static;
  end;

  TFireDACConnectionManagerAdapter = class(TDriverConnectionManager<string, TFireDACConnectionAdapter>);

  TFireDACDetailsAdapter = class;

  TFireDACControllerAdapter = class(TDriverController<TFDQuery, TFireDACConnectionAdapter, TFireDACDetailsAdapter>)
  strict protected
    procedure DoCreateDetails(); override;

    procedure DoChangeSQLTextOfDataSet(); override;
    procedure DoConfigureDataSetConnection(); override;

    function DoGetSQLTextOfDataSet(): string; override;

    procedure DoOpen(); override;
    procedure DoClose(); override;
  end;

  TFireDACDBControllerClass = class of TFireDACControllerAdapter;

  TFireDACDetailsAdapter = class(TDriverDetails<string, TFireDACControllerAdapter>)
  strict protected
    procedure DoOpenAll(); override;
    procedure DoCloseAll(); override;
    procedure DoDisableAllControls(); override;
    procedure DoEnableAllControls(); override;
    procedure DoLinkMasterController(const pDetailController: TFireDACControllerAdapter); override;
    procedure DoLinkMasterDataSource(const pMasterController: TFireDACControllerAdapter); override;
    procedure DoLinkDetailOnMasterDataSource(const pDetail: TFireDACControllerAdapter); override;
  end;

  IFireDACMetaInfoAdapter = interface
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

  TFireDACMetaInfoFactory = class sealed
    class function Get(const pConnection: TFireDACConnectionAdapter): IFireDACMetaInfoAdapter; static;
  end;

implementation

uses
  FireDAC.Phys.Intf;

type

  TFireDACMetaInfoAdapter = class sealed(TInterfacedObject, IFireDACMetaInfoAdapter)
  strict private
    FConnection: TFireDACConnectionAdapter;
    function GetMetaInfo(const pKind: TFDPhysMetaInfoKind; const pObjectName: string = ''): IIteratorDataSet;
  public
    constructor Create(const pConnection: TFireDACConnectionAdapter);

    function GetTables(): IIteratorDataSet;
    function GetFields(const pTableName: string): IIteratorDataSet;
    function GetPrimaryKey(const pTableName: string): IIteratorDataSet;
    function GetIndexes(const pTableName: string): IIteratorDataSet;
    function GetForeignKeys(const pTableName: string): IIteratorDataSet;
    function GetGenerators(): IIteratorDataSet;

    function TableExists(const pTableName: string): Boolean;
    function FieldExists(const pTableName, pFieldName: string): Boolean;
    function PrimaryKeyExists(const pTableName, pPrimaryKeyName: string): Boolean;
    function IndexExists(const pTableName, pIndexName: string): Boolean;
    function ForeignKeyExists(const pTableName, pForeignKeyName: string): Boolean;
    function GeneratorExists(const pGeneratorName: string): Boolean;
  end;

  { TFireDACStatementAdapter }

procedure TFireDACStatementAdapter.DoInternalBuild(const pSQL: string; const pDataSet: TFDQuery; const pAutoCommit: Boolean);
var
  vDataSet: TFDQuery;
begin
  inherited;
  if (pDataSet = nil) then
    vDataSet := TFDQuery.Create(nil)
  else
    vDataSet := pDataSet;
  try
    vDataSet.Close;
    vDataSet.SQL.Clear;
    vDataSet.Connection := GetConnection.GetComponent.GetConnection;
    vDataSet.SQL.Add(pSQL);
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
    if (pDataSet = nil) then
      FreeAndNil(vDataSet);
  end;
end;

function TFireDACStatementAdapter.DoInternalBuildAsDataSet(const pSQL: string;
  const pFetchRows: Integer): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := GetConnection.GetComponent.GetConnection;
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
  Result.SQL.Add(pSQL);
  Result.Prepare;
  Result.Open;
end;

function TFireDACStatementAdapter.DoInternalBuildAsFloat(const pSQL: string): Double;
var
  vDataSet: TFDQuery;
begin
  Result := 0;

  vDataSet := DoInternalBuildAsDataSet(pSQL, 1);
  try
    if not vDataSet.IsEmpty then
      Result := vDataSet.Fields[0].AsFloat;
  finally
    FreeAndNil(vDataSet);
  end;
end;

function TFireDACStatementAdapter.DoInternalBuildAsInteger(const pSQL: string): Integer;
var
  vDataSet: TFDQuery;
begin
  Result := 0;

  vDataSet := DoInternalBuildAsDataSet(pSQL, 1);
  try
    if not vDataSet.IsEmpty then
      Result := vDataSet.Fields[0].AsInteger;
  finally
    FreeAndNil(vDataSet);
  end;
end;

function TFireDACStatementAdapter.DoInternalBuildAsString(const pSQL: string): string;
var
  vDataSet: TFDQuery;
begin
  Result := EmptyStr;

  vDataSet := DoInternalBuildAsDataSet(pSQL, 1);
  try
    if not vDataSet.IsEmpty then
      Result := vDataSet.Fields[0].AsString;
  finally
    FreeAndNil(vDataSet);
  end;
end;

procedure TFireDACStatementAdapter.DoInternalBuildInDataSet(const pSQL: string; const pDataSet: TFDQuery);
begin
  inherited;
  if (pDataSet = nil) then
    raise EDataSetDoesNotExist.Create('DataSet does not exist!');

  pDataSet.Close;
  pDataSet.Connection := GetConnection.GetComponent.GetConnection;
  pDataSet.SQL.Add(pSQL);
  pDataSet.Prepare;
  pDataSet.Open;
end;

{ TFireDACConnectionAdapter }

procedure TFireDACConnectionAdapter.DoAfterBuild;
begin
  inherited;

end;

procedure TFireDACConnectionAdapter.DoCommit;
begin
  inherited;
  GetComponent.GetConnection.Commit();
end;

procedure TFireDACConnectionAdapter.DoConnect;
begin
  inherited;
  GetComponent.GetConnection.Open();
end;

procedure TFireDACConnectionAdapter.DoCreateStatement;
begin
  inherited;
  SetStatement(TFireDACStatementAdapter.Create(Self));
end;

procedure TFireDACConnectionAdapter.DoDisconect;
begin
  inherited;
  GetComponent.GetConnection.Close();
end;

function TFireDACConnectionAdapter.DoInTransaction: Boolean;
begin
  Result := GetComponent.GetConnection.InTransaction;
end;

procedure TFireDACConnectionAdapter.DoRollback;
begin
  inherited;
  GetComponent.GetConnection.Rollback();
end;

procedure TFireDACConnectionAdapter.DoStartTransaction;
begin
  inherited;
  GetComponent.GetConnection.StartTransaction();
end;

{ TFireDACSingletonConnectionAdapter }

class constructor TFireDACSingletonConnectionAdapter.Create;
begin
  SingletonConnectionAdapter := nil;
end;

class destructor TFireDACSingletonConnectionAdapter.Destroy;
begin
  if (SingletonConnectionAdapter <> nil) then
    FreeAndNil(SingletonConnectionAdapter);
end;

class function TFireDACSingletonConnectionAdapter.Get: TFireDACConnectionAdapter;
begin
  if (SingletonConnectionAdapter = nil) then
  begin
    TGlobalCriticalSection.GetInstance.Enter;
    try
      SingletonConnectionAdapter := TFireDACConnectionAdapter.Create;
    finally
      TGlobalCriticalSection.GetInstance.Leave;
    end;
  end;
  Result := SingletonConnectionAdapter;
end;

{ TFireDACControllerAdapter }

procedure TFireDACControllerAdapter.DoChangeSQLTextOfDataSet;
begin
  inherited;
  GetDataSet.SQL.Clear;
  GetDataSet.SQL.Add(GetSQLParserSelect.GetSQLText);
end;

procedure TFireDACControllerAdapter.DoClose;
begin
  inherited;
  GetDataSet.Close();
end;

procedure TFireDACControllerAdapter.DoConfigureDataSetConnection;
begin
  inherited;
  GetDataSet.Connection := GetConnection.GetComponent.GetConnection;
end;

procedure TFireDACControllerAdapter.DoCreateDetails;
begin
  inherited;
  SetDetails(TFireDACDetailsAdapter.Create(Self));
end;

function TFireDACControllerAdapter.DoGetSQLTextOfDataSet: string;
begin
  inherited;
  Result := GetDataSet.SQL.Text;
end;

procedure TFireDACControllerAdapter.DoOpen;
begin
  inherited;
  GetDataSet.Open();
end;

{ TFireDACDetailsAdapter }

procedure TFireDACDetailsAdapter.DoCloseAll;
var
  vPair: TPair<string, TDetailProperties>;
begin
  inherited;
  for vPair in GetDetailDictionary do
  begin
    vPair.Value.Obj.GetDataSet.Close;
    vPair.Value.Obj.GetDetails.CloseAll;
  end;
end;

procedure TFireDACDetailsAdapter.DoDisableAllControls;
var
  vPair: TPair<string, TDetailProperties>;
begin
  inherited;
  for vPair in GetDetailDictionary do
  begin
    vPair.Value.Obj.GetDataSet.DisableControls();
    vPair.Value.Obj.GetDetails.DisableAllControls();
  end;
end;

procedure TFireDACDetailsAdapter.DoEnableAllControls;
var
  vPair: TPair<string, TDetailProperties>;
begin
  inherited;
  for vPair in GetDetailDictionary do
  begin
    vPair.Value.Obj.GetDataSet.EnableControls();
    vPair.Value.Obj.GetDetails.EnableAllControls();
  end;
end;

procedure TFireDACDetailsAdapter.DoLinkDetailOnMasterDataSource(
  const pDetail: TFireDACControllerAdapter);
begin
  inherited;
  pDetail.GetDataSet.MasterSource := GetMasterDataSource();
end;

procedure TFireDACDetailsAdapter.DoLinkMasterController(const pDetailController: TFireDACControllerAdapter);
begin
  inherited;
  pDetailController.SetMaster<TFireDACControllerAdapter>(GetMasterController());
end;

procedure TFireDACDetailsAdapter.DoLinkMasterDataSource(
  const pMasterController: TFireDACControllerAdapter);
begin
  inherited;
  GetMasterDataSource.DataSet := pMasterController.GetDataSet;
end;

procedure TFireDACDetailsAdapter.DoOpenAll;
var
  vPair: TPair<string, TDetailProperties>;
begin
  inherited;
  for vPair in GetDetailDictionary do
  begin
    vPair.Value.Obj.GetDataSet.Open();
    vPair.Value.Obj.GetDetails.OpenAll();
  end;
end;

{ TFireDACMetaInfoAdapter }

constructor TFireDACMetaInfoAdapter.Create(const pConnection: TFireDACConnectionAdapter);
begin
  FConnection := pConnection;
end;

function TFireDACMetaInfoAdapter.GetForeignKeys(const pTableName: string): IIteratorDataSet;
begin
  Result := GetMetaInfo(mkForeignKeys, pTableName);
end;

function TFireDACMetaInfoAdapter.GetGenerators: IIteratorDataSet;
begin
  Result := GetMetaInfo(mkGenerators);
end;

function TFireDACMetaInfoAdapter.GetIndexes(const pTableName: string): IIteratorDataSet;
begin
  Result := GetMetaInfo(mkIndexes, pTableName);
end;

function TFireDACMetaInfoAdapter.GetMetaInfo(const pKind: TFDPhysMetaInfoKind; const pObjectName: string): IIteratorDataSet;
var
  vDataSet: TFDMetaInfoQuery;
begin
  vDataSet := TFDMetaInfoQuery.Create(nil);
  vDataSet.Connection := FConnection.GetComponent.GetConnection;
  vDataSet.MetaInfoKind := pKind;
  vDataSet.ObjectName := pObjectName;
  vDataSet.Open();
  Result := TIteratorDataSetFactory.Get(vDataSet, True);
end;

function TFireDACMetaInfoAdapter.GetPrimaryKey(const pTableName: string): IIteratorDataSet;
begin
  Result := GetMetaInfo(mkPrimaryKey, pTableName);
end;

function TFireDACMetaInfoAdapter.FieldExists(const pTableName, pFieldName: string): Boolean;
var
  vIterator: IIteratorDataSet;
begin
  Result := False;
  vIterator := GetFields(pTableName);
  while vIterator.HasNext do
    if vIterator.FieldByName('COLUMN_NAME').AsString.Equals(pFieldName) then
      Exit(True);
end;

function TFireDACMetaInfoAdapter.ForeignKeyExists(const pTableName, pForeignKeyName: string): Boolean;
var
  vIterator: IIteratorDataSet;
begin
  Result := False;
  vIterator := GetForeignKeys(pTableName);
  while vIterator.HasNext do
    if vIterator.FieldByName('FKEY_NAME').AsString.Equals(pForeignKeyName) then
      Exit(True);
end;

function TFireDACMetaInfoAdapter.GeneratorExists(const pGeneratorName: string): Boolean;
var
  vIterator: IIteratorDataSet;
begin
  Result := False;
  vIterator := GetGenerators();
  while vIterator.HasNext do
    if vIterator.FieldByName('GENERATOR_NAME').AsString.Equals(pGeneratorName) then
      Exit(True);
end;

function TFireDACMetaInfoAdapter.GetFields(const pTableName: string): IIteratorDataSet;
begin
  Result := GetMetaInfo(mkTableFields, pTableName);
end;

function TFireDACMetaInfoAdapter.GetTables: IIteratorDataSet;
begin
  Result := GetMetaInfo(mkTables);
end;

function TFireDACMetaInfoAdapter.IndexExists(const pTableName, pIndexName: string): Boolean;
var
  vIterator: IIteratorDataSet;
begin
  Result := False;
  vIterator := GetIndexes(pTableName);
  while vIterator.HasNext do
    if vIterator.FieldByName('INDEX_NAME').AsString.Equals(pIndexName) then
      Exit(True);
end;

function TFireDACMetaInfoAdapter.PrimaryKeyExists(const pTableName, pPrimaryKeyName: string): Boolean;
var
  vIterator: IIteratorDataSet;
begin
  Result := False;
  vIterator := GetPrimaryKey(pTableName);
  while vIterator.HasNext do
    if vIterator.FieldByName('PKEY_NAME').AsString.Equals(pPrimaryKeyName) then
      Exit(True);
end;

function TFireDACMetaInfoAdapter.TableExists(const pTableName: string): Boolean;
var
  vIterator: IIteratorDataSet;
begin
  Result := False;
  vIterator := GetTables;
  while vIterator.HasNext do
    if vIterator.FieldByName('TABLE_NAME').AsString.Equals(pTableName) then
      Exit(True);
end;

{ TFireDACMetaInfoFactory }

class function TFireDACMetaInfoFactory.Get(const pConnection: TFireDACConnectionAdapter): IFireDACMetaInfoAdapter;
begin
  Result := TFireDACMetaInfoAdapter.Create(pConnection);
end;

end.
