unit InfraFwk4D.Persistence.Adapter.ADO;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Rtti,
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

  TADOStatementAdapter = class(TDriverStatementAdapter<TADOConnection>)
  private
    { private declarations }
  protected
    procedure DataSetPreparation(const dataSet: TDataSet); override;
    procedure Execute(const commit: Boolean); override;

    function AsDataSet(const fetchRows: Integer): TDataSet; override;
  public
    { public declarations }
  end;

  TADOSessionAdapter = class(TDriverSessionAdapter<TADOConnection>)
  private
    { private declarations }
  protected
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

  TADOMetaDataInfoAdapter = class(TDriverMetaDataInfoAdapter<TADOConnection>)
  private
    function GetMetaInfo(const kind: TObject): IDataSetIterator; overload;
    function GetMetaInfo(const kind: TObject; const objectName: string): IDataSetIterator; overload;
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
  dataSet := TADOQuery.Create(nil);
  DataSetPreparation(dataSet);
  dataSet.Open;
  Result := dataSet;
end;

procedure TADOStatementAdapter.Execute(const commit: Boolean);
var
  dataSet: TADOQuery;
begin
  if (GetPreparedDataSet <> nil) then
    dataSet := GetPreparedDataSet as TADOQuery
  else
    dataSet := TADOQuery.Create(nil);
  try
    DataSetPreparation(dataSet);
    if commit then
    begin
      GetConnection.GetComponent.BeginTrans;
      try
        dataSet.ExecSQL;
        GetConnection.GetComponent.CommitTrans;
      except
        GetConnection.GetComponent.RollbackTrans;
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

procedure TADOStatementAdapter.DataSetPreparation(const dataSet: TDataSet);
var
  param: TPair<string, TValue>;
  typedDataSet: TADOQuery;
begin
  typedDataSet := dataSet as TADOQuery;

  if typedDataSet.Active then
    typedDataSet.Close;

  typedDataSet.Connection := GetConnection.GetComponent;
  typedDataSet.SQL.Text := GetQuery;

  for param in GetParams do
    typedDataSet.Parameters.ParamByName(param.Key).Value := param.Value.AsVariant;

  typedDataSet.Prepared := True;;
end;

{ TADOSessionAdapter }

function TADOSessionAdapter.NewStatement: IDBStatement;
begin
  Result := TADOStatementAdapter.Create(GetConnection);
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
  raise Exception.Create('Not Implemented!');
end;

function TADOMetaDataInfoAdapter.GetForeignKeys(const tableName: string): IDataSetIterator;
begin
  raise Exception.Create('Not Implemented!');
end;

function TADOMetaDataInfoAdapter.GetGenerators: IDataSetIterator;
begin
  raise Exception.Create('Not Implemented!');
end;

function TADOMetaDataInfoAdapter.GetIndexes(const tableName: string): IDataSetIterator;
begin
  raise Exception.Create('Not Implemented!');
end;

function TADOMetaDataInfoAdapter.GetMetaInfo(const kind: TObject): IDataSetIterator;
begin
  raise Exception.Create('Not Implemented!');
end;

function TADOMetaDataInfoAdapter.GetMetaInfo(const kind: TObject; const objectName: string): IDataSetIterator;
begin
  raise Exception.Create('Not Implemented!');
end;

function TADOMetaDataInfoAdapter.GetPrimaryKeys(const tableName: string): IDataSetIterator;
begin
  raise Exception.Create('Not Implemented!');
end;

function TADOMetaDataInfoAdapter.GetTables: IDataSetIterator;
begin
  raise Exception.Create('Not Implemented!');
end;

end.
