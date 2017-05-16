unit InfraFwk4D.Persistence.Adapter.FireDAC;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Rtti,
  FireDAC.DApt,
  FireDAC.Comp.Client,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.Phys.Intf,
  InfraFwk4D.Persistence,
  InfraFwk4D.Persistence.Base,
  InfraFwk4D.DataSet.Iterator;

type

  TFireDACConnectionAdapter = class(TDriverConnectionAdapter<TFDConnection>)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  TFireDACStatementAdapter = class(TDriverStatementAdapter<TFDQuery, TFDConnection>)
  private
    fPreparedDataSet: TFDQuery;
    procedure PrepareDataSet(const dataSet: TFDQuery);
  protected
    function Prepare(const dataSet: TFDQuery): IDBStatement<TFDQuery>; override;

    procedure Open(const dataSet: TFDQuery); override;
    procedure Execute(const commit: Boolean); override;

    function AsDataSet(const fetchRows: Integer): TFDQuery; override;
  public
    procedure AfterConstruction; override;
  end;

  TFireDACSessionAdapter = class(TDriverSessionAdapter<TFDConnection, TFDQuery>)
  private
    { private declarations }
  protected
    function NewStatement: IDBStatement<TFDQuery>; override;
  public
    { public declarations }
  end;

  TFireDACQueryChangerAdapter = class(TDriverQueryChangerAdapter<TFDQuery>)
  private
    { private declarations }
  protected
    function GetDataSetQueryText: string; override;
    procedure SetDataSetQueryText(const value: string); override;
  public
    { public declarations }
  end;

  TFireDACMetaDataInfoAdapter = class(TDriverMetaDataInfoAdapter<TFDMetaInfoQuery, TFDConnection>)
  private
    function GetMetaInfo(const kind: TFDPhysMetaInfoKind): IDataSetIterator<TFDMetaInfoQuery>; overload;
    function GetMetaInfo(const kind: TFDPhysMetaInfoKind; const objectName: string): IDataSetIterator<TFDMetaInfoQuery>; overload;
  protected
    function GetTables: IDataSetIterator<TFDMetaInfoQuery>; override;
    function GetFields(const tableName: string): IDataSetIterator<TFDMetaInfoQuery>; override;
    function GetPrimaryKeys(const tableName: string): IDataSetIterator<TFDMetaInfoQuery>; override;
    function GetIndexes(const tableName: string): IDataSetIterator<TFDMetaInfoQuery>; override;
    function GetForeignKeys(const tableName: string): IDataSetIterator<TFDMetaInfoQuery>; override;
    function GetGenerators: IDataSetIterator<TFDMetaInfoQuery>; override;
  public
    { public declarations }
  end;

implementation

{ TFireDACStatementAdapter }

procedure TFireDACStatementAdapter.AfterConstruction;
begin
  inherited AfterConstruction;
  fPreparedDataSet := nil;
end;

function TFireDACStatementAdapter.AsDataSet(const fetchRows: Integer): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  PrepareDataSet(Result);
  if (fetchRows > 0) then
  begin
    Result.FetchOptions.Mode := fmOnDemand;
    Result.FetchOptions.RowsetSize := fetchRows;
  end
  else
  begin
    Result.FetchOptions.Mode := fmAll;
    Result.FetchOptions.RowsetSize := -1;
  end;
  Result.Open;
end;

procedure TFireDACStatementAdapter.Execute(const commit: Boolean);
var
  dataSet: TFDQuery;
begin
  if Assigned(fPreparedDataSet) then
    dataSet := fPreparedDataSet
  else
    dataSet := TFDQuery.Create(nil);
  try
    PrepareDataSet(dataSet);
    if commit then
    begin
      GetConnection.GetComponent.StartTransaction;
      try
        dataSet.ExecSQL;
        GetConnection.GetComponent.Commit;
      except
        GetConnection.GetComponent.Rollback;
        raise;
      end;
    end
    else
      dataSet.ExecSQL;
  finally
    if Assigned(fPreparedDataSet) then
      fPreparedDataSet := nil
    else
      dataSet.Free;
  end;
end;

procedure TFireDACStatementAdapter.Open(const dataSet: TFDQuery);
begin
  PrepareDataSet(dataSet);
  dataSet.Open;
end;

function TFireDACStatementAdapter.Prepare(const dataSet: TFDQuery): IDBStatement<TFDQuery>;
begin
  fPreparedDataSet := dataSet;
  Result := Self;
end;

procedure TFireDACStatementAdapter.PrepareDataSet(const dataSet: TFDQuery);
var
  p: TPair<string, TValue>;
begin
  if dataSet.Active then
    dataSet.Close;

  dataSet.Connection := GetConnection.GetComponent;
  dataSet.SQL.Text := GetQuery;

  for p in GetParams do
    dataSet.ParamByName(p.Key).Value := p.Value.AsVariant;

  dataSet.Prepare;
end;

{ TFireDACSessionAdapter }

function TFireDACSessionAdapter.NewStatement: IDBStatement<TFDQuery>;
begin
  Result := TFireDACStatementAdapter.Create(GetConnection);
end;

{ TFireDACQueryChangerAdapter }

function TFireDACQueryChangerAdapter.GetDataSetQueryText: string;
begin
  Result := GetDataSet.SQL.Text;
end;

procedure TFireDACQueryChangerAdapter.SetDataSetQueryText(const value: string);
begin
  inherited;
  GetDataSet.SQL.Text := value;
end;

{ TFireDACMetaDataInfoAdapter }

function TFireDACMetaDataInfoAdapter.GetFields(const tableName: string): IDataSetIterator<TFDMetaInfoQuery>;
begin
  Result := GetMetaInfo(mkTableFields, tableName);
end;

function TFireDACMetaDataInfoAdapter.GetForeignKeys(const tableName: string): IDataSetIterator<TFDMetaInfoQuery>;
begin
  Result := GetMetaInfo(mkForeignKeys, tableName);
end;

function TFireDACMetaDataInfoAdapter.GetGenerators: IDataSetIterator<TFDMetaInfoQuery>;
begin
  Result := GetMetaInfo(mkGenerators);
end;

function TFireDACMetaDataInfoAdapter.GetIndexes(const tableName: string): IDataSetIterator<TFDMetaInfoQuery>;
begin
  Result := GetMetaInfo(mkIndexes, tableName);
end;

function TFireDACMetaDataInfoAdapter.GetMetaInfo(const kind: TFDPhysMetaInfoKind): IDataSetIterator<TFDMetaInfoQuery>;
begin
  Result := GetMetaInfo(kind, EmptyStr);
end;

function TFireDACMetaDataInfoAdapter.GetMetaInfo(const kind: TFDPhysMetaInfoKind; const objectName: string): IDataSetIterator<TFDMetaInfoQuery>;
var
  ds: TFDMetaInfoQuery;
begin
  ds := TFDMetaInfoQuery.Create(nil);
  ds.Connection := GetSession.GetConnection.GetComponent;
  ds.MetaInfoKind := kind;
  ds.ObjectName := objectName;
  ds.Open;
  Result := TDataSetIterator<TFDMetaInfoQuery>.Create(ds, True);
end;

function TFireDACMetaDataInfoAdapter.GetPrimaryKeys(const tableName: string): IDataSetIterator<TFDMetaInfoQuery>;
begin
  Result := GetMetaInfo(mkPrimaryKey, tableName);
end;

function TFireDACMetaDataInfoAdapter.GetTables: IDataSetIterator<TFDMetaInfoQuery>;
begin
  Result := GetMetaInfo(mkTables);
end;

end.
