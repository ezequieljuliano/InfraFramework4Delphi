unit InfraDB4D.Drivers.FireDAC;

interface

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.Generics.Collections,
  InfraDB4D,
  InfraDB4D.Drivers.Base,
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

implementation

var
  _vFireDACConnection: TFireDACConnectionAdapter = nil;

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

class function TFireDACSingletonConnectionAdapter.Get: TFireDACConnectionAdapter;
begin
  if (_vFireDACConnection = nil) then
  begin
    TGlobalCriticalSection.GetInstance.Enter;
    try
      _vFireDACConnection := TFireDACConnectionAdapter.Create;
    finally
      TGlobalCriticalSection.GetInstance.Leave;
    end;
  end;
  Result := _vFireDACConnection;
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
    vPair.Value.Obj.GetDataSet.Close;
end;

procedure TFireDACDetailsAdapter.DoDisableAllControls;
var
  vPair: TPair<string, TDetailProperties>;
begin
  inherited;
  for vPair in GetDetailDictionary do
    vPair.Value.Obj.GetDataSet.DisableControls();
end;

procedure TFireDACDetailsAdapter.DoEnableAllControls;
var
  vPair: TPair<string, TDetailProperties>;
begin
  inherited;
  for vPair in GetDetailDictionary do
    vPair.Value.Obj.GetDataSet.EnableControls();
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
    vPair.Value.Obj.GetDataSet.Open();
end;

initialization

_vFireDACConnection := nil;

finalization

if (_vFireDACConnection <> nil) then
  FreeAndNil(_vFireDACConnection);

end.
