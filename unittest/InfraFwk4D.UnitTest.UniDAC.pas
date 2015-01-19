unit InfraFwk4D.UnitTest.UniDAC;

interface

uses
  TestFramework,
  System.SysUtils,
  Uni,
  InfraFwk4D.Driver.UniDAC,
  InfraFwk4D.UnitTest.UniDAC.Connection,
  InfraFwk4D.UnitTest.UniDAC.DAO,
  InfraFwk4D.UnitTest.UniDAC.BC;

type

  TTestInfraFwkUniDAC = class(TTestCase)
  private
    FUniDACDmConnection: TUniDACDmConnection;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestConnection();
    procedure TestConnectionSingleton();
    procedure TestConnectionManager();
    procedure TestBusinessController();
  end;

implementation

{ TTestInfraFwkUniDAC }

procedure TTestInfraFwkUniDAC.SetUp;
begin
  inherited;
  FUniDACDmConnection := TUniDACDmConnection.Create(nil);
end;

procedure TTestInfraFwkUniDAC.TearDown;
begin
  inherited;
  FreeAndNil(FUniDACDmConnection);
end;

procedure TTestInfraFwkUniDAC.TestBusinessController;
var
  vDAO: TUniDACDAO;
  vBC: TUniDACBC;
begin
  vDAO := TUniDACDAO.Create(nil);
  vBC := TUniDACBC.Create(vDAO);
  try
    CheckTrue(vBC.Persistence <> nil);
    CheckTrue(vBC.Persistence.Connection <> nil);
    CheckTrue(vBC.Persistence.Master <> nil);
    CheckTrue(vBC.Persistence.Detail <> nil);
    CheckTrue(vBC.Persistence.QueryBuilder(vBC.Persistence.Master) <> nil);
    CheckTrue(vBC.Persistence.QueryBuilder('Master') <> nil);
    CheckTrue(vBC.Persistence.QueryBuilder(vBC.Persistence.Detail) <> nil);
    CheckTrue(vBC.Persistence.QueryBuilder('Detail') <> nil);
  finally
    FreeAndNil(vBC);
  end;

  vDAO := TUniDACDAO.Create(nil);
  vBC := TUniDACBC.Create(vDAO, False);
  try
    CheckTrue(vBC.Persistence <> nil);
    CheckTrue(vBC.Persistence.Connection <> nil);
    CheckTrue(vBC.Persistence.Master <> nil);
    CheckTrue(vBC.Persistence.Detail <> nil);
    CheckTrue(vBC.Persistence.QueryBuilder(vBC.Persistence.Master) <> nil);
    CheckTrue(vBC.Persistence.QueryBuilder('Master') <> nil);
    CheckTrue(vBC.Persistence.QueryBuilder(vBC.Persistence.Detail) <> nil);
    CheckTrue(vBC.Persistence.QueryBuilder('Detail') <> nil);
  finally
    FreeAndNil(vBC);
    FreeAndNil(vDAO);
    CheckTrue(vDAO = nil);
  end;

  vBC := TUniDACBC.Create(TUniDACDAO);
  try
    CheckTrue(vBC.Persistence <> nil);
    CheckTrue(vBC.Persistence.Connection <> nil);
    CheckTrue(vBC.Persistence.Master <> nil);
    CheckTrue(vBC.Persistence.Detail <> nil);
    CheckTrue(vBC.Persistence.QueryBuilder(vBC.Persistence.Master) <> nil);
    CheckTrue(vBC.Persistence.QueryBuilder('Master') <> nil);
    CheckTrue(vBC.Persistence.QueryBuilder(vBC.Persistence.Detail) <> nil);
    CheckTrue(vBC.Persistence.QueryBuilder('Detail') <> nil);
  finally
    FreeAndNil(vBC);
  end;
end;

procedure TTestInfraFwkUniDAC.TestConnection;
var
  vConnection: TUniDACConnectionAdapter;
begin
  vConnection := TUniDACConnectionAdapter.Create;
  vConnection.Build(TUniDACComponentAdapter.Create(FUniDACDmConnection.UniConnection), True);

  CheckTrue(vConnection.Component <> nil);
  CheckTrue(vConnection.Statement <> nil);

  FreeAndNil(vConnection);
end;

procedure TTestInfraFwkUniDAC.TestConnectionManager;
var
  vConnectionManager: TUniDACConnectionManagerAdapter;
  vConnection: TUniDACConnectionAdapter;
begin
  vConnectionManager := TUniDACConnectionManagerAdapter.Create;
  vConnection := TUniDACConnectionAdapter.Create;
  vConnection.Build(TUniDACComponentAdapter.Create(FUniDACDmConnection.UniConnection));

  vConnectionManager.RegisterConnection('Conn1', vConnection);
  CheckTrue(vConnectionManager.Count = 1);
  CheckTrue(vConnectionManager.GetConnection('Conn1') <> nil);
  CheckTrue(vConnectionManager.ConnectionIsRegistered('Conn1'));

  vConnectionManager.RegisterConnection('Conn2', TUniDACConnectionAdapter);
  vConnectionManager.GetConnection('Conn2').Build(TUniDACComponentAdapter.Create(FUniDACDmConnection.UniConnection));
  CheckTrue(vConnectionManager.Count = 2);
  CheckTrue(vConnectionManager.GetConnection('Conn2') <> nil);
  CheckTrue(vConnectionManager.ConnectionIsRegistered('Conn2'));

  vConnectionManager.UnregisterConnection('Conn2');
  CheckTrue(vConnectionManager.Count = 1);
  CheckFalse(vConnectionManager.ConnectionIsRegistered('Conn2'));

  vConnectionManager.UnregisterAllConnections;
  CheckTrue(vConnectionManager.Count = 0);

  FreeAndNil(vConnection);
  FreeAndNil(vConnectionManager);
end;

procedure TTestInfraFwkUniDAC.TestConnectionSingleton;
var
  vConnection: TUniDACConnectionAdapter;
begin
  vConnection := UniDACSingletonConnectionAdapter.Instance;

  CheckTrue(vConnection <> nil);

  vConnection.Build(TUniDACComponentAdapter.Create(FUniDACDmConnection.UniConnection), True);

  CheckTrue(vConnection.Component <> nil);
  CheckTrue(vConnection.Statement <> nil);
end;

initialization

RegisterTest(TTestInfraFwkUniDAC.Suite);

end.
