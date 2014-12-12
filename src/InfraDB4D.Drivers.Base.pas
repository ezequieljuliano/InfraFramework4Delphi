unit InfraDB4D.Drivers.Base;

interface

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.Generics.Collections,
  System.TypInfo,
  Data.DB,
  InfraDB4D,
  InfraDB4D.Iterator,
  SQLBuilder4D,
  PropertiesFile4D,
  SQLBuilder4D.Parser;

type

  TDataModuleClass = class of TDataModule;
  TDriverClass = class of TObject;

  TDriverComponent<TConnection: TComponent> = class abstract
  strict private
    FConnection: TConnection;
  public
    constructor Create(const pConnection: TConnection);

    function GetConnection(): TConnection;
  end;

  TDriverStatement<TDrvDataSet: TDataSet; TDrvConnection: class> = class abstract
  strict private
    FConnection: TDrvConnection;
  strict protected
    function GetConnection(): TDrvConnection;

    procedure DoBuild(const pSQL: string; const pDataSet: TDrvDataSet; const pAutoCommit: Boolean = False); virtual; abstract;

    procedure DoBuildInDataSet(const pSQL: string; const pDataSet: TDrvDataSet); virtual; abstract;
    procedure DoBuildInIterator(const pSQL: string; const pIterator: IIterator<TDrvDataSet>); virtual; abstract;

    function DoBuildAsDataSet(const pSQL: string; const pFetchRows: Integer): TDrvDataSet; virtual; abstract;
    function DoBuildAsIteratorDataSet(const pSQL: string): IIteratorDataSet; virtual; abstract;
    function DoBuildAsIterator(const pSQL: string; const pFetchRows: Integer): IIterator<TDrvDataSet>; virtual; abstract;

    function DoBuildAsInteger(const pSQL: string): Integer; virtual; abstract;
    function DoBuildAsFloat(const pSQL: string): Double; virtual; abstract;
    function DoBuildAsString(const pSQL: string): string; virtual; abstract;
  public
    constructor Create(const pConnection: TDrvConnection);

    procedure Build(const pInsert: ISQLInsert; const pAutoCommit: Boolean = False); overload;
    procedure Build(const pUpdate: ISQLUpdate; const pAutoCommit: Boolean = False); overload;
    procedure Build(const pDelete: ISQLDelete; const pAutoCommit: Boolean = False); overload;
    procedure Build(const pSQL: string; const pAutoCommit: Boolean = False); overload;

    procedure Build(const pWhere: ISQLWhere; const pAutoCommit: Boolean = False); overload;
    procedure Build(const pGroupBy: ISQLGroupBy; const pAutoCommit: Boolean = False); overload;
    procedure Build(const pHaving: ISQLHaving; const pAutoCommit: Boolean = False); overload;
    procedure Build(const pOrderBy: ISQLOrderBy; const pAutoCommit: Boolean = False); overload;

    procedure Build(const pInsert: ISQLInsert; const pDataSet: TDrvDataSet; const pAutoCommit: Boolean = False); overload;
    procedure Build(const pUpdate: ISQLUpdate; const pDataSet: TDrvDataSet; const pAutoCommit: Boolean = False); overload;
    procedure Build(const pDelete: ISQLDelete; const pDataSet: TDrvDataSet; const pAutoCommit: Boolean = False); overload;
    procedure Build(const pSQL: string; const pDataSet: TDrvDataSet; const pAutoCommit: Boolean = False); overload;

    procedure Build(const pWhere: ISQLWhere; const pDataSet: TDrvDataSet; const pAutoCommit: Boolean = False); overload;
    procedure Build(const pGroupBy: ISQLGroupBy; const pDataSet: TDrvDataSet; const pAutoCommit: Boolean = False); overload;
    procedure Build(const pHaving: ISQLHaving; const pDataSet: TDrvDataSet; const pAutoCommit: Boolean = False); overload;
    procedure Build(const pOrderBy: ISQLOrderBy; const pDataSet: TDrvDataSet; const pAutoCommit: Boolean = False); overload;

    function BuildAsDataSet(const pSelect: ISQLSelect; const pFetchRows: Integer = 0): TDrvDataSet; overload;
    function BuildAsDataSet(const pWhere: ISQLWhere; const pFetchRows: Integer = 0): TDrvDataSet; overload;
    function BuildAsDataSet(const pGroupBy: ISQLGroupBy; const pFetchRows: Integer = 0): TDrvDataSet; overload;
    function BuildAsDataSet(const pHaving: ISQLHaving; const pFetchRows: Integer = 0): TDrvDataSet; overload;
    function BuildAsDataSet(const pOrderBy: ISQLOrderBy; const pFetchRows: Integer = 0): TDrvDataSet; overload;
    function BuildAsDataSet(const pSQL: string; const pFetchRows: Integer = 0): TDrvDataSet; overload;

    procedure BuildInDataSet(const pSelect: ISQLSelect; const pDataSet: TDrvDataSet); overload;
    procedure BuildInDataSet(const pWhere: ISQLWhere; const pDataSet: TDrvDataSet); overload;
    procedure BuildInDataSet(const pGroupBy: ISQLGroupBy; const pDataSet: TDrvDataSet); overload;
    procedure BuildInDataSet(const pHaving: ISQLHaving; const pDataSet: TDrvDataSet); overload;
    procedure BuildInDataSet(const pOrderBy: ISQLOrderBy; const pDataSet: TDrvDataSet); overload;
    procedure BuildInDataSet(const pSQL: string; const pDataSet: TDrvDataSet); overload;

    procedure BuildInIterator(const pSelect: ISQLSelect; const pIterator: IIterator<TDrvDataSet>); overload;
    procedure BuildInIterator(const pWhere: ISQLWhere; const pIterator: IIterator<TDrvDataSet>); overload;
    procedure BuildInIterator(const pGroupBy: ISQLGroupBy; const pIterator: IIterator<TDrvDataSet>); overload;
    procedure BuildInIterator(const pHaving: ISQLHaving; const pIterator: IIterator<TDrvDataSet>); overload;
    procedure BuildInIterator(const pOrderBy: ISQLOrderBy; const pIterator: IIterator<TDrvDataSet>); overload;
    procedure BuildInIterator(const pSQL: string; const pIterator: IIterator<TDrvDataSet>); overload;

    function BuildAsIterator(const pSelect: ISQLSelect; const pFetchRows: Integer = 0): IIterator<TDrvDataSet>; overload;
    function BuildAsIterator(const pWhere: ISQLWhere; const pFetchRows: Integer = 0): IIterator<TDrvDataSet>; overload;
    function BuildAsIterator(const pGroupBy: ISQLGroupBy; const pFetchRows: Integer = 0): IIterator<TDrvDataSet>; overload;
    function BuildAsIterator(const pHaving: ISQLHaving; const pFetchRows: Integer = 0): IIterator<TDrvDataSet>; overload;
    function BuildAsIterator(const pOrderBy: ISQLOrderBy; const pFetchRows: Integer = 0): IIterator<TDrvDataSet>; overload;
    function BuildAsIterator(const pSQL: string; const pFetchRows: Integer = 0): IIterator<TDrvDataSet>; overload;

    function BuildAsIteratorDataSet(const pSelect: ISQLSelect): IIteratorDataSet; overload;
    function BuildAsIteratorDataSet(const pWhere: ISQLWhere): IIteratorDataSet; overload;
    function BuildAsIteratorDataSet(const pGroupBy: ISQLGroupBy): IIteratorDataSet; overload;
    function BuildAsIteratorDataSet(const pHaving: ISQLHaving): IIteratorDataSet; overload;
    function BuildAsIteratorDataSet(const pOrderBy: ISQLOrderBy): IIteratorDataSet; overload;
    function BuildAsIteratorDataSet(const pSQL: string): IIteratorDataSet; overload;

    function BuildAsInteger(const pSelect: ISQLSelect): Integer; overload;
    function BuildAsInteger(const pWhere: ISQLWhere): Integer; overload;
    function BuildAsInteger(const pGroupBy: ISQLGroupBy): Integer; overload;
    function BuildAsInteger(const pHaving: ISQLHaving): Integer; overload;
    function BuildAsInteger(const pOrderBy: ISQLOrderBy): Integer; overload;
    function BuildAsInteger(const pSQL: string): Integer; overload;

    function BuildAsFloat(const pSelect: ISQLSelect): Double; overload;
    function BuildAsFloat(const pWhere: ISQLWhere): Double; overload;
    function BuildAsFloat(const pGroupBy: ISQLGroupBy): Double; overload;
    function BuildAsFloat(const pHaving: ISQLHaving): Double; overload;
    function BuildAsFloat(const pOrderBy: ISQLOrderBy): Double; overload;
    function BuildAsFloat(const pSQL: string): Double; overload;

    function BuildAsString(const pSelect: ISQLSelect): string; overload;
    function BuildAsString(const pWhere: ISQLWhere): string; overload;
    function BuildAsString(const pGroupBy: ISQLGroupBy): string; overload;
    function BuildAsString(const pHaving: ISQLHaving): string; overload;
    function BuildAsString(const pOrderBy: ISQLOrderBy): string; overload;
    function BuildAsString(const pSQL: string): string; overload;
  end;

  TDriverConnection<TDrvComponent, TDrvStatement: class> = class abstract
  strict private
    FComponent: TDrvComponent;
    FAutoDestroyComponent: Boolean;
    FStatement: TDrvStatement;
    procedure DestroyComponent();
  strict protected
    procedure SetStatement(const pStatement: TDrvStatement);
    procedure DoCreateStatement(); virtual; abstract;

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

    function GetComponent(): TDrvComponent;
    function GetStatement(): TDrvStatement;

    procedure Connect();
    procedure Disconect();

    function InTransaction(): Boolean;
    procedure StartTransaction();
    procedure Commit();
    procedure Rollback();

    procedure Build(const pComponent: TDrvComponent; const pAutoDestroyComponent: Boolean = True);
  end;

  TDriverSingletonConnection<TDrvConnection: class> = class abstract

  end;

  TDriverConnectionManager<TKey; TDrvConnection: class> = class abstract
  strict private
  type
    TConnectionProperties = class
    strict private
      FObj: TDrvConnection;
      FAutoDestroy: Boolean;
    public
      constructor Create(const pObj: TDrvConnection; const pAutoDestroy: Boolean);
      destructor Destroy(); override;

      property Obj: TDrvConnection read FObj;
      property AutoDestroy: Boolean write FAutoDestroy;
    end;
  strict private
    FConnections: TObjectDictionary<TKey, TConnectionProperties>;
    procedure InternalRegisterConnection(const pKey: TKey; pConnectionProperties: TConnectionProperties);
  public
    constructor Create();
    destructor Destroy(); override;

    function GetCount: Integer;

    procedure RegisterConnection(const pKey: TKey; const pConnection: TDrvConnection); overload;
    procedure RegisterConnection(const pKey: TKey; const pConnectionClass: TDriverClass); overload;
    procedure UnregisterConnection(const pKey: TKey);
    procedure UnregisterAllConnections();
    function ConnectionIsRegistered(const pKey: TKey): Boolean;
    function GetConnection(const pKey: TKey): TDrvConnection;

    property Count: Integer read GetCount;
  end;

  TDriverController<TDrvDataSet: TDataSet; TDrvConnection, TDrvDetails: class> = class abstract
  strict private
    FConnection: TDrvConnection;
    FDataSet: TDrvDataSet;
    FModel: TDataModule;
    FMaster: TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>;
    FModelDestroy: Boolean;
    FSQLInitial: string;
    FSQLParserSelect: ISQLParserSelect;
    FDetails: TDrvDetails;
    procedure InternalCreate();
    function FindDataSetOnModel(const pDataSetName: string): TDrvDataSet;
  strict protected
    procedure SetDetails(const pDBDetails: TDrvDetails);
    procedure SetModel(const pModel: TDataModule);

    function GetSQLInitial(): string;
    function GetSQLParserSelect(): ISQLParserSelect;

    procedure DoCreateDetails(); virtual; abstract;

    procedure DoChangeSQLTextOfDataSet(); virtual; abstract;
    procedure DoConfigureDataSetConnection(); virtual; abstract;

    function DoGetSQLTextOfDataSet(): string; virtual; abstract;

    procedure DoOpen(); virtual; abstract;
    procedure DoClose(); virtual; abstract;
  public
    constructor Create(const pConnection: TDrvConnection; const pModel: TDataModule; const pDataSet: TDrvDataSet); overload;
    constructor Create(const pConnection: TDrvConnection; const pModel: TDataModule; const pDataSetName: string); overload;
    constructor Create(const pConnection: TDrvConnection; const pModelClass: TDataModuleClass; const pDataSetName: string); overload;

    destructor Destroy(); override;

    function GetConnection(): TDrvConnection;
    function GetDetails(): TDrvDetails;
    function GetDataSet(): TDrvDataSet;

    function GetModel<T: TDataModule>(): T;

    function GetMaster<T: class>(): T;
    procedure SetMaster<T: class>(const pMaster: T);

    procedure SQLInitialize(const pSQL: string);
    procedure SQLBuild(const pWhere: ISQLWhere; const pOpen: Boolean = True); overload;
    procedure SQLBuild(const pGroupBy: ISQLGroupBy; const pOpen: Boolean = True); overload;
    procedure SQLBuild(const pOrderBy: ISQLOrderBy; const pOpen: Boolean = True); overload;
    procedure SQLBuild(const pHaving: ISQLHaving; const pOpen: Boolean = True); overload;
    procedure SQLRestore(const pOpen: Boolean = True);
  end;

  TDriverDetails<TKey; TDrvController: class> = class abstract
  strict protected
  type
    TDetailProperties = class
    strict private
      FObj: TDrvController;
      FAutoDestroy: Boolean;
    public
      constructor Create(const pObj: TDrvController; const pAutoDestroy: Boolean);
      destructor Destroy(); override;

      property Obj: TDrvController read FObj;
      property AutoDestroy: Boolean write FAutoDestroy;
    end;
  strict private
    FDetails: TObjectDictionary<TKey, TDetailProperties>;
    FMasterController: TDrvController;
    FMasterDataSource: TDataSource;
  strict protected
    function GetMasterController(): TDrvController;
    function GetMasterDataSource(): TDataSource;
    function GetDetailDictionary(): TDictionary<TKey, TDetailProperties>;

    procedure DoOpenAll(); virtual; abstract;
    procedure DoCloseAll(); virtual; abstract;
    procedure DoDisableAllControls(); virtual; abstract;
    procedure DoEnableAllControls(); virtual; abstract;
    procedure DoLinkMasterController(const pDetailController: TDrvController); virtual; abstract;
    procedure DoLinkMasterDataSource(const pMasterController: TDrvController); virtual; abstract;
    procedure DoLinkDetailOnMasterDataSource(const pDetail: TDrvController); virtual; abstract;
  public
    constructor Create(const pMasterController: TDrvController);
    destructor Destroy(); override;

    function GetCount: Integer;

    procedure RegisterDetail(const pKey: TKey; const pDetail: TDrvController; const pAutoDestroyDetail: Boolean = True);
    procedure UnregisterDetail(const pKey: TKey);
    procedure UnregisterAllDetails();
    function DetailIsRegistered(const pKey: TKey): Boolean;
    function GetDetail(const pKey: TKey): TDrvController;
    function GetDetailAs<T: class>(const pKey: TKey): T;
    function GetDetailByClass<T: class>(): T;

    procedure OpenAll();
    procedure CloseAll();
    procedure DisableAllControls();
    procedure EnableAllControls();

    property Count: Integer read GetCount;
  end;

