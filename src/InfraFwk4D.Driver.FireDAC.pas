unit InfraFwk4D.Driver.FireDAC;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.SyncObjs,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Option,
  InfraFwk4D.Driver,
  InfraFwk4D.Iterator.DataSet;

type

  TFireDACComponentAdapter = class(TDriverComponent<TFDConnection>);

  TFireDACConnectionAdapter = class;

  TFireDACStatementAdapter = class(TDriverStatement<TFDQuery, TFireDACConnectionAdapter>)
  strict protected
    procedure DoExecute(const pQuery: string; const pDataSet: TFDQuery; const pAutoCommit: Boolean); override;

    function DoAsDataSet(const pQuery: string; const pFetchRows: Integer): TFDQuery; override;
    function DoAsIterator(const pQuery: string; const pFetchRows: Integer): IIteratorDataSet; override;
    function DoAsInteger(const pQuery: string): Integer; override;
    function DoAsFloat(const pQuery: string): Double; override;
    function DoAsString(const pQuery: string): string; override;
    function DoAsVariant(const pQuery: string): Variant; override;

    procedure DoInDataSet(const pQuery: string; const pDataSet: TFDQuery); override;
    procedure DoInIterator(const pQuery: string; const pIterator: IIteratorDataSet); override;
  end;

  TFireDACConnectionAdapter = class(TDriverConnection<TFireDACComponentAdapter, TFireDACStatementAdapter>)
  strict protected
    function DoCreateStatement(): TFireDACStatementAdapter; override;

    procedure DoConnect(); override;
    procedure DoDisconect(); override;

    function DoInTransaction(): Boolean; override;
    procedure DoStartTransaction(); override;
    procedure DoCommit(); override;
    procedure DoRollback(); override;

    procedure DoAfterBuild(); override;
  end;

  TFireDACConnectionManagerAdapter = class(TDriverConnectionManager<string, TFireDACConnectionAdapter>);

  IFireDACPersistenceAdapter = interface(IDriverPersistence<TFireDACConnectionAdapter>)
    ['{35B5023D-CA6B-4006-9A07-5B34CC0AAC8C}']
  end;

  TFireDACDetailsAdapter<TFireDACPersistence: TDataModule> = class;

  TFireDACBusinessAdapter<TFireDACPersistence: TDataModule> = class(TDriverBusiness<TFireDACPersistence, TFDQuery,
    TFireDACConnectionAdapter, TFireDACDetailsAdapter<TFireDACPersistence>>)
  strict protected
    function DoCreateDetails(): TFireDACDetailsAdapter<TFireDACPersistence>; override;
    function DoGetDataSetQuery(): string; override;
    procedure DoDataSetChangeQuery(); override;
    procedure DoDataSetConfigureConnection(); override;
    procedure DoDataSetOpen(); override;
    procedure DoDataSetClose(); override;
  end;

  TFireDACDetailsAdapter<TFireDACPersistence: TDataModule> = class(TDriverDetails <string, TFireDACBusinessAdapter <TFireDACPersistence>>)
  strict protected
    procedure DoOpenAll(); override;
    procedure DoCloseAll(); override;
    procedure DoDisableAllControls(); override;
    procedure DoEnableAllControls(); override;
    procedure DoLinkMasterDataSource(const pMasterBusiness: TFireDACBusinessAdapter<TFireDACPersistence>); override;
    procedure DoLinkDetailOnMasterDataSource(const pDetail: TFireDACBusinessAdapter<TFireDACPersistence>); override;
  end;

  IFireDACSingletonConnectionAdapter = interface(IDriverSingletonConnection<TFireDACConnectionAdapter>)
    ['{1D4996C4-ADAD-489A-84FC-1D1279F5ED95}']
  end;

function FireDACSingletonConnectionAdapter(): IFireDACSingletonConnectionAdapter;

implementation

uses
  InfraFwk4D;

type

  TFireDACSingletonConnectionAdapter = class(TInterfacedObject, IFireDACSingletonConnectionAdapter)
  private
    class var SingletonConnection: IFireDACSingletonConnectionAdapter;
    class constructor Create;
    class destructor Destroy;
  private
    FConnectionAdapter: TFireDACConnectionAdapter;

    function GetInstance(): TFireDACConnectionAdapter;
  public
    constructor Create;
    destructor Destroy; override;

    property Instance: TFireDACConnectionAdapter read GetInstance;
  end;

