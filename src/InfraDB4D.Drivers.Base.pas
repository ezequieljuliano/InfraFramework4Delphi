(*
  Copyright 2014 Ezequiel Juliano Müller | Microsys Sistemas Ltda

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*)

unit InfraDB4D.Drivers.Base;

interface

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.Generics.Collections,
  System.TypInfo,
  InfraDB4D,
  SQLBuilder4D,
  PropertiesFile4D,
  SQLBuilder4D.Parser;

type

  TDriverComponent<TCompConnection: TComponent> = class abstract
  strict private
    FCompConnection: TCompConnection;
  public
    constructor Create(const pCompConnection: TCompConnection);

    function GetCompConnection(): TCompConnection;
  end;

  TDriverStatement<TDataSet: TComponent; TDrvConnection: class> = class abstract
  strict private
    FConnection: TDrvConnection;
  strict protected
    function GetConnection(): TDrvConnection;

    procedure DoInternalBuild(const pSQL: string; const pAutoCommit: Boolean = False); virtual; abstract;
    function DoInternalBuildAsDataSet(const pSQL: string; const pFetchRows: Integer): TDataSet; virtual; abstract;
  public
    constructor Create(const pConnection: TDrvConnection);

    procedure Build(const pInsert: ISQLInsert; const pAutoCommit: Boolean = False); overload;
    procedure Build(const pUpdate: ISQLUpdate; const pAutoCommit: Boolean = False); overload;
    procedure Build(const pDelete: ISQLDelete; const pAutoCommit: Boolean = False); overload;

    procedure Build(const pWhere: ISQLWhere; const pAutoCommit: Boolean = False); overload;
    procedure Build(const pGroupBy: ISQLGroupBy; const pAutoCommit: Boolean = False); overload;
    procedure Build(const pHaving: ISQLHaving; const pAutoCommit: Boolean = False); overload;
    procedure Build(const pOrderBy: ISQLOrderBy; const pAutoCommit: Boolean = False); overload;

    function BuildAsDataSet(const pSelect: ISQLSelect; const pFetchRows: Integer = 0): TDataSet; overload;
    function BuildAsDataSet(const pWhere: ISQLWhere; const pFetchRows: Integer = 0): TDataSet; overload;
    function BuildAsDataSet(const pGroupBy: ISQLGroupBy; const pFetchRows: Integer = 0): TDataSet; overload;
    function BuildAsDataSet(const pHaving: ISQLHaving; const pFetchRows: Integer = 0): TDataSet; overload;
    function BuildAsDataSet(const pOrderBy: ISQLOrderBy; const pFetchRows: Integer = 0): TDataSet; overload;
  end;

  TDriverConnection<TDrvComponent, TDrvStatement: class> = class abstract
  strict private
    FComponent: TDrvComponent;
    FStatement: TDrvStatement;
  strict protected
    procedure SetStatement(const pStatement: TDrvStatement);
    procedure DoCreateStatement(); virtual; abstract;

    procedure DoConnect(); virtual; abstract;
    procedure DoDisconect(); virtual; abstract;

    function DoInTransaction(): Boolean; virtual; abstract;
    procedure DoStartTransaction(); virtual; abstract;
    procedure DoCommit(); virtual; abstract;
    procedure DoRollback(); virtual; abstract;
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

    procedure Build(const pComponent: TDrvComponent);
  end;

  TDriverConnectionFactory<TDrvConnection: class> = class abstract
  strict private
    FIsThreadSafe: Boolean;
  strict protected
    function DoGetNewInstance(): TDrvConnection; virtual; abstract;
    function DoGetSingletonInstance(): TDrvConnection; virtual; abstract;
  public
    constructor Create();

    function GetIsThreadSafe: Boolean;
    procedure SetIsThreadSafe(const pValue: Boolean);

    function GetNewInstance(): TDrvConnection;
    function GetSingletonInstance(): TDrvConnection;

    property IsThreadSafe: Boolean read GetIsThreadSafe write SetIsThreadSafe;
  end;

  TDriverManager<TKey; TDrvConnection: class> = class abstract
  strict private
    FIsThreadSafe: Boolean;
    FConnections: TDictionary<TKey, TDrvConnection>;
  public
    constructor Create();
    destructor Destroy(); override;

    function GetCount: Integer;
    function GetIsThreadSafe: Boolean;
    procedure SetIsThreadSafe(const pValue: Boolean);

    procedure RegisterConnection(const pKey: TKey; const pConnection: TDrvConnection);
    procedure UnregisterConnection(const pKey: TKey);
    procedure UnregisterAllConnections();
    function ConnectionIsRegistered(const pKey: TKey): Boolean;
    function GetConnection(const pKey: TKey): TDrvConnection;

    property Count: Integer read GetCount;
    property IsThreadSafe: Boolean read GetIsThreadSafe write SetIsThreadSafe;
  end;

  TDriverController<TDataSet: TComponent; TDrvConnection, TDrvDetails: class> = class abstract
  strict private
    FDataSet: TDataSet;
    FConnection: TDrvConnection;
    FSQLInitial: string;
    FSQLParserSelect: ISQLParserSelect;
    FDetails: TDrvDetails;
    procedure InternalCreate();
  strict protected
    procedure SetDetails(const pDBDetails: TDrvDetails);
    function GetSQLInitial(): string;
    function GetSQLParserSelect(): ISQLParserSelect;

    procedure DoCreateDetails(); virtual; abstract;
    procedure DoChangeSQLTextOfDataSet(); virtual; abstract;
    function DoGetSQLTextOfDataSet(): string; virtual; abstract;

    procedure DoOpen(); virtual; abstract;
    procedure DoClose(); virtual; abstract;
  public
    constructor Create(const pConnection: TDrvConnection); overload;
    constructor Create(const pConnection: TDrvConnection; const pDataSet: TDataSet); overload;
    destructor Destroy(); override;

    function GetConnection(): TDrvConnection;
    function GetDetails(): TDrvDetails;
    function GetDataSet(): TDataSet;
    procedure SetDataSet(const pDataSet: TDataSet);

    procedure SQLInitialize(const pSQL: string);
    procedure SQLBuild(const pWhere: ISQLWhere; const pOpen: Boolean = True); overload;
    procedure SQLBuild(const pGroupBy: ISQLGroupBy; const pOpen: Boolean = True); overload;
    procedure SQLBuild(const pOrderBy: ISQLOrderBy; const pOpen: Boolean = True); overload;
    procedure SQLBuild(const pHaving: ISQLHaving; const pOpen: Boolean = True); overload;
    procedure SQLRestore(const pOpen: Boolean = True);
  end;

  TDriverDetails<TKey; TDrvController: class> = class abstract
  strict private
    FDetails: TDictionary<TKey, TDrvController>;
    FMasterController: TDrvController;
  strict protected
    function GetMasterController(): TDrvController;
    function GetDetailDictionary(): TDictionary<TKey, TDrvController>;

    procedure DoOpenAll(); virtual; abstract;
    procedure DoCloseAll(); virtual; abstract;
    procedure DoDisableAllControls(); virtual; abstract;
    procedure DoEnableAllControls(); virtual; abstract;
  public
    constructor Create(const pMasterController: TDrvController);
    destructor Destroy(); override;

    function GetCount: Integer;

    procedure RegisterDetail(const pKey: TKey; const pDetail: TDrvController);
    procedure UnregisterDetail(const pKey: TKey);
    procedure UnregisterAllDetails();
    function DetailIsRegistered(const pKey: TKey): Boolean;
    function GetDetail(const pKey: TKey): TDrvController;

    procedure OpenAll();
    procedure CloseAll();
    procedure DisableAllControls();
    procedure EnableAllControls();

    property Count: Integer read GetCount;
  end;