implementation

{ TDriverStatement<TDataSet, TDBConnection> }

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pDelete: ISQLDelete; const pAutoCommit: Boolean);
begin
  DoBuild(pDelete.ToString, nil, pAutoCommit);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pWhere: ISQLWhere; const pAutoCommit: Boolean);
begin
  DoBuild(pWhere.ToString, nil, pAutoCommit);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pInsert: ISQLInsert; const pAutoCommit: Boolean);
begin
  DoBuild(pInsert.ToString, nil, pAutoCommit);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pUpdate: ISQLUpdate; const pAutoCommit: Boolean);
begin
  DoBuild(pUpdate.ToString, nil, pAutoCommit);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pOrderBy: ISQLOrderBy; const pAutoCommit: Boolean);
begin
  DoBuild(pOrderBy.ToString, nil, pAutoCommit);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pUpdate: ISQLUpdate; const pDataSet: TDrvDataSet;
  const pAutoCommit: Boolean);
begin
  DoBuild(pUpdate.ToString, pDataSet, pAutoCommit);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pInsert: ISQLInsert; const pDataSet: TDrvDataSet;
  const pAutoCommit: Boolean);
begin
  DoBuild(pInsert.ToString, pDataSet, pAutoCommit);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Build(const pSQL: string;
  const pDataSet: TDrvDataSet; const pAutoCommit: Boolean);