function FireDACSingletonConnectionAdapter(): IFireDACSingletonConnectionAdapter;
begin
  Result := TFireDACSingletonConnectionAdapter.SingletonConnection;
end;

{ TFireDACStatementAdapter }

function TFireDACStatementAdapter.DoAsDataSet(const pQuery: string;
  const pFetchRows: Integer): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := GetConnection.Component.Connection;
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
  Result.SQL.Add(pQuery);
  Result.Prepare;
  Result.Open;
end;

function TFireDACStatementAdapter.DoAsFloat(const pQuery: string): Double;
var
  vIterator: IIteratorDataSet;
begin
  Result := 0;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsFloat;
end;

function TFireDACStatementAdapter.DoAsInteger(const pQuery: string): Integer;
var
  vIterator: IIteratorDataSet;
begin
  Result := 0;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsInteger;
end;

function TFireDACStatementAdapter.DoAsIterator(const pQuery: string;
  const pFetchRows: Integer): IIteratorDataSet;
begin
  Result := IteratorDataSetFactory.Build(DoAsDataSet(pQuery, pFetchRows), True);
end;

function TFireDACStatementAdapter.DoAsString(const pQuery: string): string;
var
  vIterator: IIteratorDataSet;
begin
  Result := EmptyStr;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsString;
end;

function TFireDACStatementAdapter.DoAsVariant(const pQuery: string): Variant;
var
  vIterator: IIteratorDataSet;
begin
  Result := varNull;
  vIterator := DoAsIterator(pQuery, 0);
  if not vIterator.IsEmpty then
    Result := vIterator.Fields[0].AsVariant;
end;

procedure TFireDACStatementAdapter.DoExecute(const pQuery: string; const pDataSet: TFDQuery;
  const pAutoCommit: Boolean);
var
  vDataSet: TFDQuery;
  vOwnsDataSet: Boolean;
begin
  inherited;
  if (pDataSet = nil) then
  begin
    vDataSet := TFDQuery.Create(nil);
    vOwnsDataSet := True;
  end
  else
  begin
    vDataSet := pDataSet;
    vOwnsDataSet := False;
  end;
  try
    vDataSet.Close;
    vDataSet.SQL.Clear;
    vDataSet.Connection := GetConnection.Component.Connection;
    vDataSet.SQL.Add(pQuery);
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
    if vOwnsDataSet then
      FreeAndNil(vDataSet);
  end;
end;

procedure TFireDACStatementAdapter.DoInDataSet(const pQuery: string; const pDataSet: TFDQuery);
begin
  inherited;
  if (pDataSet = nil) then
    raise EDataSetDoesNotExist.Create('DataSet does not exist!');
  pDataSet.Close;
  pDataSet.Connection := GetConnection.Component.Connection;
  pDataSet.SQL.Add(pQuery);
  pDataSet.Prepare;
  pDataSet.Open;
end;

procedure TFireDACStatementAdapter.DoInIterator(const pQuery: string;
  const pIterator: IIteratorDataSet);
begin
  inherited;
  DoInDataSet(pQuery, TFDQuery(pIterator.GetDataSet));
end;

{ TFireDACConnectionAdapter }

procedure TFireDACConnectionAdapter.DoAfterBuild;
begin
  inherited;

end;

procedure TFireDACConnectionAdapter.DoCommit;
begin
  inherited;
  Component.Connection.Commit();
end;

procedure TFireDACConnectionAdapter.DoConnect;
begin
  inherited;
  Component.Connection.Open();
end;

function TFireDACConnectionAdapter.DoCreateStatement: TFireDACStatementAdapter;
begin
  Result := TFireDACStatementAdapter.Create(Self);
end;

procedure TFireDACConnectionAdapter.DoDisconect;
begin
  inherited;
  Component.Connection.Close();
end;

function TFireDACConnectionAdapter.DoInTransaction: Boolean;
begin
  Result := Component.Connection.InTransaction;
end;

procedure TFireDACConnectionAdapter.DoRollback;
begin
  inherited;
  Component.Connection.Rollback();
end;

procedure TFireDACConnectionAdapter.DoStartTransaction;
begin
  inherited;
  Component.Connection.StartTransaction();
