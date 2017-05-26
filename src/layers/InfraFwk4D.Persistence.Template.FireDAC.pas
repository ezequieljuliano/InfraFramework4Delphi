unit InfraFwk4D.Persistence.Template.FireDAC;

interface

uses
  System.SysUtils,
  System.Classes,
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
    fDelegate: IDBDelegate<TFDQuery>;
  protected
    function GetSession: IDBSession;
    function GetDelegate: IDBDelegate<TFDQuery>;
  public
    constructor Create(const session: IDBSession); reintroduce;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}

{ TPersistenceTemplateFireDAC }

constructor TPersistenceTemplateFireDAC.Create(const session: IDBSession);
begin
  inherited Create(nil);
  fSession := session;
  fDelegate := TFireDACDelegateAdapter.Create(session, Self);
end;

function TPersistenceTemplateFireDAC.GetDelegate: IDBDelegate<TFDQuery>;
begin
  Result := fDelegate;
end;

function TPersistenceTemplateFireDAC.GetSession: IDBSession;
begin
  if not Assigned(fSession) then
    raise EPersistenceException.CreateFmt('Database Session not defined in %s!', [Self.ClassName]);
  Result := fSession;
end;

end.
