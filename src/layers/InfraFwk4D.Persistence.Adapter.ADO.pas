unit InfraFwk4D.Persistence.Adapter.ADO;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Rtti,
  System.Classes,
  Data.DB,
  Data.Win.ADODB,
  InfraFwk4D.Persistence,
  InfraFwk4D.Persistence.Base,
  InfraFwk4D.DataSet.Iterator;

type

  TADOConnectionAdapter = class(TDriverConnectionAdapter<TADOConnection>)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  TADOStatementAdapter = class(TDriverStatementAdapter)
  private
    procedure ValidateDataSetType(const dataSet: TDataSet);
  protected
    procedure DataSetPreparation(const dataSet: TDataSet); override;
    procedure Execute(const commit: Boolean); override;

    function AsDataSet(const fetchRows: Integer): TDataSet; override;
  public
    { public declarations }
  end;

  TADOTransactionAdapter = class(TDriverTransactionAdapter<TADOConnection>)
  private
    { private declarations }
  protected
    procedure Commit; override;
    procedure Rollback; override;
    function InTransaction: Boolean; override;
  public
    { public declarations }
  end;

  TADOSessionAdapter = class(TDriverSessionAdapter<TADOConnection>)
  private
    { private declarations }
  protected
    function BeginTransaction: IDBTransaction; override;
    function NewStatement: IDBStatement; override;
  public
    { public declarations }
  end;

  TADOQueryChangerAdapter = class(TDriverQueryChangerAdapter<TADOQuery>)
  private
    { private declarations }
  protected
    function GetDataSetQueryText: string; override;
    procedure SetDataSetQueryText(const value: string); override;
  public
    { public declarations }
  end;

  TADODelegateAdapter = class(TDriverDelegateAdapter<TADOQuery>)
  private
    { private declarations }
  protected
    procedure Setup(const dao: TDataModule); override;
  public
    { public declarations }
  end;

  TADOMetaDataInfoAdapter = class(TDriverMetaDataInfoAdapter<TADOConnection>)
  private
    { private declarations }
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

{ TADOStatementAdapter }

function TADOStatementAdapter.AsDataSet(const fetchRows: Integer): TDataSet;
var
  dataSet: TADOQuery;
begin
  if (fetchRows > 0) then
    raise EPersistenceException.Create('ADO Statement Adapter does not work with fetch rows.');

  dataSet := TADOQuery.Create(nil);
  DataSetPreparation(dataSet);
  dataSet.Open;
  Result := dataSet;
end;

procedure TADOStatementAdapter.Execute(const commit: Boolean);
var
  dataSet: TADOQuery;
  transaction: IDBTransaction;
begin
  if (GetPreparedDataSet <> nil) then
  begin
    ValidateDataSetType(GetPreparedDataSet);
    dataSet := GetPreparedDataSet as TADOQuery;
  end
  else
    dataSet := TADOQuery.Create(nil);
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

procedure TADOStatementAdapter.ValidateDataSetType(const dataSet: TDataSet);
begin
  if not(dataSet is TADOQuery) then
    raise EPersistenceException.CreateFmt('The DataSet can not be prepared because the class %s is not valid for preparation.', [dataSet.ClassName]);
end;

procedure TADOStatementAdapter.DataSetPreparation(const dataSet: TDataSet);
var
  param: TPair<string, TValue>;
  typedDataSet: TADOQuery;
begin
  ValidateDataSetType(dataSet);

  typedDataSet := dataSet as TADOQuery;
  typedDataSet.Close;
  typedDataSet.Connection := (GetSession.GetOwner as IDBConnection<TADOConnection>).GetComponent;
  typedDataSet.SQL.Text := GetQuery;

  for param in GetParams do
    typedDataSet.Parameters.ParamByName(param.Key).Value := param.Value.AsVariant;

  typedDataSet.Prepared := True;
end;

{ TADOTransactionAdapter }

procedure TADOTransactionAdapter.Commit;
begin
  if Assigned(Transaction) then
    Transaction.CommitTrans;
end;

function TADOTransactionAdapter.InTransaction: Boolean;
begin
  Result := Assigned(Transaction) and Transaction.InTransaction;
end;

procedure TADOTransactionAdapter.Rollback;
begin
  if Assigned(Transaction) then
    Transaction.RollbackTrans;
end;

{ TADOSessionAdapter }

function TADOSessionAdapter.BeginTransaction: IDBTransaction;
begin
  Result := nil;
  if not GetConnection.GetComponent.InTransaction then
  begin
    GetConnection.GetComponent.BeginTrans;
    Result := TADOTransactionAdapter.Create(GetConnection.GetComponent);
  end;
end;

function TADOSessionAdapter.NewStatement: IDBStatement;
begin
  Result := TADOStatementAdapter.Create(Self);
end;

{ TADOQueryChangerAdapter }

function TADOQueryChangerAdapter.GetDataSetQueryText: string;
begin
  Result := GetDataSet.SQL.Text;
end;

procedure TADOQueryChangerAdapter.SetDataSetQueryText(const value: string);
begin
  inherited;
  GetDataSet.SQL.Text := value;
end;

{ TADOMetaDataInfoAdapter }

function TADOMetaDataInfoAdapter.GetFields(const tableName: string): IDataSetIterator;
begin
  raise EPersistenceException.Create('Not Implemented!');
end;

function TADOMetaDataInfoAdapter.GetForeignKeys(const tableName: string): IDataSetIterator;
begin
  raise EPersistenceException.Create('Not Implemented!');
end;

function TADOMetaDataInfoAdapter.GetGenerators: IDataSetIterator;
begin
  raise EPersistenceException.Create('Not Implemented!');
end;

function TADOMetaDataInfoAdapter.GetIndexes(const tableName: string): IDataSetIterator;
begin
  raise EPersistenceException.Create('Not Implemented!');
end;

function TADOMetaDataInfoAdapter.GetPrimaryKeys(const tableName: string): IDataSetIterator;
begin
  raise EPersistenceException.Create('Not Implemented!');
end;

function TADOMetaDataInfoAdapter.GetTables: IDataSetIterator;
begin
  raise EPersistenceException.Create('Not Implemented!');
end;

{ TADODelegateAdapter }

procedure TADODelegateAdapter.Setup(const dao: TDataModule);
var
  i: Integer;
  ctx: TRttiContext;
  t: TRttiType;
  p: TRttiProperty;
begin
  ctx := TRttiContext.Create;
  try
    for i := 0 to Pred(dao.ComponentCount) do
    begin
      t := ctx.GetType(dao.Components[i].ClassType);
      p := t.GetProperty('Connection');
      if Assigned(p) and p.GetValue(dao.Components[i]).IsType<TADOConnection> and p.IsWritable then
      begin
        p.SetValue(dao.Components[i], (GetSession.GetOwner as IDBConnection<TADOConnection>).GetComponent);
        if dao.Components[i] is TADOQuery then
          GetQueryChangers.AddOrSetValue(dao.Components[i].Name, TADOQueryChangerAdapter.Create(dao.Components[i] as TADOQuery));
      end;
    end;
  finally
    ctx.Free;
  end;
end;

end.
