unit InfraFwk4D.UnitTest.IBX.DAO;

interface

uses
  System.SysUtils, System.Classes, InfraFwk4D.Driver.IBX.Persistence,
  InfraFwk4D.Driver.IBX, Data.DB, IBX.IBCustomDataSet, InfraFwk4D.UnitTest.IBX.Connection;

type

  TIBXDAO = class(TIBXPersistenceAdapter)
    Master: TIBDataSet;
    Detail: TIBDataSet;
  private
    { Private declarations }
  strict protected
    function GetConnection(): TIBXConnectionAdapter; override;
    procedure ConfigureDataSetsConnection(); override;
  public
    { Public declarations }
  end;

implementation

{ %CLASSGROUP 'System.Classes.TPersistent' }

{$R *.dfm}

{ TIBXDAO }

procedure TIBXDAO.ConfigureDataSetsConnection;
begin
  inherited;
  Master.Database := Connection.Component.Connection;
  Detail.Database := Connection.Component.Connection;
end;

function TIBXDAO.GetConnection: TIBXConnectionAdapter;
begin
  Result := IBXAdapter.SingletonConnection.Instance;
end;

end.
