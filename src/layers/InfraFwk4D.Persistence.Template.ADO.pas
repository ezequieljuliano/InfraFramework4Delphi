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
    fSession: IDBSession;
    fDelegate: IDBDelegate<TADOQuery>;
  protected
    function GetSession: IDBSession;
    function GetDelegate: IDBDelegate<TADOQuery>;
  public
    constructor Create(const session: IDBSession); reintroduce;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}

{ TPersistenceTemplateADO }

constructor TPersistenceTemplateADO.Create(const session: IDBSession);
begin
  inherited Create(nil);
  fSession := session;
  fDelegate := TADODelegateAdapter.Create(session, Self);
end;

function TPersistenceTemplateADO.GetDelegate: IDBDelegate<TADOQuery>;
begin
  Result := fDelegate;
end;

function TPersistenceTemplateADO.GetSession: IDBSession;
begin
  if not Assigned(fSession) then
    raise EPersistenceException.CreateFmt('Database Session not defined in %s!', [Self.ClassName]);
  Result := fSession;
end;

end.
