unit InfraFwk4D.UnitTest.FireDAC;

interface

uses
  TestFramework,
  System.SysUtils,
  InfraFwk4D.Driver.FireDAC,
  FireDAC.Comp.Client,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Def,
  FireDAC.DApt,
  InfraFwk4D.UnitTest.FireDAC.Connection,
  InfraFwk4D.UnitTest.FireDAC.DAO,
  InfraFwk4D.UnitTest.FireDAC.BC;

type

  TTestInfraFwkFireDAC = class(TTestCase)
  private
    FFireDACDmConnection: TFireDACDmConnection;
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

{ TTestInfraFwkFireDAC }

procedure TTestInfraFwkFireDAC.SetUp;
begin
  inherited;
  FFireDACDmConnection := TFireDACDmConnection.Create(nil);
end;

procedure TTestInfraFwkFireDAC.TearDown;
begin
  inherited;
  FreeAndNil(FFireDACDmConnection);
end;

procedure TTestInfraFwkFireDAC.TestConnection;
var
  vConnection: TFireDACConnectionAdapter;
begin
  vConnection := TFireDACConnectionAdapter.Create;
  vConnection.Build(TFireDACComponentAdapter.Create(FFireDACDmConnection.FDConnection), True);

  CheckTrue(vConnection.Component <> nil);
  CheckTrue(vConnection.Statement <> nil);

  FreeAndNil(vConnection);
end;

procedure TTestInfraFwkFireDAC.TestConnectionManager;
var
  vConnectionManager: TFireDACConnectionManagerAdapter;
  vConnection: TFireDACConnectionAdapter;
begin
  vConnectionManager := TFireDACConnectionManagerAdapter.Create;
  vConnection := TFireDACConnectionAdapter.Create;
  vConnection.Build(TFireDACComponentAdapter.Create(FFireDACDmConnection.FDConnection));

  vConnectionManager.RegisterConnection('Conn1', vConnection);
  CheckTrue(vConnectionManager.Count = 1);
  CheckTrue(vConnectionManager.GetConnection('Conn1') <> nil);
  CheckTrue(vConnectionManager.ConnectionIsRegistered('Conn1'));

  vConnectionManager.RegisterConnection('Conn2', TFireDACConnectionAdapter);
  vConnectionManager.GetConnection('Conn2').Build(TFireDACComponentAdapter.Create(FFireDACDmConnection.FDConnection));
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

procedure TTestInfraFwkFireDAC.TestConnectionSingleton;
var
  vConnection: TFireDACConnectionAdapter;
begin
  vConnection := FireDACAdapter.SingletonConnection.Instance;

  CheckTrue(vConnection <> nil);

  vConnection.Build(TFireDACComponentAdapter.Create(FFireDACDmConnection.FDConnection), True);

  CheckTrue(vConnection.Component <> nil);
  CheckTrue(vConnection.Statement <> nil);
end;

procedure TTestInfraFwkFireDAC.TestBusinessController;
var
  vDAO: TFireDACDAO;
  vBC: TFireDACBC;
begin
  vDAO := TFireDACDAO.Create(nil);
  vBC := TFireDACBC.Create(vDAO);
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

  vDAO := TFireDACDAO.Create(nil);
  vBC := TFireDACBC.Create(vDAO, False);
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

  vBC := TFireDACBC.Create(TFireDACDAO);
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

  vBC := TFireDACBC.Create();
  try
    CheckTrue(vBC.Persistence <> nil);
    CheckTrue(vBC.Persistence.Connection <> nil);
    CheckTrue(vBC.Persistence.Master <> nil);
    CheckTrue(vBC.Persistence.Detail <> nil);
    CheckTrue(vBC.Persistence.ClassNameIs('TFireDACDAO'));
    CheckTrue(vBC.Persistence.QueryBuilder(vBC.Persistence.Master) <> nil);
    CheckTrue(vBC.Persistence.QueryBuilder('Master') <> nil);
    CheckTrue(vBC.Persistence.QueryBuilder(vBC.Persistence.Detail) <> nil);
    CheckTrue(vBC.Persistence.QueryBuilder('Detail') <> nil);
  finally
    FreeAndNil(vBC);
  end;
end;

initialization

RegisterTest(TTestInfraFwkFireDAC.Suite);

end.