implementation

{ TDriverStatement<TDataSet, TDBConnection> }

procedure TDriverStatement<TDataSet, TDrvConnection>.Build(
  const pDelete: ISQLDelete; const pAutoCommit: Boolean);
begin
  DoInternalBuild(pDelete.ToString, pAutoCommit);
end;

procedure TDriverStatement<TDataSet, TDrvConnection>.Build(
  const pWhere: ISQLWhere; const pAutoCommit: Boolean);
begin
  DoInternalBuild(pWhere.ToString, pAutoCommit);
end;

procedure TDriverStatement<TDataSet, TDrvConnection>.Build(
  const pInsert: ISQLInsert; const pAutoCommit: Boolean);
begin
  DoInternalBuild(pInsert.ToString, pAutoCommit);
end;

procedure TDriverStatement<TDataSet, TDrvConnection>.Build(
  const pUpdate: ISQLUpdate; const pAutoCommit: Boolean);
begin
  DoInternalBuild(pUpdate.ToString, pAutoCommit);
end;

procedure TDriverStatement<TDataSet, TDrvConnection>.Build(
  const pOrderBy: ISQLOrderBy; const pAutoCommit: Boolean);
begin
  DoInternalBuild(pOrderBy.ToString, pAutoCommit);
end;

procedure TDriverStatement<TDataSet, TDrvConnection>.Build(
  const pHaving: ISQLHaving; const pAutoCommit: Boolean);