begin
  DoBuild(pSQL, pDataSet, pAutoCommit);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pDelete: ISQLDelete; const pDataSet: TDrvDataSet;
  const pAutoCommit: Boolean);
begin
  DoBuild(pDelete.ToString, pDataSet, pAutoCommit);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pSQL: string; const pAutoCommit: Boolean);
begin
  DoBuild(pSQL, nil, pAutoCommit);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pHaving: ISQLHaving; const pAutoCommit: Boolean);
begin
  DoBuild(pHaving.ToString, nil, pAutoCommit);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pGroupBy: ISQLGroupBy; const pAutoCommit: Boolean);
begin
  DoBuild(pGroupBy.ToString, nil, pAutoCommit);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pGroupBy: ISQLGroupBy; const pDataSet: TDrvDataSet;
  const pAutoCommit: Boolean);
begin
  DoBuild(pGroupBy.ToString, pDataSet, pAutoCommit);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pWhere: ISQLWhere; const pDataSet: TDrvDataSet;
  const pAutoCommit: Boolean);
begin
  DoBuild(pWhere.ToString, pDataSet, pAutoCommit);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pOrderBy: ISQLOrderBy; const pDataSet: TDrvDataSet;
  const pAutoCommit: Boolean);
begin
  DoBuild(pOrderBy.ToString, pDataSet, pAutoCommit);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.Build(
  const pHaving: ISQLHaving; const pDataSet: TDrvDataSet;
  const pAutoCommit: Boolean);
