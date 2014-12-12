unit InfraDB4D.Drivers.IBX;

interface

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.Generics.Collections,
  Data.DB,
  InfraDB4D,
  InfraDB4D.Drivers.Base,
  InfraDB4D.Iterator,
  SQLBuilder4D,
  IBX.IBDatabase,
  IBX.IBCustomDataSet;

type

  TIBXComponentAdapter = class(TDriverComponent<TIBDatabase>);

  TIBXConnectionAdapter = class;

  TIBXStatementAdapter = class(TDriverStatement<TIBDataSet, TIBXConnectionAdapter>)
  strict protected
    procedure DoBuild(const pSQL: string; const pDataSet: TIBDataSet; const pAutoCommit: Boolean = False); override;

    procedure DoBuildInDataSet(const pSQL: string; const pDataSet: TIBDataSet); override;
    procedure DoBuildInIterator(const pSQL: string; const pIterator: IIterator<TIBDataSet>); override;

    function DoBuildAsDataSet(const pSQL: string; const pFetchRows: Integer): TIBDataSet; override;
    function DoBuildAsIteratorDataSet(const pSQL: string): IIteratorDataSet; override;
    function DoBuildAsIterator(const pSQL: string; const pFetchRows: Integer): IIterator<TIBDataSet>; override;

    function DoBuildAsInteger(const pSQL: string): Integer; override;
    function DoBuildAsFloat(const pSQL: string): Double; override;
    function DoBuildAsString(const pSQL: string): string; override;
  end;

  TIBXConnectionAdapter = class(TDriverConnection<TIBXComponentAdapter, TIBXStatementAdapter>)
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

  TIBXSingletonConnectionAdapter = class(TDriverSingletonConnection<TIBXConnectionAdapter>)
  strict private
    class var SingletonConnectionAdapter: TIBXConnectionAdapter;
    class constructor Create;
    class destructor Destroy;
  public
    class function Get(): TIBXConnectionAdapter; static;
  end;

  TIBXConnectionManagerAdapter = class(TDriverConnectionManager<string, TIBXConnectionAdapter>);

  TIBXDetailsAdapter = class;

  TIBXControllerAdapter = class(TDriverController<TIBDataSet, TIBXConnectionAdapter, TIBXDetailsAdapter>)
  strict protected
    procedure DoCreateDetails(); override;

    procedure DoChangeSQLTextOfDataSet(); override;
    procedure DoConfigureDataSetConnection(); override;

    function DoGetSQLTextOfDataSet(): string; override;

    procedure DoOpen(); override;
    procedure DoClose(); override;
  end;

  TIBXDBControllerClass = class of TIBXControllerAdapter;

  TIBXDetailsAdapter = class(TDriverDetails<string, TIBXControllerAdapter>)
  strict protected
    procedure DoOpenAll(); override;
    procedure DoCloseAll(); override;
    procedure DoDisableAllControls(); override;
    procedure DoEnableAllControls(); override;
    procedure DoLinkMasterController(const pDetailController: TIBXControllerAdapter); override;
    procedure DoLinkMasterDataSource(const pMasterController: TIBXControllerAdapter); override;
    procedure DoLinkDetailOnMasterDataSource(const pDetail: TIBXControllerAdapter); override;
  end;

implementation

{ TIBXStatementAdapter }

procedure TIBXStatementAdapter.DoBuild(const pSQL: string; const pDataSet: TIBDataSet; const pAutoCommit: Boolean);
var
  vDataSet: TIBDataSet;
begin
  inherited;
  if (pDataSet = nil) then
    vDataSet := TIBDataSet.Create(nil)
  else
    vDataSet := pDataSet;
  try
    vDataSet.Close;
    vDataSet.SelectSQL.Clear;
    vDataSet.Database := GetConnection.GetComponent.GetConnection;
    vDataSet.SelectSQL.Add(pSQL);
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
    if (pDataSet = nil) then
      FreeAndNil(vDataSet);
  end;