begin
  DoInternalBuild(pHaving.ToString, pAutoCommit);
end;

procedure TDriverStatement<TDataSet, TDrvConnection>.Build(
  const pGroupBy: ISQLGroupBy; const pAutoCommit: Boolean);
begin
  DoInternalBuild(pGroupBy.ToString, pAutoCommit);
end;

function TDriverStatement<TDataSet, TDrvConnection>.BuildAsDataSet(
  const pHaving: ISQLHaving; const pFetchRows: Integer): TDataSet;
begin
  Result := DoInternalBuildAsDataSet(pHaving.ToString, pFetchRows);
end;

function TDriverStatement<TDataSet, TDrvConnection>.BuildAsDataSet(
  const pGroupBy: ISQLGroupBy; const pFetchRows: Integer): TDataSet;
begin
  Result := DoInternalBuildAsDataSet(pGroupBy.ToString, pFetchRows);
end;

function TDriverStatement<TDataSet, TDrvConnection>.BuildAsDataSet(
  const pWhere: ISQLWhere; const pFetchRows: Integer): TDataSet;
begin
  Result := DoInternalBuildAsDataSet(pWhere.ToString, pFetchRows);
end;

function TDriverStatement<TDataSet, TDrvConnection>.BuildAsDataSet(
  const pSelect: ISQLSelect; const pFetchRows: Integer): TDataSet;
begin
  Result := DoInternalBuildAsDataSet(pSelect.ToString, pFetchRows);
end;

function TDriverStatement<TDataSet, TDrvConnection>.BuildAsDataSet(
  const pOrderBy: ISQLOrderBy; const pFetchRows: Integer): TDataSet;
begin
  Result := DoInternalBuildAsDataSet(pOrderBy.ToString, pFetchRows);
end;

constructor TDriverStatement<TDataSet, TDrvConnection>.Create(
  const pConnection: TDrvConnection);
begin
  FConnection := pConnection;
end;

function TDriverStatement<TDataSet, TDrvConnection>.GetConnection: TDrvConnection;
begin
  Result := FConnection;
end;

{ TDriverComponent<TCompConnection> }

constructor TDriverComponent<TCompConnection>.Create(
  const pCompConnection: TCompConnection);
begin
  FCompConnection := pCompConnection;
end;

function TDriverComponent<TCompConnection>.GetCompConnection: TCompConnection;
begin
  Result := FCompConnection;
end;

{ TDriverConnection<TDrvComponent, TDrvStatement> }

procedure TDriverConnection<TDrvComponent, TDrvStatement>.Build(
  const pComponent: TDrvComponent);
begin
  FComponent := pComponent;
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
  DoCreateStatement();
end;

destructor TDriverConnection<TDrvComponent, TDrvStatement>.Destroy;
begin
  if (FComponent <> nil) then
    FreeAndNil(FComponent);

  if (FStatement <> nil) then
    FreeAndNil(FStatement);
  inherited Destroy();
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

{ TDriverConnectionFactory<TDrvConnection> }

constructor TDriverConnectionFactory<TDrvConnection>.Create;
begin
  FIsThreadSafe := True;
end;

function TDriverConnectionFactory<TDrvConnection>.GetIsThreadSafe: Boolean;
begin
  Result := FIsThreadSafe;
end;

function TDriverConnectionFactory<TDrvConnection>.GetNewInstance: TDrvConnection;
begin
  Result := DoGetNewInstance();
end;

function TDriverConnectionFactory<TDrvConnection>.GetSingletonInstance: TDrvConnection;
begin
  if FIsThreadSafe then
    TGlobalCriticalSection.GetInstance.Enter;
  try
    Result := DoGetSingletonInstance();
  finally
    if FIsThreadSafe then
      TGlobalCriticalSection.GetInstance.Leave;
  end;
end;

procedure TDriverConnectionFactory<TDrvConnection>.SetIsThreadSafe(
  const pValue: Boolean);
begin
  FIsThreadSafe := pValue;
end;

{ TDriverManager<TKey, TDrvConnection> }

constructor TDriverManager<TKey, TDrvConnection>.Create;
begin
  FIsThreadSafe := True;
  FConnections := TDictionary<TKey, TDrvConnection>.Create();
end;

function TDriverManager<TKey, TDrvConnection>.ConnectionIsRegistered(
  const pKey: TKey): Boolean;
begin
  Result := FConnections.ContainsKey(pKey);
end;

destructor TDriverManager<TKey, TDrvConnection>.Destroy;
begin
  FreeAndNil(FConnections);
  inherited Destroy();
