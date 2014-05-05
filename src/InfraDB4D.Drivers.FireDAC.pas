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
  FireDAC.Stan.Option;

type

  TFireDACComponentAdapter = class(TDriverComponent<TFDConnection>);

  TFireDACConnectionAdapter = class;

  TFireDACStatementAdapter = class(TDriverStatement<TFDQuery, TFireDACConnectionAdapter>)
  strict protected
    procedure DoInternalBuild(const pSQL: string; const pAutoCommit: Boolean = False); override;
    function DoInternalBuildAsDataSet(const pSQL: string; const pFetchRows: Integer): TFDQuery; override;
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
    procedure DoLinkMasterDataSource(const pMasterController: TFireDACControllerAdapter); override;
    procedure DoLinkDetailOnMasterDataSource(const pDetail: TFireDACControllerAdapter); override;
  end;

implementation

var
  _vFireDACConnection: TFireDACConnectionAdapter = nil;

  { TFireDACStatementAdapter }

procedure TFireDACStatementAdapter.DoInternalBuild(const pSQL: string;
  const pAutoCommit: Boolean);
var
  vDataSet: TFDQuery;
begin
  vDataSet := TFDQuery.Create(nil);
  try
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

{ TFireDACConnectionAdapter }

procedure TFireDACConnectionAdapter.DoCommit;
begin
  GetComponent.GetConnection.Commit();
end;

procedure TFireDACConnectionAdapter.DoConnect;
begin
  GetComponent.GetConnection.Open();
end;

procedure TFireDACConnectionAdapter.DoCreateStatement;
begin
  SetStatement(TFireDACStatementAdapter.Create(Self));
end;

procedure TFireDACConnectionAdapter.DoDisconect;
begin
  GetComponent.GetConnection.Close();
end;

function TFireDACConnectionAdapter.DoInTransaction: Boolean;
begin
  Result := GetComponent.GetConnection.InTransaction;
end;

procedure TFireDACConnectionAdapter.DoRollback;
begin
  GetComponent.GetConnection.Rollback();
end;

procedure TFireDACConnectionAdapter.DoStartTransaction;
begin
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
  GetDataSet.SQL.Clear;
  GetDataSet.SQL.Add(GetSQLParserSelect.GetSQLText);
end;

procedure TFireDACControllerAdapter.DoClose;
begin
  GetDataSet.Close();
end;

procedure TFireDACControllerAdapter.DoConfigureDataSetConnection;
begin
  GetDataSet.Connection := GetConnection.GetComponent.GetConnection;
end;

procedure TFireDACControllerAdapter.DoCreateDetails;
begin
  SetDetails(TFireDACDetailsAdapter.Create(Self));
end;

function TFireDACControllerAdapter.DoGetSQLTextOfDataSet: string;
begin
  Result := GetDataSet.SQL.Text;
end;

procedure TFireDACControllerAdapter.DoOpen;
begin
  GetDataSet.Open();
end;

{ TFireDACDetailsAdapter }

procedure TFireDACDetailsAdapter.DoCloseAll;
var
  vPair: TPair<string, TDetailProperties>;
begin
  for vPair in GetDetailDictionary do
    vPair.Value.Obj.GetDataSet.Close;
end;

procedure TFireDACDetailsAdapter.DoDisableAllControls;
var
  vPair: TPair<string, TDetailProperties>;
begin
  for vPair in GetDetailDictionary do
    vPair.Value.Obj.GetDataSet.DisableControls();
end;

procedure TFireDACDetailsAdapter.DoEnableAllControls;
var
  vPair: TPair<string, TDetailProperties>;
begin
  for vPair in GetDetailDictionary do
    vPair.Value.Obj.GetDataSet.EnableControls();
end;

procedure TFireDACDetailsAdapter.DoLinkDetailOnMasterDataSource(
  const pDetail: TFireDACControllerAdapter);
begin
  pDetail.GetDataSet.MasterSource := GetMasterDataSource();
end;

procedure TFireDACDetailsAdapter.DoLinkMasterDataSource(
  const pMasterController: TFireDACControllerAdapter);
begin
  GetMasterDataSource.DataSet := pMasterController.GetDataSet;
end;

procedure TFireDACDetailsAdapter.DoOpenAll;
var
  vPair: TPair<string, TDetailProperties>;
begin
  for vPair in GetDetailDictionary do
    vPair.Value.Obj.GetDataSet.Open();
end;

initialization

_vFireDACConnection := nil;

finalization

if (_vFireDACConnection <> nil) then
  FreeAndNil(_vFireDACConnection);

end.
