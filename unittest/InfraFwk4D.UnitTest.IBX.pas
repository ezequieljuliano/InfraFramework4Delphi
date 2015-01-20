unit InfraFwk4D.UnitTest.IBX;

interface

uses
  TestFramework,
  System.SysUtils,
  InfraFwk4D.Driver.IBX,
  InfraFwk4D.UnitTest.IBX.Connection,
  InfraFwk4D.UnitTest.IBX.DAO,
  InfraFwk4D.UnitTest.IBX.BC;

type

  TTestInfraFwkIBX = class(TTestCase)
  private
    FIBXDmConnection: TIBXDmConnection;
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

{ TTestInfraFwkIBX }

procedure TTestInfraFwkIBX.SetUp;
begin
  inherited;
  FIBXDmConnection := TIBXDmConnection.Create(nil);
end;

procedure TTestInfraFwkIBX.TearDown;
begin
  inherited;
  FreeAndNil(FIBXDmConnection);
end;

procedure TTestInfraFwkIBX.TestBusinessController;
var
  vDAO: TIBXDAO;
  vBC: TIBXBC;
begin
  vDAO := TIBXDAO.Create(nil);
  vBC := TIBXBC.Create(vDAO);
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

  vDAO := TIBXDAO.Create(nil);
  vBC := TIBXBC.Create(vDAO, False);
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

  vBC := TIBXBC.Create(TIBXDAO);
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

procedure TTestInfraFwkIBX.TestConnection;
var
  vConnection: TIBXConnectionAdapter;
begin
  vConnection := TIBXConnectionAdapter.Create;
  vConnection.Build(TIBXComponentAdapter.Create(FIBXDmConnection.IBDatabase), True);

  CheckTrue(vConnection.Component <> nil);
  CheckTrue(vConnection.Statement <> nil);

  FreeAndNil(vConnection);
end;

procedure TTestInfraFwkIBX.TestConnectionManager;
var
  vConnectionManager: TIBXConnectionManagerAdapter;
  vConnection: TIBXConnectionAdapter;
begin
  vConnectionManager := TIBXConnectionManagerAdapter.Create;
  vConnection := TIBXConnectionAdapter.Create;
  vConnection.Build(TIBXComponentAdapter.Create(FIBXDmConnection.IBDatabase));

  vConnectionManager.RegisterConnection('Conn1', vConnection);
  CheckTrue(vConnectionManager.Count = 1);
  CheckTrue(vConnectionManager.GetConnection('Conn1') <> nil);
  CheckTrue(vConnectionManager.ConnectionIsRegistered('Conn1'));

  vConnectionManager.RegisterConnection('Conn2', TIBXConnectionAdapter);
  vConnectionManager.GetConnection('Conn2').Build(TIBXComponentAdapter.Create(FIBXDmConnection.IBDatabase));
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

procedure TTestInfraFwkIBX.TestConnectionSingleton;
var
  vConnection: TIBXConnectionAdapter;
begin
  vConnection := IBXSingletonConnectionAdapter.Instance;

  CheckTrue(vConnection <> nil);

  vConnection.Build(TIBXComponentAdapter.Create(FIBXDmConnection.IBDatabase), True);

  CheckTrue(vConnection.Component <> nil);
  CheckTrue(vConnection.Statement <> nil);
end;

initialization

RegisterTest(TTestInfraFwkIBX.Suite);

end.