end;

{ TFireDACBusinessAdapter<TFireDACPersistence> }

function TFireDACBusinessAdapter<TFireDACPersistence>.DoCreateDetails: TFireDACDetailsAdapter<TFireDACPersistence>;
begin
  Result := TFireDACDetailsAdapter<TFireDACPersistence>.Create(Self);
end;

procedure TFireDACBusinessAdapter<TFireDACPersistence>.DoDataSetChangeQuery;
begin
  inherited;
  DataSet.SQL.Clear;
  DataSet.SQL.Add(GetQueryParserSelect.GetSQLText);
end;

procedure TFireDACBusinessAdapter<TFireDACPersistence>.DoDataSetClose;
begin
  inherited;
  DataSet.Close();
end;

procedure TFireDACBusinessAdapter<TFireDACPersistence>.DoDataSetConfigureConnection;
begin
  inherited;
  DataSet.Connection := GetConnection.Component.Connection;
end;

procedure TFireDACBusinessAdapter<TFireDACPersistence>.DoDataSetOpen;
begin
  inherited;
  DataSet.Open();
end;

function TFireDACBusinessAdapter<TFireDACPersistence>.DoGetDataSetQuery: string;
begin
  Result := DataSet.SQL.Text;
end;

{ TFireDACDetailsAdapter<TFireDACPersistence> }

procedure TFireDACDetailsAdapter<TFireDACPersistence>.DoCloseAll;
var
  vPair: TPair<string, TDetailProperties>;
begin
  inherited;
  for vPair in GetDetailDictionary do
  begin
    vPair.Value.Obj.DataSet.Close;
    vPair.Value.Obj.Details.CloseAll;
  end;
end;

procedure TFireDACDetailsAdapter<TFireDACPersistence>.DoDisableAllControls;
var
  vPair: TPair<string, TDetailProperties>;
begin
  inherited;
  for vPair in GetDetailDictionary do
  begin
    vPair.Value.Obj.DataSet.DisableControls;
    vPair.Value.Obj.Details.DisableAllControls;
  end;
end;

procedure TFireDACDetailsAdapter<TFireDACPersistence>.DoEnableAllControls;
var
  vPair: TPair<string, TDetailProperties>;
begin
  inherited;
  for vPair in GetDetailDictionary do
  begin
    vPair.Value.Obj.DataSet.EnableControls;
    vPair.Value.Obj.Details.EnableAllControls;
  end;
end;

procedure TFireDACDetailsAdapter<TFireDACPersistence>.DoLinkDetailOnMasterDataSource(
  const pDetail: TFireDACBusinessAdapter<TFireDACPersistence>);
begin
  inherited;
  pDetail.DataSet.MasterSource := GetMasterDataSource();
end;

procedure TFireDACDetailsAdapter<TFireDACPersistence>.DoLinkMasterDataSource(
  const pMasterBusiness: TFireDACBusinessAdapter<TFireDACPersistence>);
begin
  inherited;
  GetMasterDataSource.DataSet := pMasterBusiness.DataSet;
end;

procedure TFireDACDetailsAdapter<TFireDACPersistence>.DoOpenAll;
var
  vPair: TPair<string, TDetailProperties>;
begin
  inherited;
  for vPair in GetDetailDictionary do
  begin
    vPair.Value.Obj.DataSet.Open();
    vPair.Value.Obj.Details.OpenAll();
  end;
end;

{ TFireDACSingletonConnectionAdapter }

constructor TFireDACSingletonConnectionAdapter.Create;
begin
  FConnectionAdapter := TFireDACConnectionAdapter.Create;
end;

destructor TFireDACSingletonConnectionAdapter.Destroy;
begin
  FreeAndNil(FConnectionAdapter);
  inherited Destroy();
end;

function TFireDACSingletonConnectionAdapter.GetInstance: TFireDACConnectionAdapter;
begin
  Result := FConnectionAdapter;
end;

class constructor TFireDACSingletonConnectionAdapter.Create;
begin
  GlobalCriticalSection.Enter;
  try
    SingletonConnection := TFireDACSingletonConnectionAdapter.Create;
  finally
    GlobalCriticalSection.Leave;
  end;
end;

class destructor TFireDACSingletonConnectionAdapter.Destroy;
begin
  SingletonConnection := nil;
end;

end.