end;

function TDriverManager<TKey, TDrvConnection>.GetCount: Integer;
begin
  Result := FConnections.Count;
end;

function TDriverManager<TKey, TDrvConnection>.GetConnection(
  const pKey: TKey): TDrvConnection;
begin
  if ConnectionIsRegistered(pKey) then
  begin
    if FIsThreadSafe then
      TGlobalCriticalSection.GetInstance.Enter;
    try
      Result := FConnections.Items[pKey];
    finally
      if FIsThreadSafe then
        TGlobalCriticalSection.GetInstance.Leave;
    end;
  end
  else
    raise EConnectionUnregistered.Create('Database connection unregistered!');
end;

function TDriverManager<TKey, TDrvConnection>.GetIsThreadSafe: Boolean;
begin
  Result := FIsThreadSafe;
end;

procedure TDriverManager<TKey, TDrvConnection>.RegisterConnection(
  const pKey: TKey; const pConnection: TDrvConnection);
begin
  if not ConnectionIsRegistered(pKey) then
  begin
    if FIsThreadSafe then
      TGlobalCriticalSection.GetInstance.Enter;
    try
      FConnections.Add(pKey, pConnection);
    finally
      if FIsThreadSafe then
        TGlobalCriticalSection.GetInstance.Leave;
    end;
  end
  else
    raise EConnectionAlreadyRegistered.Create('Database already registered!');
end;

procedure TDriverManager<TKey, TDrvConnection>.SetIsThreadSafe(
  const pValue: Boolean);
begin
  FIsThreadSafe := pValue;
end;

procedure TDriverManager<TKey, TDrvConnection>.UnregisterAllConnections;
begin
  if FIsThreadSafe then
    TGlobalCriticalSection.GetInstance.Enter;
  try
    FConnections.Clear;
  finally
    if FIsThreadSafe then
      TGlobalCriticalSection.GetInstance.Leave;
  end;
end;

procedure TDriverManager<TKey, TDrvConnection>.UnregisterConnection(
  const pKey: TKey);
begin
  if ConnectionIsRegistered(pKey) then
  begin
    if FIsThreadSafe then
      TGlobalCriticalSection.GetInstance.Enter;
    try
      FConnections.Remove(pKey);
    finally
      if FIsThreadSafe then
        TGlobalCriticalSection.GetInstance.Leave;
    end;
  end
  else
    raise EConnectionUnregistered.Create('Database connection unregistered!');
end;

{ TDriverController<TDataSet, TDrvConnection, TDrvDetails> }

constructor TDriverController<TDataSet, TDrvConnection, TDrvDetails>.Create(
  const pConnection: TDrvConnection; const pDataSet: TDataSet);
begin
  FConnection := pConnection;
  FDataSet := pDataSet;
  InternalCreate();
end;

constructor TDriverController<TDataSet, TDrvConnection, TDrvDetails>.Create(
  const pConnection: TDrvConnection);
begin
  FConnection := pConnection;
  FDataSet := nil;
  InternalCreate();
end;

destructor TDriverController<TDataSet, TDrvConnection, TDrvDetails>.Destroy;
begin
  if (FDetails <> nil) then
    FreeAndNil(FDetails);
  inherited Destroy();
end;

function TDriverController<TDataSet, TDrvConnection, TDrvDetails>.GetDataSet: TDataSet;
begin
  if (FDataSet = nil) then
    raise EDataSetDoesNotExist.Create('DataSet does not exist!');

  Result := FDataSet;
end;

function TDriverController<TDataSet, TDrvConnection, TDrvDetails>.GetConnection: TDrvConnection;
begin
  if (FConnection = nil) then
    raise EConnectionDoesNotExist.Create('DBConnection does not exist!');

  Result := FConnection;
end;

function TDriverController<TDataSet, TDrvConnection, TDrvDetails>.GetDetails: TDrvDetails;
begin
  if (FDetails = nil) then
    raise EDetailUnregistered.Create('DBDetails unregistered!');

  Result := FDetails;
end;

function TDriverController<TDataSet, TDrvConnection, TDrvDetails>.GetSQLInitial: string;
begin
  Result := FSQLInitial;
end;

function TDriverController<TDataSet, TDrvConnection, TDrvDetails>.GetSQLParserSelect: ISQLParserSelect;
begin
  Result := FSQLParserSelect;
end;

procedure TDriverController<TDataSet, TDrvConnection, TDrvDetails>.InternalCreate;
begin
  FSQLParserSelect := TSQLParserFactory.GetSelectInstance(prGaSQLParser);
  if (FDataSet <> nil) then
    FSQLInitial := DoGetSQLTextOfDataSet
  else
    FSQLInitial := EmptyStr;
  SQLInitialize(FSQLInitial);
  DoCreateDetails();
