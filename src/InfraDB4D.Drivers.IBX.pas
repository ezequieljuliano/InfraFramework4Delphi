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
  SQLBuilder4D,
  IBX.IBDatabase,
  IBX.IBCustomDataSet;

type

  TIBXComponentAdapter = class(TDriverComponent<TIBDatabase>);

  TIBXConnectionAdapter = class;

  TIBXStatementAdapter = class(TDriverStatement<TIBDataSet, TIBXConnectionAdapter>)
  strict protected
    procedure DoInternalBuild(const pSQL: string; const pAutoCommit: Boolean = False); override;
    function DoInternalBuildAsDataSet(const pSQL: string; const pFetchRows: Integer): TIBDataSet; override;
    function DoInternalBuildAsInteger(const pSQL: string): Integer; override;
    function DoInternalBuildAsFloat(const pSQL: string): Double; override;
    function DoInternalBuildAsString(const pSQL: string): string; override;
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

var
  _vIBXConnection: TIBXConnectionAdapter = nil;

  { TIBXStatementAdapter }

procedure TIBXStatementAdapter.DoInternalBuild(const pSQL: string;
  const pAutoCommit: Boolean);
var
  vDataSet: TIBDataSet;
begin
  inherited;
  vDataSet := TIBDataSet.Create(nil);
  try
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
    FreeAndNil(vDataSet);
  end;
end;

function TIBXStatementAdapter.DoInternalBuildAsDataSet(const pSQL: string;
  const pFetchRows: Integer): TIBDataSet;
begin
  Result := TIBDataSet.Create(nil);
  Result.Database := GetConnection.GetComponent.GetConnection;
  Result.SelectSQL.Add(pSQL);
  Result.Prepare;
  Result.Open;
end;

function TIBXStatementAdapter.DoInternalBuildAsFloat(
  const pSQL: string): Double;
var
  vDataSet: TIBDataSet;
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

function TIBXStatementAdapter.DoInternalBuildAsInteger(
  const pSQL: string): Integer;
var
  vDataSet: TIBDataSet;
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

function TIBXStatementAdapter.DoInternalBuildAsString(
  const pSQL: string): string;
var
  vDataSet: TIBDataSet;
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

class function TIBXSingletonConnectionAdapter.Get: TIBXConnectionAdapter;
begin
  if (_vIBXConnection = nil) then
  begin
    TGlobalCriticalSection.GetInstance.Enter;
    try
      _vIBXConnection := TIBXConnectionAdapter.Create;
    finally
      TGlobalCriticalSection.GetInstance.Leave;
    end;
  end;
  Result := _vIBXConnection;
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

initialization

_vIBXConnection := nil;

finalization

if (_vIBXConnection <> nil) then
  FreeAndNil(_vIBXConnection);

end.
