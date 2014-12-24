unit InfraFwk4D.UnitTest.FireDAC;

interface

uses
  TestFramework,
  System.SysUtils,
  InfraFwk4D.UnitTest.DataModule,
  InfraFwk4D.Driver.FireDAC,
  InfraFwk4D.Attributes,
  FireDAC.Comp.Client,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Def,
  FireDAC.DApt;

type

  TFireDACDmConnection = class(TInfraFwkDataModule)
  private
    FConnection: TFDConnection;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    property Connection: TFDConnection read FConnection;
  end;

  TFireDACDAO = class(TInfraFwkDataModule, IFireDACPersistenceAdapter)
    Master: TFDQuery;
    Detail: TFDQuery;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    function GetConnection(): TFireDACConnectionAdapter;

    property Connection: TFireDACConnectionAdapter read GetConnection;
  end;

  [DataSetComponent('Master')]
  TFireDACMasterBC = class(TFireDACBusinessAdapter<TFireDACDAO>)
  end;

  [DataSetComponent('Detail')]
  TFireDACDetailBC = class(TFireDACBusinessAdapter<TFireDACDAO>)
  end;

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
    procedure TestBusinessDetails();
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
  vConnection.Build(TFireDACComponentAdapter.Create(FFireDACDmConnection.FConnection), True);

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
  vConnection.Build(TFireDACComponentAdapter.Create(FFireDACDmConnection.FConnection));

  vConnectionManager.RegisterConnection('Conn1', vConnection);
  CheckTrue(vConnectionManager.Count = 1);
  CheckTrue(vConnectionManager.GetConnection('Conn1') <> nil);
  CheckTrue(vConnectionManager.ConnectionIsRegistered('Conn1'));

  vConnectionManager.RegisterConnection('Conn2', TFireDACConnectionAdapter);
  vConnectionManager.GetConnection('Conn2').Build(TFireDACComponentAdapter.Create(FFireDACDmConnection.FConnection));
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
  vConnection := FireDACSingletonConnectionAdapter.Instance;

  CheckTrue(vConnection <> nil);

  vConnection.Build(TFireDACComponentAdapter.Create(FFireDACDmConnection.FConnection), True);

  CheckTrue(vConnection.Component <> nil);
  CheckTrue(vConnection.Statement <> nil);
end;

procedure TTestInfraFwkFireDAC.TestBusinessController;
var
  vDAO: TFireDACDAO;
  vMasterBC: TFireDACMasterBC;
begin
  vDAO := TFireDACDAO.Create(nil);
  vMasterBC := TFireDACMasterBC.Create(vDAO);
  try
    CheckTrue(vMasterBC.Persistence <> nil);
    CheckTrue(vMasterBC.Persistence.Connection <> nil);
    CheckTrue(vMasterBC.DataSet <> nil);
  finally
    FreeAndNil(vMasterBC);
  end;

  vDAO := TFireDACDAO.Create(nil);
  vMasterBC := TFireDACMasterBC.Create(vDAO, False);
  try
    CheckTrue(vMasterBC.Persistence <> nil);
    CheckTrue(vMasterBC.Persistence.Connection <> nil);
    CheckTrue(vMasterBC.DataSet <> nil);
  finally
    FreeAndNil(vMasterBC);
    FreeAndNil(vDAO);
    CheckTrue(vDAO = nil);
  end;

  vMasterBC := TFireDACMasterBC.Create(TFireDACDAO);
  try
    CheckTrue(vMasterBC.Persistence <> nil);
    CheckTrue(vMasterBC.Persistence.Connection <> nil);
    CheckTrue(vMasterBC.DataSet <> nil);
  finally
    FreeAndNil(vMasterBC);
  end;
end;

procedure TTestInfraFwkFireDAC.TestBusinessDetails;
var
  vDAO: TFireDACDAO;
  vMasterBC: TFireDACMasterBC;
begin
  vDAO := TFireDACDAO.Create(nil);
  vMasterBC := TFireDACMasterBC.Create(vDAO);
  try
    CheckTrue(vMasterBC.Persistence <> nil);
    CheckTrue(vMasterBC.Persistence.Connection <> nil);
    CheckTrue(vMasterBC.DataSet <> nil);

    vMasterBC.Details.RegisterDetail('Detail', TFireDACDetailBC.Create(vMasterBC.Persistence, False));

    CheckTrue(vMasterBC.Details.GetDetail('Detail').Persistence <> nil);
    CheckTrue(vMasterBC.Details.GetDetail('Detail').Persistence.Connection <> nil);
    CheckTrue(vMasterBC.Details.GetDetail('Detail').DataSet <> nil);
    CheckTrue(vMasterBC.Details.GetDetailAs<TFireDACDetailBC>('Detail').DataSet <> nil);
    CheckTrue(vMasterBC.Details.GetDetailAs<TFireDACDetailBC>('Detail').ClassName = 'TFireDACDetailBC');
    CheckTrue(vMasterBC.Details.GetDetailByClass<TFireDACDetailBC>().DataSet <> nil);
    CheckTrue(vMasterBC.Details.GetDetailByClass<TFireDACDetailBC>().ClassName = 'TFireDACDetailBC');
  finally
    FreeAndNil(vMasterBC);
  end;
end;

{ TFireDACDmConnection }

procedure TFireDACDmConnection.AfterConstruction;
begin
  inherited AfterConstruction;
  FConnection := TFDConnection.Create(nil);
end;

procedure TFireDACDmConnection.BeforeDestruction;
begin
  FreeAndNil(FConnection);
  inherited BeforeDestruction;
end;

{ TFireDACPersistence }

procedure TFireDACDAO.AfterConstruction;
begin
  inherited AfterConstruction;
  Master := TFDQuery.Create(nil);
  Detail := TFDQuery.Create(nil);
end;

procedure TFireDACDAO.BeforeDestruction;
begin
  FreeAndNil(Master);
  FreeAndNil(Detail);
  inherited BeforeDestruction;
end;

function TFireDACDAO.GetConnection: TFireDACConnectionAdapter;
begin
  Result := FireDACSingletonConnectionAdapter.Instance;
end;

initialization

RegisterTest(TTestInfraFwkFireDAC.Suite);

end.