end;

function TIBXStatementAdapter.DoBuildAsDataSet(const pSQL: string;
  const pFetchRows: Integer): TIBDataSet;
begin
  Result := TIBDataSet.Create(nil);
  Result.Database := GetConnection.GetComponent.GetConnection;
  Result.SelectSQL.Add(pSQL);
  Result.Prepare;
  Result.Open;
end;

function TIBXStatementAdapter.DoBuildAsFloat(
  const pSQL: string): Double;
var
  vDataSet: TIBDataSet;
begin
  Result := 0;

  vDataSet := DoBuildAsDataSet(pSQL, 1);
  try
    if not vDataSet.IsEmpty then
      Result := vDataSet.Fields[0].AsFloat;
  finally
    FreeAndNil(vDataSet);
  end;
end;

function TIBXStatementAdapter.DoBuildAsInteger(
  const pSQL: string): Integer;
var
  vDataSet: TIBDataSet;
begin
  Result := 0;

  vDataSet := DoBuildAsDataSet(pSQL, 1);
  try
    if not vDataSet.IsEmpty then
      Result := vDataSet.Fields[0].AsInteger;
  finally
    FreeAndNil(vDataSet);
  end;
end;

function TIBXStatementAdapter.DoBuildAsIterator(const pSQL: string;
  const pFetchRows: Integer): IIterator<TIBDataSet>;
begin
  Result := TIteratorFactory<TIBDataSet>.Get(DoBuildAsDataSet(pSQL, 0), True);
end;

function TIBXStatementAdapter.DoBuildAsIteratorDataSet(const pSQL: string): IIteratorDataSet;
begin
  Result := TIteratorDataSetFactory.Get(DoBuildAsDataSet(pSQL, 0), True);
end;

function TIBXStatementAdapter.DoBuildAsString(
  const pSQL: string): string;
var
  vDataSet: TIBDataSet;
begin
  Result := EmptyStr;

  vDataSet := DoBuildAsDataSet(pSQL, 1);
  try
    if not vDataSet.IsEmpty then
      Result := vDataSet.Fields[0].AsString;
  finally
    FreeAndNil(vDataSet);
  end;
end;

procedure TIBXStatementAdapter.DoBuildInDataSet(const pSQL: string; const pDataSet: TIBDataSet);
begin
  inherited;
  if (pDataSet = nil) then
    raise EDataSetDoesNotExist.Create('DataSet does not exist!');

  pDataSet.Close;
  pDataSet.Database := GetConnection.GetComponent.GetConnection;
  pDataSet.SelectSQL.Add(pSQL);
  pDataSet.Prepare;
  pDataSet.Open;
end;

procedure TIBXStatementAdapter.DoBuildInIterator(const pSQL: string;
  const pIterator: IIterator<TIBDataSet>);
begin
  inherited;
  DoBuildInDataSet(pSQL, pIterator.GetDataSet);
end;

{ TIBXConnectionAdapter }

procedure TIBXConnectionAdapter.DoAfterBuild;
begin
  inherited;

end;

procedure TIBXConnectionAdapter.DoCommit;
begin
  inherited;
  GetComponent.GetConnection.DefaultTransaction.CommitRetaining;
end;

procedure TIBXConnectionAdapter.DoConnect;
begin
  inherited;
  GetComponent.GetConnection.Open();
end;

procedure TIBXConnectionAdapter.DoCreateStatement;
begin
  inherited;
  SetStatement(TIBXStatementAdapter.Create(Self));
end;

procedure TIBXConnectionAdapter.DoDisconect;
begin
  inherited;
  GetComponent.GetConnection.Close();
end;

function TIBXConnectionAdapter.DoInTransaction: Boolean;
begin
  Result := (GetComponent.GetConnection.TransactionCount > 0);
end;

procedure TIBXConnectionAdapter.DoRollback;
begin
  inherited;
  GetComponent.GetConnection.DefaultTransaction.RollbackRetaining;
