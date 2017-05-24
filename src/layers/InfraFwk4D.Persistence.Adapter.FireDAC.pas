unit InfraFwk4D.Persistence.Adapter.FireDAC;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Rtti,
  Data.DB,
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

  TFireDACStatementAdapter = class(TDriverStatementAdapter<TFDConnection>)
  private
    { private declarations }
  protected
    procedure DataSetPreparation(const dataSet: TDataSet); override;
    procedure Execute(const commit: Boolean); override;

    function AsDataSet(const fetchRows: Integer): TDataSet; override;
  public
    { public declarations }
  end;

  TFireDACSessionAdapter = class(TDriverSessionAdapter<TFDConnection>)
  private
    { private declarations }
  protected
    function NewStatement: IDBStatement; override;
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

  TFireDACMetaDataInfoAdapter = class(TDriverMetaDataInfoAdapter<TFDConnection>)
  private
    function GetMetaInfo(const kind: TFDPhysMetaInfoKind): IDataSetIterator; overload;
    function GetMetaInfo(const kind: TFDPhysMetaInfoKind; const objectName: string): IDataSetIterator; overload;
  protected
    function GetTables: IDataSetIterator; override;
    function GetFields(const tableName: string): IDataSetIterator; override;
    function GetPrimaryKeys(const tableName: string): IDataSetIterator; override;
    function GetIndexes(const tableName: string): IDataSetIterator; override;
    function GetForeignKeys(const tableName: string): IDataSetIterator; override;
    function GetGenerators: IDataSetIterator; override;
  public
    { public declarations }
  end;

implementation

{ TFireDACStatementAdapter }

function TFireDACStatementAdapter.AsDataSet(const fetchRows: Integer): TDataSet;
var
  dataSet: TFDQuery;
begin
  dataSet := TFDQuery.Create(nil);
  DataSetPreparation(dataSet);
  if (fetchRows > 0) then
  begin
    dataSet.FetchOptions.Mode := fmOnDemand;
    dataSet.FetchOptions.RowsetSize := fetchRows;
  end
  else
  begin
    dataSet.FetchOptions.Mode := fmAll;
    dataSet.FetchOptions.RowsetSize := -1;
  end;
  dataSet.Open;
  Result := dataSet;
end;

procedure TFireDACStatementAdapter.Execute(const commit: Boolean);
var
  dataSet: TFDQuery;
begin
  if (GetPreparedDataSet <> nil) then
    dataSet := GetPreparedDataSet as TFDQuery
  else
    dataSet := TFDQuery.Create(nil);
  try
    DataSetPreparation(dataSet);
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
    if (GetPreparedDataSet <> nil) then
      SetPreparedDataSet(nil)
    else
      dataSet.Free;
  end;
end;

procedure TFireDACStatementAdapter.DataSetPreparation(const dataSet: TDataSet);
var
  param: TPair<string, TValue>;
  typedDataSet: TFDQuery;
begin
  typedDataSet := dataSet as TFDQuery;

  if typedDataSet.Active then
    typedDataSet.Close;

  typedDataSet.Connection := GetConnection.GetComponent;
  typedDataSet.SQL.Text := GetQuery;

  for param in GetParams do
    typedDataSet.ParamByName(param.Key).Value := param.Value.AsVariant;

  typedDataSet.Prepare;
end;

{ TFireDACSessionAdapter }

function TFireDACSessionAdapter.NewStatement: IDBStatement;
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

function TFireDACMetaDataInfoAdapter.GetFields(const tableName: string): IDataSetIterator;
begin
  Result := GetMetaInfo(mkTableFields, tableName);
end;

function TFireDACMetaDataInfoAdapter.GetForeignKeys(const tableName: string): IDataSetIterator;
begin
  Result := GetMetaInfo(mkForeignKeys, tableName);
end;

function TFireDACMetaDataInfoAdapter.GetGenerators: IDataSetIterator;
begin
  Result := GetMetaInfo(mkGenerators);
end;

function TFireDACMetaDataInfoAdapter.GetIndexes(const tableName: string): IDataSetIterator;
begin
  Result := GetMetaInfo(mkIndexes, tableName);
end;

function TFireDACMetaDataInfoAdapter.GetMetaInfo(const kind: TFDPhysMetaInfoKind): IDataSetIterator;
begin
  Result := GetMetaInfo(kind, EmptyStr);
end;

function TFireDACMetaDataInfoAdapter.GetMetaInfo(const kind: TFDPhysMetaInfoKind; const objectName: string): IDataSetIterator;
var
  ds: TFDMetaInfoQuery;
begin
  ds := TFDMetaInfoQuery.Create(nil);
  ds.Connection := GetSession.GetConnection.GetComponent;
  ds.MetaInfoKind := kind;
  ds.ObjectName := objectName;
  ds.Open;
  Result := TDataSetIterator.Create(ds, True);
end;

function TFireDACMetaDataInfoAdapter.GetPrimaryKeys(const tableName: string): IDataSetIterator;
begin
  Result := GetMetaInfo(mkPrimaryKey, tableName);
end;

function TFireDACMetaDataInfoAdapter.GetTables: IDataSetIterator;
begin
  Result := GetMetaInfo(mkTables);
end;

end.
