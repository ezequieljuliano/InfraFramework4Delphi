unit InfraDB4D.Drivers.UniDAC;

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
  Uni;

type

  TUniDACComponentAdapter = class(TDriverComponent<TUniConnection>);

  TUniDACConnectionAdapter = class;

  TUniDACStatementAdapter = class(TDriverStatement<TUniQuery, TUniDACConnectionAdapter>)
  strict protected
    procedure DoBuild(const pSQL: string; const pDataSet: TUniQuery; const pAutoCommit: Boolean = False); override;

    procedure DoBuildInDataSet(const pSQL: string; const pDataSet: TUniQuery); override;
    procedure DoBuildInIterator(const pSQL: string; const pIterator: IIterator<TUniQuery>); override;

    function DoBuildAsDataSet(const pSQL: string; const pFetchRows: Integer): TUniQuery; override;
    function DoBuildAsIteratorDataSet(const pSQL: string): IIteratorDataSet; override;
    function DoBuildAsIterator(const pSQL: string; const pFetchRows: Integer): IIterator<TUniQuery>; override;

    function DoBuildAsInteger(const pSQL: string): Integer; override;
    function DoBuildAsFloat(const pSQL: string): Double; override;
    function DoBuildAsString(const pSQL: string): string; override;
  end;

  TUniDACConnectionAdapter = class(TDriverConnection<TUniDACComponentAdapter, TUniDACStatementAdapter>)
  strict private
  const
    cInterBaseProviderName = 'InterBase';
  strict private
    FDefaultAutoCommit: Boolean;
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

  TUniDACSingletonConnectionAdapter = class(TDriverSingletonConnection<TUniDACConnectionAdapter>)
  strict private
    class var SingletonConnectionAdapter: TUniDACConnectionAdapter;
    class constructor Create;
    class destructor Destroy;
  public
    class function Get(): TUniDACConnectionAdapter; static;
  end;

  TUniDACConnectionManagerAdapter = class(TDriverConnectionManager<string, TUniDACConnectionAdapter>);

  TUniDACDetailsAdapter = class;

  TUniDACControllerAdapter = class(TDriverController<TUniQuery, TUniDACConnectionAdapter, TUniDACDetailsAdapter>)
  strict protected
    procedure DoCreateDetails(); override;

    procedure DoChangeSQLTextOfDataSet(); override;
    procedure DoConfigureDataSetConnection(); override;

    function DoGetSQLTextOfDataSet(): string; override;

    procedure DoOpen(); override;
    procedure DoClose(); override;
  end;

  TUniDACDBControllerClass = class of TUniDACControllerAdapter;

  TUniDACDetailsAdapter = class(TDriverDetails<string, TUniDACControllerAdapter>)
  strict protected
    procedure DoOpenAll(); override;
    procedure DoCloseAll(); override;
    procedure DoDisableAllControls(); override;
    procedure DoEnableAllControls(); override;
    procedure DoLinkMasterController(const pDetailController: TUniDACControllerAdapter); override;
    procedure DoLinkMasterDataSource(const pMasterController: TUniDACControllerAdapter); override;
    procedure DoLinkDetailOnMasterDataSource(const pDetail: TUniDACControllerAdapter); override;
  end;

implementation

{ TUniDACStatementAdapter }

procedure TUniDACStatementAdapter.DoBuild(const pSQL: string; const pDataSet: TUniQuery; const pAutoCommit: Boolean);
var
  vDataSet: TUniQuery;
begin
  inherited;
  if (pDataSet = nil) then
    vDataSet := TUniQuery.Create(nil)
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

function TUniDACStatementAdapter.DoBuildAsDataSet(const pSQL: string;
  const pFetchRows: Integer): TUniQuery;
begin
  Result := TUniQuery.Create(nil);
  Result.Connection := GetConnection.GetComponent.GetConnection;
  if (pFetchRows > 0) then
  begin
    Result.SpecificOptions.Values['FetchAll'] := 'False';
    Result.FetchRows := pFetchRows;
  end;
  Result.SQL.Add(pSQL);
  Result.Prepare;
  Result.Open;
end;

function TUniDACStatementAdapter.DoBuildAsFloat(
  const pSQL: string): Double;
var
  vDataSet: TUniQuery;
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

function TUniDACStatementAdapter.DoBuildAsInteger(
  const pSQL: string): Integer;
var
  vDataSet: TUniQuery;
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

function TUniDACStatementAdapter.DoBuildAsIterator(const pSQL: string;
  const pFetchRows: Integer): IIterator<TUniQuery>;
begin
  Result := TIteratorFactory<TUniQuery>.Get(DoBuildAsDataSet(pSQL, 0), True);
end;

function TUniDACStatementAdapter.DoBuildAsIteratorDataSet(const pSQL: string): IIteratorDataSet;
begin
  Result := TIteratorDataSetFactory.Get(DoBuildAsDataSet(pSQL, 0), True);
end;

function TUniDACStatementAdapter.DoBuildAsString(
  const pSQL: string): string;
var
  vDataSet: TUniQuery;
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

procedure TUniDACStatementAdapter.DoBuildInDataSet(const pSQL: string; const pDataSet: TUniQuery);
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

procedure TUniDACStatementAdapter.DoBuildInIterator(const pSQL: string;
  const pIterator: IIterator<TUniQuery>);
begin
  inherited;
  DoBuildInDataSet(pSQL, pIterator.GetDataSet);
end;