end;

procedure TDriverController<TDataSet, TDrvConnection, TDrvDetails>.SetDataSet(
  const pDataSet: TDataSet);
begin
  FDataSet := pDataSet;
  FSQLInitial := DoGetSQLTextOfDataSet;
  SQLInitialize(FSQLInitial);
end;

procedure TDriverController<TDataSet, TDrvConnection, TDrvDetails>.SetDetails(
  const pDBDetails: TDrvDetails);
begin
  FDetails := pDBDetails;
end;

procedure TDriverController<TDataSet, TDrvConnection, TDrvDetails>.SQLBuild(
  const pGroupBy: ISQLGroupBy; const pOpen: Boolean);
begin
  DoClose();
  FSQLParserSelect.AddOrSetGroupBy(pGroupBy.ToString);
  DoChangeSQLTextOfDataSet();
  if pOpen then
    DoOpen();
end;

procedure TDriverController<TDataSet, TDrvConnection, TDrvDetails>.SQLBuild(
  const pWhere: ISQLWhere; const pOpen: Boolean);
begin
  DoClose();
  FSQLParserSelect.AddOrSetWhere(pWhere.ToString);
  DoChangeSQLTextOfDataSet();
  if pOpen then
    DoOpen();
end;

procedure TDriverController<TDataSet, TDrvConnection, TDrvDetails>.SQLBuild(
  const pOrderBy: ISQLOrderBy; const pOpen: Boolean);
begin
  DoClose();
  FSQLParserSelect.AddOrSetOrderBy(pOrderBy.ToString);
  DoChangeSQLTextOfDataSet();
  if pOpen then
    DoOpen();
end;

procedure TDriverController<TDataSet, TDrvConnection, TDrvDetails>.SQLBuild(
  const pHaving: ISQLHaving; const pOpen: Boolean);
begin
  DoClose();
  FSQLParserSelect.AddOrSetHaving(pHaving.ToString);
  DoChangeSQLTextOfDataSet();
  if pOpen then
    DoOpen();
end;

procedure TDriverController<TDataSet, TDrvConnection, TDrvDetails>.SQLInitialize(
  const pSQL: string);
begin
  if (pSQL <> EmptyStr) then
  begin
    DoClose();
    FSQLInitial := pSQL;
    FSQLParserSelect.Parse(FSQLInitial);
    DoChangeSQLTextOfDataSet();
  end;
end;

procedure TDriverController<TDataSet, TDrvConnection, TDrvDetails>.SQLRestore(
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
  FDetails := TDictionary<TKey, TDrvController>.Create();
  FMasterController := pMasterController;
end;

function TDriverDetails<TKey, TDrvController>.DetailIsRegistered(
  const pKey: TKey): Boolean;
begin
  Result := FDetails.ContainsKey(pKey);
end;

destructor TDriverDetails<TKey, TDrvController>.Destroy;
begin
  FreeAndNil(FDetails);
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

function TDriverDetails<TKey, TDrvController>.GetDetail(
  const pKey: TKey): TDrvController;
begin
  if DetailIsRegistered(pKey) then
    Result := FDetails.Items[pKey]
  else
    raise EDetailUnregistered.Create('DBDetail unregistered!');
end;

function TDriverDetails<TKey, TDrvController>.GetDetailDictionary: TDictionary<TKey, TDrvController>;
begin
  Result := FDetails;
end;

procedure TDriverDetails<TKey, TDrvController>.OpenAll;
begin
  DoOpenAll();
end;

procedure TDriverDetails<TKey, TDrvController>.RegisterDetail(
  const pKey: TKey; const pDetail: TDrvController);
begin
  if not DetailIsRegistered(pKey) then
    FDetails.Add(pKey, pDetail)
  else
    raise EDetailAlreadyRegistered.Create('DBDetail already registered!');
end;

procedure TDriverDetails<TKey, TDrvController>.UnregisterAllDetails;
var
  vPair: TPair<TKey, TDrvController>;
  vKey: TKey;
begin
  for vPair in FDetails do
  begin
    vKey := vPair.Key;
    UnregisterDetail(vKey);
  end;
end;

procedure TDriverDetails<TKey, TDrvController>.UnregisterDetail(
  const pKey: TKey);
begin
  if DetailIsRegistered(pKey) then
    FDetails.Remove(pKey)
  else
    raise EDetailUnregistered.Create('DBDetail unregistered!');
end;

end.