end;

procedure TIBXConnectionAdapter.DoStartTransaction;
begin
  inherited;
  GetComponent.GetConnection.DefaultTransaction.StartTransaction;
end;

{ TIBXSingletonConnectionAdapter }

class constructor TIBXSingletonConnectionAdapter.Create;
begin
  SingletonConnectionAdapter := nil;
end;

class destructor TIBXSingletonConnectionAdapter.Destroy;
begin
  if (SingletonConnectionAdapter <> nil) then
    FreeAndNil(SingletonConnectionAdapter);
end;

class function TIBXSingletonConnectionAdapter.Get: TIBXConnectionAdapter;
begin
  if (SingletonConnectionAdapter = nil) then
  begin
    TGlobalCriticalSection.GetInstance.Enter;
    try
      SingletonConnectionAdapter := TIBXConnectionAdapter.Create;
    finally
      TGlobalCriticalSection.GetInstance.Leave;
    end;
  end;
  Result := SingletonConnectionAdapter;
end;

{ TIBXControllerAdapter }

procedure TIBXControllerAdapter.DoChangeSQLTextOfDataSet;
begin
  inherited;
  GetDataSet.SelectSQL.Clear;
  GetDataSet.SelectSQL.Add(GetSQLParserSelect.GetSQLText);
end;

procedure TIBXControllerAdapter.DoClose;
begin
  inherited;
  GetDataSet.Close();
end;

procedure TIBXControllerAdapter.DoConfigureDataSetConnection;
begin
  inherited;
  GetDataSet.Database := GetConnection.GetComponent.GetConnection;
end;

procedure TIBXControllerAdapter.DoCreateDetails;
begin
  inherited;
  SetDetails(TIBXDetailsAdapter.Create(Self));
end;

function TIBXControllerAdapter.DoGetSQLTextOfDataSet: string;
begin
  inherited;
  Result := GetDataSet.SelectSQL.Text;
end;

procedure TIBXControllerAdapter.DoOpen;
begin
  inherited;
  GetDataSet.Open();
end;

{ TIBXDetailsAdapter }

procedure TIBXDetailsAdapter.DoCloseAll;
var
  vPair: TPair<string, TDetailProperties>;
begin
  inherited;
  for vPair in GetDetailDictionary do
    vPair.Value.Obj.GetDataSet.Close;
end;

procedure TIBXDetailsAdapter.DoDisableAllControls;
var
  vPair: TPair<string, TDetailProperties>;
begin
  inherited;
  for vPair in GetDetailDictionary do
    vPair.Value.Obj.GetDataSet.DisableControls();
end;

procedure TIBXDetailsAdapter.DoEnableAllControls;
var
  vPair: TPair<string, TDetailProperties>;
begin
  inherited;
  for vPair in GetDetailDictionary do
    vPair.Value.Obj.GetDataSet.EnableControls();
end;

procedure TIBXDetailsAdapter.DoLinkDetailOnMasterDataSource(
  const pDetail: TIBXControllerAdapter);
begin
  inherited;
  pDetail.GetDataSet.DataSource := GetMasterDataSource();
end;

procedure TIBXDetailsAdapter.DoLinkMasterController(
  const pDetailController: TIBXControllerAdapter);
begin
  inherited;
  pDetailController.SetMaster<TIBXControllerAdapter>(GetMasterController());
end;

procedure TIBXDetailsAdapter.DoLinkMasterDataSource(
  const pMasterController: TIBXControllerAdapter);
begin
  inherited;
  GetMasterDataSource.DataSet := pMasterController.GetDataSet;
end;

procedure TIBXDetailsAdapter.DoOpenAll;
var
  vPair: TPair<string, TDetailProperties>;
begin
  inherited;
  for vPair in GetDetailDictionary do
    vPair.Value.Obj.GetDataSet.Open();
end;

end.
