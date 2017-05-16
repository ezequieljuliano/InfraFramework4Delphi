unit InfraFwk4D.Persistence.Template.FireDAC;

interface

uses
  System.SysUtils,
  System.Classes,
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
  InfraFwk4D.DataSet.Iterator,
  InfraFwk4D.Persistence,
  InfraFwk4D.Persistence.Adapter.FireDAC;

type

  TPersistenceTemplateFireDAC = class(TDataModule)
  private
    fSession: IDBSession<TFDConnection, TFDQuery>;
    fQueryChangers: TDictionary<string, IDBQueryChanger<TFDQuery>>;
  protected
    function GetSession: IDBSession<TFDConnection, TFDQuery>;
    function GetQueryChangers: TDictionary<string, IDBQueryChanger<TFDQuery>>;

    procedure Setup; virtual;

    function QueryChanger(const dataSet: TFDQuery): IDBQueryChanger<TFDQuery>; overload;
    function QueryChanger(const dataSetName: string): IDBQueryChanger<TFDQuery>; overload;

    function NewIterator(const dataSet: TFDQuery): IDataSetIterator<TFDQuery>; overload;
    function NewIterator(const dataSetName: string): IDataSetIterator<TFDQuery>; overload;
  public
    constructor Create(const session: IDBSession<TFDConnection, TFDQuery>); reintroduce;
    destructor Destroy; override;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}

{ TPersistenceTemplateFireDAC }

destructor TPersistenceTemplateFireDAC.Destroy;
begin
  if Assigned(fQueryChangers) then
    fQueryChangers.Free;
  inherited Destroy;
end;

constructor TPersistenceTemplateFireDAC.Create(const session: IDBSession<TFDConnection, TFDQuery>);
begin
  inherited Create(nil);
  fSession := session;
  fQueryChangers := nil;
  Setup;
end;

function TPersistenceTemplateFireDAC.GetSession: IDBSession<TFDConnection, TFDQuery>;
begin
  if not Assigned(fSession) then
    raise EPersistenceException.CreateFmt('Database Session not defined in %s!', [Self.ClassName]);
  Result := fSession;
end;

function TPersistenceTemplateFireDAC.NewIterator(const dataSet: TFDQuery): IDataSetIterator<TFDQuery>;
begin
  Result := TDataSetIterator<TFDQuery>.Create(dataSet, False);
end;

function TPersistenceTemplateFireDAC.NewIterator(const dataSetName: string): IDataSetIterator<TFDQuery>;
begin
  Result := NewIterator(FindComponent(dataSetName) as TFDQuery);
end;

function TPersistenceTemplateFireDAC.GetQueryChangers: TDictionary<string, IDBQueryChanger<TFDQuery>>;
begin
  if not Assigned(fQueryChangers) then
    fQueryChangers := TDictionary < string, IDBQueryChanger < TFDQuery >>.Create;
  Result := fQueryChangers;
end;

procedure TPersistenceTemplateFireDAC.Setup;
var
  i: Integer;
  ctx: TRttiContext;
  t: TRttiType;
  p: TRttiProperty;
begin
  ctx := TRttiContext.Create;
  try
    for i := 0 to Pred(ComponentCount) do
      if Components[i].ClassName.StartsWith('TFD') then
      begin
        t := ctx.GetType(Components[i].ClassType);
        p := t.GetProperty('Connection');
        if Assigned(p) and p.GetValue(Components[i]).IsType<TFDConnection> and p.IsWritable then
        begin
          p.SetValue(Components[i], fSession.GetConnection.GetComponent);
          if Components[i].ClassName.Equals('TFDQuery') then
            GetQueryChangers.AddOrSetValue(Components[i].Name, TFireDACQueryChangerAdapter.Create(Components[i] as TFDQuery));
        end;
      end;
  finally
    ctx.Free;
  end;
end;

function TPersistenceTemplateFireDAC.QueryChanger(const dataSet: TFDQuery): IDBQueryChanger<TFDQuery>;
begin
  Result := QueryChanger(dataSet.Name);
end;

function TPersistenceTemplateFireDAC.QueryChanger(const dataSetName: string): IDBQueryChanger<TFDQuery>;
begin
  Result := GetQueryChangers.Items[dataSetName];
end;

end.
