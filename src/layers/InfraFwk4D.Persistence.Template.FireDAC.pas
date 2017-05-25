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
    fSession: IDBSession;
    fQueryChangers: TDictionary<string, IDBQueryChanger>;
  protected
    function GetSession: IDBSession;
    function GetQueryChangers: TDictionary<string, IDBQueryChanger>;

    procedure Setup; virtual;

    function QueryChanger(const dataSet: TFDQuery): IDBQueryChanger; overload;
    function QueryChanger(const dataSetName: string): IDBQueryChanger; overload;

    function NewIterator(const dataSet: TFDQuery): IDataSetIterator; overload;
    function NewIterator(const dataSetName: string): IDataSetIterator; overload;
  public
    constructor Create(const session: IDBSession); reintroduce;
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

constructor TPersistenceTemplateFireDAC.Create(const session: IDBSession);
begin
  inherited Create(nil);
  fSession := session;
  fQueryChangers := nil;
  Setup;
end;

function TPersistenceTemplateFireDAC.GetSession: IDBSession;
begin
  if not Assigned(fSession) then
    raise EPersistenceException.CreateFmt('Database Session not defined in %s!', [Self.ClassName]);
  Result := fSession;
end;

function TPersistenceTemplateFireDAC.NewIterator(const dataSet: TFDQuery): IDataSetIterator;
begin
  Result := TDataSetIterator.Create(dataSet, False);
end;

function TPersistenceTemplateFireDAC.NewIterator(const dataSetName: string): IDataSetIterator;
begin
  Result := NewIterator(FindComponent(dataSetName) as TFDQuery);
end;

function TPersistenceTemplateFireDAC.GetQueryChangers: TDictionary<string, IDBQueryChanger>;
begin
  if not Assigned(fQueryChangers) then
    fQueryChangers := TDictionary<string, IDBQueryChanger>.Create;
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
          p.SetValue(Components[i], (fSession.GetOwner as IDBConnection<TFDConnection>).GetComponent);
          if Components[i] is TFDCustomQuery then
            GetQueryChangers.AddOrSetValue(Components[i].Name, TFireDACQueryChangerAdapter.Create(Components[i] as TFDQuery));
        end;
      end;
  finally
    ctx.Free;
  end;
end;

function TPersistenceTemplateFireDAC.QueryChanger(const dataSet: TFDQuery): IDBQueryChanger;
begin
  Result := QueryChanger(dataSet.Name);
end;

function TPersistenceTemplateFireDAC.QueryChanger(const dataSetName: string): IDBQueryChanger;
begin
  Result := GetQueryChangers.Items[dataSetName];
end;

end.