{ TUniDACConnectionAdapter }

procedure TUniDACConnectionAdapter.DoAfterBuild;
begin
  inherited;
  FDefaultAutoCommit := GetComponent.GetConnection.AutoCommit;
end;

procedure TUniDACConnectionAdapter.DoCommit;
begin
  inherited;
  if (GetComponent.GetConnection.ProviderName = cInterBaseProviderName) then
    GetComponent.GetConnection.CommitRetaining
  else
    GetComponent.GetConnection.Commit();
  GetComponent.GetConnection.AutoCommit := FDefaultAutoCommit;
end;

procedure TUniDACConnectionAdapter.DoConnect;
begin
  inherited;
  GetComponent.GetConnection.Open();
end;

procedure TUniDACConnectionAdapter.DoCreateStatement;
begin
  inherited;
  SetStatement(TUniDACStatementAdapter.Create(Self));
end;

procedure TUniDACConnectionAdapter.DoDisconect;
begin
  inherited;
  GetComponent.GetConnection.Close();
end;

function TUniDACConnectionAdapter.DoInTransaction: Boolean;
begin
  Result := GetComponent.GetConnection.InTransaction;
end;

procedure TUniDACConnectionAdapter.DoRollback;
begin
  inherited;
  if (GetComponent.GetConnection.ProviderName = cInterBaseProviderName) then
    GetComponent.GetConnection.RollbackRetaining
  else
    GetComponent.GetConnection.Rollback;
  GetComponent.GetConnection.AutoCommit := FDefaultAutoCommit;
end;

procedure TUniDACConnectionAdapter.DoStartTransaction;
begin
  inherited;
  GetComponent.GetConnection.AutoCommit := False;
  if not InTransaction then
    GetComponent.GetConnection.StartTransaction();
end;

{ TUniDACSingletonConnectionAdapter }

class constructor TUniDACSingletonConnectionAdapter.Create;
begin
  SingletonConnectionAdapter := nil;
end;

class destructor TUniDACSingletonConnectionAdapter.Destroy;
begin
  if (SingletonConnectionAdapter <> nil) then
    FreeAndNil(SingletonConnectionAdapter);
end;

class function TUniDACSingletonConnectionAdapter.Get: TUniDACConnectionAdapter;
begin
  if (SingletonConnectionAdapter = nil) then
  begin
    TGlobalCriticalSection.GetInstance.Enter;
    try
      SingletonConnectionAdapter := TUniDACConnectionAdapter.Create;
    finally
      TGlobalCriticalSection.GetInstance.Leave;
    end;
  end;
  Result := SingletonConnectionAdapter;
end;

{ TUniDACControllerAdapter }

procedure TUniDACControllerAdapter.DoChangeSQLTextOfDataSet;
begin
  inherited;
  GetDataSet.SQL.Clear;
  GetDataSet.SQL.Add(GetSQLParserSelect.GetSQLText);
end;

procedure TUniDACControllerAdapter.DoClose;
begin
  inherited;
  GetDataSet.Close();
end;

procedure TUniDACControllerAdapter.DoConfigureDataSetConnection;
begin
  inherited;
  GetDataSet.Connection := GetConnection.GetComponent.GetConnection;
end;

procedure TUniDACControllerAdapter.DoCreateDetails;
begin
  inherited;
  SetDetails(TUniDACDetailsAdapter.Create(Self));
end;

function TUniDACControllerAdapter.DoGetSQLTextOfDataSet: string;
begin
  inherited;
  Result := GetDataSet.SQL.Text;
end;

procedure TUniDACControllerAdapter.DoOpen;
begin
  inherited;
  GetDataSet.Open();
end;

{ TUniDACDetailsAdapter }

procedure TUniDACDetailsAdapter.DoCloseAll;
var
  vPair: TPair<string, TDetailProperties>;
begin
  inherited;
  for vPair in GetDetailDictionary do
    vPair.Value.Obj.GetDataSet.Close;
end;

procedure TUniDACDetailsAdapter.DoDisableAllControls;
var
  vPair: TPair<string, TDetailProperties>;
begin
  inherited;
  for vPair in GetDetailDictionary do
    vPair.Value.Obj.GetDataSet.DisableControls();
end;

procedure TUniDACDetailsAdapter.DoEnableAllControls;
var
  vPair: TPair<string, TDetailProperties>;
begin
  inherited;
  for vPair in GetDetailDictionary do
    vPair.Value.Obj.GetDataSet.EnableControls();
end;

procedure TUniDACDetailsAdapter.DoLinkDetailOnMasterDataSource(
  const pDetail: TUniDACControllerAdapter);
begin
  inherited;
  pDetail.GetDataSet.MasterSource := GetMasterDataSource();
end;

procedure TUniDACDetailsAdapter.DoLinkMasterController(
  const pDetailController: TUniDACControllerAdapter);
begin
  inherited;
  pDetailController.SetMaster<TUniDACControllerAdapter>(GetMasterController());
end;

procedure TUniDACDetailsAdapter.DoLinkMasterDataSource(
  const pMasterController: TUniDACControllerAdapter);
begin
  inherited;
  GetMasterDataSource.DataSet := pMasterController.GetDataSet;
end;

procedure TUniDACDetailsAdapter.DoOpenAll;
var
  vPair: TPair<string, TDetailProperties>;
begin
  inherited;
  for vPair in GetDetailDictionary do
    vPair.Value.Obj.GetDataSet.Open();
end;

end.