begin
  DoBuild(pHaving.ToString, pDataSet, pAutoCommit);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsDataSet(
  const pHaving: ISQLHaving; const pFetchRows: Integer): TDrvDataSet;
begin
  Result := DoBuildAsDataSet(pHaving.ToString, pFetchRows);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsDataSet(
  const pGroupBy: ISQLGroupBy; const pFetchRows: Integer): TDrvDataSet;
begin
  Result := DoBuildAsDataSet(pGroupBy.ToString, pFetchRows);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsDataSet(
  const pWhere: ISQLWhere; const pFetchRows: Integer): TDrvDataSet;
begin
  Result := DoBuildAsDataSet(pWhere.ToString, pFetchRows);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsDataSet(
  const pSelect: ISQLSelect; const pFetchRows: Integer): TDrvDataSet;
begin
  Result := DoBuildAsDataSet(pSelect.ToString, pFetchRows);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsDataSet(
  const pOrderBy: ISQLOrderBy; const pFetchRows: Integer): TDrvDataSet;
begin
  Result := DoBuildAsDataSet(pOrderBy.ToString, pFetchRows);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsFloat(
  const pWhere: ISQLWhere): Double;
begin
  Result := DoBuildAsFloat(pWhere.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsFloat(
  const pSelect: ISQLSelect): Double;
begin
  Result := DoBuildAsFloat(pSelect.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsFloat(
  const pGroupBy: ISQLGroupBy): Double;
begin
  Result := DoBuildAsFloat(pGroupBy.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsDataSet(
  const pSQL: string; const pFetchRows: Integer): TDrvDataSet;
begin
  Result := DoBuildAsDataSet(pSQL, pFetchRows);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsFloat(
  const pOrderBy: ISQLOrderBy): Double;
begin
  Result := DoBuildAsFloat(pOrderBy.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsFloat(
  const pSQL: string): Double;
begin
  Result := DoBuildAsFloat(pSQL);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsFloat(
  const pHaving: ISQLHaving): Double;
begin
  Result := DoBuildAsFloat(pHaving.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsInteger(
  const pWhere: ISQLWhere): Integer;
begin
  Result := DoBuildAsInteger(pWhere.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsInteger(
  const pSelect: ISQLSelect): Integer;
begin
  Result := DoBuildAsInteger(pSelect.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsInteger(
  const pGroupBy: ISQLGroupBy): Integer;
begin
  Result := DoBuildAsInteger(pGroupBy.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsInteger(
  const pOrderBy: ISQLOrderBy): Integer;
begin
  Result := DoBuildAsInteger(pOrderBy.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsInteger(
  const pSQL: string): Integer;
begin
  Result := DoBuildAsInteger(pSQL);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsIterator(const pGroupBy: ISQLGroupBy;
  const pFetchRows: Integer): IIterator<TDrvDataSet>;
begin
  Result := DoBuildAsIterator(pGroupBy.ToString, pFetchRows);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsIterator(const pWhere: ISQLWhere;
  const pFetchRows: Integer): IIterator<TDrvDataSet>;
begin
  Result := DoBuildAsIterator(pWhere.ToString, pFetchRows);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsIterator(const pSelect: ISQLSelect;
  const pFetchRows: Integer): IIterator<TDrvDataSet>;
begin
  Result := DoBuildAsIterator(pSelect.ToString, pFetchRows);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsIterator(const pSQL: string;
  const pFetchRows: Integer): IIterator<TDrvDataSet>;
begin
  Result := DoBuildAsIterator(pSQL, pFetchRows);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsIterator(const pOrderBy: ISQLOrderBy;
  const pFetchRows: Integer): IIterator<TDrvDataSet>;
begin
  Result := DoBuildAsIterator(pOrderBy.ToString, pFetchRows);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsIterator(const pHaving: ISQLHaving;
  const pFetchRows: Integer): IIterator<TDrvDataSet>;
begin
  Result := DoBuildAsIterator(pHaving.ToString, pFetchRows);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsIteratorDataSet(
  const pGroupBy: ISQLGroupBy): IIteratorDataSet;
begin
  Result := DoBuildAsIteratorDataSet(pGroupBy.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsIteratorDataSet(const pWhere: ISQLWhere): IIteratorDataSet;
begin
  Result := DoBuildAsIteratorDataSet(pWhere.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsIteratorDataSet(
  const pSelect: ISQLSelect): IIteratorDataSet;
begin
  Result := DoBuildAsIteratorDataSet(pSelect.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsIteratorDataSet(const pSQL: string): IIteratorDataSet;
begin
  Result := DoBuildAsIteratorDataSet(pSQL);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsIteratorDataSet(
  const pOrderBy: ISQLOrderBy): IIteratorDataSet;
begin
  Result := DoBuildAsIteratorDataSet(pOrderBy.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsIteratorDataSet(
  const pHaving: ISQLHaving): IIteratorDataSet;
begin
  Result := DoBuildAsIteratorDataSet(pHaving.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsString(
  const pWhere: ISQLWhere): string;
begin
  Result := DoBuildAsString(pWhere.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsString(
  const pSelect: ISQLSelect): string;
begin
  Result := DoBuildAsString(pSelect.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsString(
  const pGroupBy: ISQLGroupBy): string;
begin
  Result := DoBuildAsString(pGroupBy.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsString(
  const pOrderBy: ISQLOrderBy): string;
begin
  Result := DoBuildAsString(pOrderBy.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsString(
  const pSQL: string): string;
begin
  Result := DoBuildAsString(pSQL);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.BuildInDataSet(
  const pWhere: ISQLWhere; const pDataSet: TDrvDataSet);
begin
  DoBuildInDataSet(pWhere.ToString, pDataSet);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.BuildInDataSet(
  const pSelect: ISQLSelect; const pDataSet: TDrvDataSet);
begin
  DoBuildInDataSet(pSelect.ToString, pDataSet);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.BuildInDataSet(
  const pGroupBy: ISQLGroupBy; const pDataSet: TDrvDataSet);
begin
  DoBuildInDataSet(pGroupBy.ToString, pDataSet);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.BuildInDataSet(
  const pOrderBy: ISQLOrderBy; const pDataSet: TDrvDataSet);
begin
  DoBuildInDataSet(pOrderBy.ToString, pDataSet);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.BuildInDataSet(
  const pSQL: string; const pDataSet: TDrvDataSet);
begin
  DoBuildInDataSet(pSQL, pDataSet);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.BuildInIterator(const pGroupBy: ISQLGroupBy;
  const pIterator: IIterator<TDrvDataSet>);
begin
  DoBuildInIterator(pGroupBy.ToString, pIterator);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.BuildInIterator(const pWhere: ISQLWhere;
  const pIterator: IIterator<TDrvDataSet>);
begin
  DoBuildInIterator(pWhere.ToString, pIterator);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.BuildInIterator(const pSelect: ISQLSelect;
  const pIterator: IIterator<TDrvDataSet>);
begin
  DoBuildInIterator(pSelect.ToString, pIterator);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.BuildInIterator(const pSQL: string;
  const pIterator: IIterator<TDrvDataSet>);
begin
  DoBuildInIterator(pSQL, pIterator);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.BuildInIterator(const pOrderBy: ISQLOrderBy;
  const pIterator: IIterator<TDrvDataSet>);
begin
  DoBuildInIterator(pOrderBy.ToString, pIterator);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.BuildInIterator(const pHaving: ISQLHaving;
  const pIterator: IIterator<TDrvDataSet>);
begin
  DoBuildInIterator(pHaving.ToString, pIterator);
end;

procedure TDriverStatement<TDrvDataSet, TDrvConnection>.BuildInDataSet(
  const pHaving: ISQLHaving; const pDataSet: TDrvDataSet);
begin
  DoBuildInDataSet(pHaving.ToString, pDataSet);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsString(
  const pHaving: ISQLHaving): string;
begin
  Result := DoBuildAsString(pHaving.ToString);
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.BuildAsInteger(
  const pHaving: ISQLHaving): Integer;
begin
  Result := DoBuildAsInteger(pHaving.ToString);
end;

constructor TDriverStatement<TDrvDataSet, TDrvConnection>.Create(
  const pConnection: TDrvConnection);
begin
  FConnection := pConnection;
end;

function TDriverStatement<TDrvDataSet, TDrvConnection>.GetConnection: TDrvConnection;
begin
  Result := FConnection;
end;

{ TDriverComponent<TConnection> }

constructor TDriverComponent<TConnection>.Create(
  const pConnection: TConnection);
begin
  FConnection := pConnection;
end;

function TDriverComponent<TConnection>.GetConnection: TConnection;
begin
  Result := FConnection;
end;

{ TDriverConnection<TDrvComponent, TDrvStatement> }

procedure TDriverConnection<TDrvComponent, TDrvStatement>.Build(
  const pComponent: TDrvComponent; const pAutoDestroyComponent: Boolean);
begin
  DestroyComponent();
  FComponent := pComponent;
  FAutoDestroyComponent := pAutoDestroyComponent;
  DoAfterBuild();
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
  FAutoDestroyComponent := False;
  DoCreateStatement();
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
  if (FAutoDestroyComponent) and (FComponent <> nil) then
    FreeAndNil(FComponent);
end;

procedure TDriverConnection<TDrvComponent, TDrvStatement>.Disconect;
begin
  DoDisconect();
end;

function TDriverConnection<TDrvComponent, TDrvStatement>.GetComponent: TDrvComponent;
begin
  if (FComponent = nil) then
    raise EComponentDoesNotExist.Create('DBComponent does not exist!');

  Result := FComponent;
end;

function TDriverConnection<TDrvComponent, TDrvStatement>.GetStatement: TDrvStatement;
begin
  if (FStatement = nil) then
    raise EStatementDoesNotExist.Create('DBStatement does not exist!');

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

procedure TDriverConnection<TDrvComponent, TDrvStatement>.SetStatement(
  const pStatement: TDrvStatement);
begin
  FStatement := pStatement;
end;

procedure TDriverConnection<TDrvComponent, TDrvStatement>.StartTransaction;
begin
  DoStartTransaction();
end;

{ TDriverConnectionManager<TKey, TDrvConnection> }

constructor TDriverConnectionManager<TKey, TDrvConnection>.Create;
begin
  FConnections := TObjectDictionary<TKey, TConnectionProperties>.Create([doOwnsValues]);
end;

function TDriverConnectionManager<TKey, TDrvConnection>.ConnectionIsRegistered(
  const pKey: TKey): Boolean;
begin
  Result := FConnections.ContainsKey(pKey);
end;

destructor TDriverConnectionManager<TKey, TDrvConnection>.Destroy;
begin
  UnregisterAllConnections();
  FreeAndNil(FConnections);
  inherited Destroy();
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
    TGlobalCriticalSection.GetInstance.Enter;
    try
      FConnections.Add(pKey, pConnectionProperties);
    finally
      TGlobalCriticalSection.GetInstance.Leave;
    end;
  end
  else
    raise EConnectionAlreadyRegistered.Create('Database already registered!');
end;

procedure TDriverConnectionManager<TKey, TDrvConnection>.RegisterConnection(
  const pKey: TKey; const pConnectionClass: TDriverClass);
begin
  InternalRegisterConnection(pKey, TConnectionProperties.Create(pConnectionClass.Create(), True));
end;

function TDriverConnectionManager<TKey, TDrvConnection>.GetConnection(
  const pKey: TKey): TDrvConnection;
begin
  if ConnectionIsRegistered(pKey) then
  begin
    TGlobalCriticalSection.GetInstance.Enter;
    try
      Result := FConnections.Items[pKey].Obj;
    finally
      TGlobalCriticalSection.GetInstance.Leave;
    end;
  end
  else
    raise EConnectionUnregistered.Create('Database connection unregistered!');
end;

procedure TDriverConnectionManager<TKey, TDrvConnection>.RegisterConnection(
  const pKey: TKey; const pConnection: TDrvConnection);
begin
  InternalRegisterConnection(pKey, TConnectionProperties.Create(pConnection, False));
end;

procedure TDriverConnectionManager<TKey, TDrvConnection>.UnregisterAllConnections;
begin
  TGlobalCriticalSection.GetInstance.Enter;
  try
    FConnections.Clear;
  finally
    TGlobalCriticalSection.GetInstance.Leave;
  end;
end;

procedure TDriverConnectionManager<TKey, TDrvConnection>.UnregisterConnection(
  const pKey: TKey);
begin
  if ConnectionIsRegistered(pKey) then
  begin
    TGlobalCriticalSection.GetInstance.Enter;
    try
      FConnections.Remove(pKey);
    finally
      TGlobalCriticalSection.GetInstance.Leave;
    end;
  end
  else
    raise EConnectionUnregistered.Create('Database connection unregistered!');
end;

{ TDriverController<TDataSet, TDrvConnection, TDrvDetails> }

constructor TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.Create(
  const pConnection: TDrvConnection; const pModel: TDataModule;
  const pDataSet: TDrvDataSet);
begin
  FConnection := pConnection;
  FModelDestroy := False;
  FModel := pModel;
  FDataSet := pDataSet;
  InternalCreate();
end;

constructor TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.Create(
  const pConnection: TDrvConnection; const pModel: TDataModule;
  const pDataSetName: string);
begin
  FConnection := pConnection;
  FModelDestroy := False;
  FModel := pModel;
  FDataSet := FindDataSetOnModel(pDataSetName);
  InternalCreate();
end;

constructor TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.Create(
  const pConnection: TDrvConnection; const pModelClass: TDataModuleClass;
  const pDataSetName: string);
begin
  FConnection := pConnection;
  FModelDestroy := True;
  FModel := pModelClass.Create(nil);
  FDataSet := FindDataSetOnModel(pDataSetName);
  InternalCreate();
end;

destructor TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.Destroy;
begin
  if (FDetails <> nil) then
    FreeAndNil(FDetails);

  if FModelDestroy then
    FreeAndNil(FModel);
  inherited Destroy();
end;

function TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.FindDataSetOnModel(const pDataSetName: string): TDrvDataSet;
begin
  Result := nil;

  if (FModel = nil) then
    raise EModelDoesNotExist.Create('Model does not exist!');

  Result := TDrvDataSet(FModel.FindComponent(pDataSetName));

  if (Result = nil) then
    raise EDataSetDoesNotExist.Create('DataSet does not exist!');
end;

function TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.GetDataSet: TDrvDataSet;
begin
  if (FDataSet = nil) then
    raise EDataSetDoesNotExist.Create('DataSet does not exist!');

  Result := FDataSet;
end;

function TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.GetConnection: TDrvConnection;
begin
  if (FConnection = nil) then
    raise EConnectionDoesNotExist.Create('Connection does not exist!');

  Result := FConnection;
end;

function TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.GetDetails: TDrvDetails;
begin
  if (FDetails = nil) then
    raise EDetailUnregistered.Create('Details unregistered!');

  Result := FDetails;
end;

function TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.GetMaster<T>: T;
begin
  if (FMaster = nil) then
    raise EMasterDoesNotExist.Create('Master Controller does not exist!');

  Result := T(FMaster);
end;

function TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.GetModel<T>: T;
begin
  if (FModel = nil) then
    raise EModelDoesNotExist.Create('Model does not exist!');

  Result := T(FModel);
end;

function TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.GetSQLInitial: string;
begin
  Result := FSQLInitial;
end;

function TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.GetSQLParserSelect: ISQLParserSelect;
begin
  Result := FSQLParserSelect;
end;

procedure TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.InternalCreate;
begin
  FMaster := nil;
  FSQLParserSelect := TSQLParserFactory.GetSelectInstance(prGaSQLParser);
  SQLInitialize(DoGetSQLTextOfDataSet);
  DoConfigureDataSetConnection();
  DoCreateDetails();
end;

procedure TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.SetDetails(
  const pDBDetails: TDrvDetails);
begin
  FDetails := pDBDetails;
end;

procedure TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.SetMaster<T>(const pMaster: T);
begin
  if not(pMaster is TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>) then
    raise EMasterDoesNotCompatible.Create('Master Controller does not compatible!');

  FMaster := TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>(pMaster);
end;

procedure TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.SetModel(
  const pModel: TDataModule);
begin
  FModel := pModel;
end;

procedure TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.SQLBuild(
  const pGroupBy: ISQLGroupBy; const pOpen: Boolean);
begin
  DoClose();
  FSQLParserSelect.AddOrSetGroupBy(pGroupBy.ToString);
  DoChangeSQLTextOfDataSet();
  if pOpen then
    DoOpen();
end;

procedure TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.SQLBuild(
  const pWhere: ISQLWhere; const pOpen: Boolean);
begin
  DoClose();
  FSQLParserSelect.AddOrSetWhere(pWhere.ToString);
  DoChangeSQLTextOfDataSet();
  if pOpen then
    DoOpen();
end;

procedure TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.SQLBuild(
  const pOrderBy: ISQLOrderBy; const pOpen: Boolean);
begin
  DoClose();
  FSQLParserSelect.AddOrSetOrderBy(pOrderBy.ToString);
  DoChangeSQLTextOfDataSet();
  if pOpen then
    DoOpen();
end;

procedure TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.SQLBuild(
  const pHaving: ISQLHaving; const pOpen: Boolean);
begin
  DoClose();
  FSQLParserSelect.AddOrSetHaving(pHaving.ToString);
  DoChangeSQLTextOfDataSet();
  if pOpen then
    DoOpen();
end;

procedure TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.SQLInitialize(
  const pSQL: string);
begin
  if (Trim(pSQL) <> EmptyStr) then
  begin
    DoClose();
    FSQLInitial := pSQL;
    FSQLParserSelect.Parse(FSQLInitial);
    DoChangeSQLTextOfDataSet();
  end;
end;

procedure TDriverController<TDrvDataSet, TDrvConnection, TDrvDetails>.SQLRestore(
  const pOpen: Boolean);
begin
  DoClose();
  FSQLParserSelect.Parse(FSQLInitial);
  DoChangeSQLTextOfDataSet();
  if pOpen then
    DoOpen();
end;

{ TDriverDetails<TKey, TDrvController> }

procedure TDriverDetails<TKey, TDrvController>.CloseAll;
begin
  DoCloseAll();
end;

constructor TDriverDetails<TKey, TDrvController>.Create(
  const pMasterController: TDrvController);
begin
  FDetails := TObjectDictionary<TKey, TDetailProperties>.Create([doOwnsValues]);;
  FMasterController := pMasterController;
  FMasterDataSource := TDataSource.Create(nil);
  DoLinkMasterDataSource(FMasterController);
end;

function TDriverDetails<TKey, TDrvController>.DetailIsRegistered(
  const pKey: TKey): Boolean;
begin
  Result := FDetails.ContainsKey(pKey);
end;

destructor TDriverDetails<TKey, TDrvController>.Destroy;
begin
  UnregisterAllDetails();
  FreeAndNil(FDetails);
  FreeAndNil(FMasterDataSource);
  inherited Destroy();
end;

procedure TDriverDetails<TKey, TDrvController>.DisableAllControls;
begin
  DoDisableAllControls();
end;

procedure TDriverDetails<TKey, TDrvController>.EnableAllControls;
begin
  DoEnableAllControls();
end;

function TDriverDetails<TKey, TDrvController>.GetCount: Integer;
begin
  Result := FDetails.Count;
end;

function TDriverDetails<TKey, TDrvController>.GetMasterController: TDrvController;
begin
  Result := FMasterController;
end;

function TDriverDetails<TKey, TDrvController>.GetMasterDataSource: TDataSource;
begin
  Result := FMasterDataSource;
end;

function TDriverDetails<TKey, TDrvController>.GetDetail(
  const pKey: TKey): TDrvController;
begin
  if DetailIsRegistered(pKey) then
    Result := FDetails.Items[pKey].Obj
  else
    raise EDetailUnregistered.Create('Detail unregistered!');
end;

function TDriverDetails<TKey, TDrvController>.GetDetailAs<T>(
  const pKey: TKey): T;
begin
  Result := (GetDetail(pKey) as T);
end;

function TDriverDetails<TKey, TDrvController>.GetDetailByClass<T>: T;
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

function TDriverDetails<TKey, TDrvController>.GetDetailDictionary: TDictionary<TKey, TDetailProperties>;
begin
  Result := FDetails;
end;

procedure TDriverDetails<TKey, TDrvController>.OpenAll;
begin
  DoOpenAll();
end;

procedure TDriverDetails<TKey, TDrvController>.RegisterDetail(
  const pKey: TKey; const pDetail: TDrvController; const pAutoDestroyDetail: Boolean);
begin
  if not DetailIsRegistered(pKey) then
  begin
    FDetails.Add(pKey, TDetailProperties.Create(pDetail, pAutoDestroyDetail));
    DoLinkMasterController(pDetail);
    DoLinkDetailOnMasterDataSource(pDetail);
  end
  else
    raise EDetailAlreadyRegistered.Create('Detail already registered!');
end;

procedure TDriverDetails<TKey, TDrvController>.UnregisterAllDetails;
begin
  FDetails.Clear;
end;

procedure TDriverDetails<TKey, TDrvController>.UnregisterDetail(
  const pKey: TKey);
begin
  if DetailIsRegistered(pKey) then
    FDetails.Remove(pKey)
  else
    raise EDetailUnregistered.Create('Detail unregistered!');
end;

{ TDriverConnectionManager<TKey, TDrvConnection>.TConnectionProperties }

constructor TDriverConnectionManager<TKey, TDrvConnection>.TConnectionProperties.Create(
  const pObj: TDrvConnection; const pAutoDestroy: Boolean);
begin
  FObj := pObj;
  FAutoDestroy := pAutoDestroy;
end;

destructor TDriverConnectionManager<TKey, TDrvConnection>.TConnectionProperties.Destroy;
begin
  if (FAutoDestroy) then
    FreeAndNil(FObj);
  inherited Destroy();
end;

{ TDriverDetails<TKey, TDrvController>.TDetailProperties }

constructor TDriverDetails<TKey, TDrvController>.TDetailProperties.Create(
  const pObj: TDrvController; const pAutoDestroy: Boolean);
begin
  FObj := pObj;
  FAutoDestroy := pAutoDestroy;
end;

destructor TDriverDetails<TKey, TDrvController>.TDetailProperties.Destroy;
begin
  if (FAutoDestroy) then
    FreeAndNil(FObj);
  inherited Destroy();
end;

end.
