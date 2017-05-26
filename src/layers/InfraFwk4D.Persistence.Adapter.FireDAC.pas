unit InfraFwk4D.Persistence.Adapter.FireDAC;

interface

uses
  System.Classes,
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

  TFireDACStatementAdapter = class(TDriverStatementAdapter)
  private
    procedure ValidateDataSetType(const dataSet: TDataSet);
  protected
    procedure DataSetPreparation(const dataSet: TDataSet); override;
    procedure Execute(const commit: Boolean); override;

    function AsDataSet(const fetchRows: Integer): TDataSet; override;
  public
    { public declarations }
  end;

  TFireDACTransactionAdapter = class(TDriverTransactionAdapter<TFDTransaction>)
  private
    { private declarations }
  protected
    procedure Commit; override;
    procedure Rollback; override;
    function InTransaction: Boolean; override;
  public
    { public declarations }
  end;

  TFireDACSessionAdapter = class(TDriverSessionAdapter<TFDConnection>)
  private
    { private declarations }
  protected
    function BeginTransaction: IDBTransaction; override;
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

  TFireDACDelegateAdapter = class(TDriverDelegateAdapter<TFDQuery>)
  private
    { private declarations }
  protected
    procedure Setup(const dao: TDataModule); override;
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
  dataSet: TFDCustomQuery;
  transaction: IDBTransaction;
begin
  if (GetPreparedDataSet <> nil) then
  begin
    ValidateDataSetType(GetPreparedDataSet);
    dataSet := GetPreparedDataSet as TFDCustomQuery;
  end
  else
    dataSet := TFDQuery.Create(nil);
  try
    DataSetPreparation(dataSet);
    if commit then
    begin
      transaction := GetSession.BeginTransaction;
      try
        dataSet.ExecSQL;
        transaction.Commit;
      except
        transaction.Rollback;
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

procedure TFireDACStatementAdapter.ValidateDataSetType(const dataSet: TDataSet);
begin
  if not(dataSet is TFDCustomQuery) then
    raise EPersistenceException.CreateFmt('The DataSet can not be prepared because the class %s is not valid for preparation.', [dataSet.ClassName]);
end;

procedure TFireDACStatementAdapter.DataSetPreparation(const dataSet: TDataSet);
var
  param: TPair<string, TValue>;
  typedDataSet: TFDCustomQuery;
begin
  ValidateDataSetType(dataSet);

  typedDataSet := dataSet as TFDCustomQuery;
  typedDataSet.Close;
  typedDataSet.Connection := (GetSession.GetOwner as IDBConnection<TFDConnection>).GetComponent;
  typedDataSet.SQL.Text := GetQuery;

  for param in GetParams do
    typedDataSet.ParamByName(param.Key).Value := param.Value.AsVariant;

  typedDataSet.Prepare;
end;

{ TFireDACTransactionAdapter }

procedure TFireDACTransactionAdapter.Commit;
begin
  if Assigned(Transaction) then
    Transaction.Commit;
end;

function TFireDACTransactionAdapter.InTransaction: Boolean;
begin
  Result := Assigned(Transaction) and Transaction.Active;
end;

procedure TFireDACTransactionAdapter.Rollback;
begin
  if Assigned(Transaction) then
    Transaction.Rollback;
end;

{ TFireDACSessionAdapter }

function TFireDACSessionAdapter.BeginTransaction: IDBTransaction;
var
  transaction: TFDTransaction;
begin
  Result := nil;
  if not GetConnection.GetComponent.InTransaction or GetConnection.GetComponent.TxOptions.EnableNested then
  begin
    transaction := TFDTransaction.Create(nil);
    transaction.Connection := GetConnection.GetComponent;
    transaction.StartTransaction;
    Result := TFireDACTransactionAdapter.Create(transaction);
  end;
end;

function TFireDACSessionAdapter.NewStatement: IDBStatement;
begin
  Result := TFireDACStatementAdapter.Create(Self);
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
  ds.Connection := (GetSession.GetOwner as IDBConnection<TFDConnection>).GetComponent;
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

{ TFireDACDelegateAdapter }

procedure TFireDACDelegateAdapter.Setup(const dao: TDataModule);
var
  i: Integer;
  ctx: TRttiContext;
  t: TRttiType;
  p: TRttiProperty;
begin
  ctx := TRttiContext.Create;
  try
    for i := 0 to Pred(dao.ComponentCount) do
      if dao.Components[i].ClassName.StartsWith('TFD') then
      begin
        t := ctx.GetType(dao.Components[i].ClassType);
        p := t.GetProperty('Connection');
        if Assigned(p) and p.GetValue(dao.Components[i]).IsType<TFDConnection> and p.IsWritable then
        begin
          p.SetValue(dao.Components[i], (GetSession.GetOwner as IDBConnection<TFDConnection>).GetComponent);
          if dao.Components[i] is TFDCustomQuery then
            GetQueryChangers.AddOrSetValue(dao.Components[i].Name, TFireDACQueryChangerAdapter.Create(dao.Components[i] as TFDQuery));
        end;
      end;
  finally
    ctx.Free;
  end;
end;

end.
