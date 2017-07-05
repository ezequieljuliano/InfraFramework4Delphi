unit InfraFwk4D.Persistence.Template.ADO;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Rtti,
  Data.DB,
  Data.Win.ADODB,
  InfraFwk4D.DataSet.Iterator,
  InfraFwk4D.Persistence,
  InfraFwk4D.Persistence.Adapter.ADO;

type

  TPersistenceTemplateADO = class(TDataModule)
  private
    fSession: IDBSession<TADOConnection>;
    fQueryChangers: TDictionary<string, IDBQueryChanger>;
  protected
    function GetSession: IDBSession<TADOConnection>;
    function GetQueryChangers: TDictionary<string, IDBQueryChanger>;

    procedure Setup; virtual;

    function QueryChanger(const dataSet: TADOQuery): IDBQueryChanger; overload;
    function QueryChanger(const dataSetName: string): IDBQueryChanger; overload;

    function NewIterator(const dataSet: TADOQuery): IDataSetIterator; overload;
    function NewIterator(const dataSetName: string): IDataSetIterator; overload;
  public
    constructor Create(const session: IDBSession<TADOConnection>); reintroduce;
    destructor Destroy; override;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}

{ TPersistenceTemplateADO }

destructor TPersistenceTemplateADO.Destroy;
begin
  if Assigned(fQueryChangers) then
    fQueryChangers.Free;
  inherited Destroy;
end;

constructor TPersistenceTemplateADO.Create(const session: IDBSession<TADOConnection>);
begin
  inherited Create(nil);
  fSession := session;
  fQueryChangers := nil;
  Setup;
end;

function TPersistenceTemplateADO.GetSession: IDBSession<TADOConnection>;
begin
  if not Assigned(fSession) then
    raise EPersistenceException.CreateFmt('Database Session not defined in %s!', [Self.ClassName]);
  Result := fSession;
end;

function TPersistenceTemplateADO.NewIterator(const dataSet: TADOQuery): IDataSetIterator;
begin
  Result := TDataSetIterator.Create(dataSet, False);
end;

function TPersistenceTemplateADO.NewIterator(const dataSetName: string): IDataSetIterator;
begin
  Result := NewIterator(FindComponent(dataSetName) as TADOQuery);
end;

function TPersistenceTemplateADO.GetQueryChangers: TDictionary<string, IDBQueryChanger>;
begin
  if not Assigned(fQueryChangers) then
    fQueryChangers := TDictionary<string, IDBQueryChanger>.Create;
  Result := fQueryChangers;
end;

procedure TPersistenceTemplateADO.Setup;
var
  i: Integer;
  ctx: TRttiContext;
  t: TRttiType;
  p: TRttiProperty;
begin
  ctx := TRttiContext.Create;
  try
    for i := 0 to Pred(ComponentCount) do
      if Components[i].ClassName.StartsWith('TADOQ') then
      begin
        t := ctx.GetType(Components[i].ClassType);
        p := t.GetProperty('Connection');
        if Assigned(p) and p.GetValue(Components[i]).IsType<TADOConnection> and p.IsWritable then
        begin
          p.SetValue(Components[i], fSession.GetConnection.GetComponent);
          if Components[i].ClassName.Equals('TADOQuery') then
            GetQueryChangers.AddOrSetValue(Components[i].Name, TADOQueryChangerAdapter.Create(Components[i] as TADOQuery));
        end;
      end;
  finally
    ctx.Free;
  end;
end;

function TPersistenceTemplateADO.QueryChanger(const dataSet: TADOQuery): IDBQueryChanger;
begin
  Result := QueryChanger(dataSet.Name);
end;

function TPersistenceTemplateADO.QueryChanger(const dataSetName: string): IDBQueryChanger;
begin
  Result := GetQueryChangers.Items[dataSetName];
end;

end.
