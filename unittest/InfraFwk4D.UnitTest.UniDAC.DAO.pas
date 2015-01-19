unit InfraFwk4D.UnitTest.UniDAC.DAO;

interface

uses
  System.SysUtils, System.Classes, InfraFwk4D.Driver.UniDAC.Persistence,
  InfraFwk4D.Driver.UniDAC, InfraFwk4D.UnitTest.UniDAC.Connection, Data.DB, MemDS, DBAccess, Uni;

type

  TUniDACDAO = class(TUniDACPersistenceAdapter)
    Master: TUniQuery;
    Detail: TUniQuery;
  private
    { Private declarations }
  strict protected
    function GetConnection(): TUniDACConnectionAdapter; override;
    procedure ConfigureDataSetsConnection(); override;
  public
    { Public declarations }
  end;

implementation

{ %CLASSGROUP 'System.Classes.TPersistent' }

{$R *.dfm}

{ TUniDACDAO }

procedure TUniDACDAO.ConfigureDataSetsConnection;
begin
  inherited;
  Master.Connection := Connection.Component.Connection;
  Detail.Connection := Connection.Component.Connection;
end;

function TUniDACDAO.GetConnection: TUniDACConnectionAdapter;
begin
  Result := UniDACSingletonConnectionAdapter.Instance;
end;

end.
