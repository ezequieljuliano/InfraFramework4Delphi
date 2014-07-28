unit InfraDB4D.UnitTest.UniDAC;

interface

uses
  TestFramework,
  System.Classes,
  System.SysUtils,
  System.TypInfo,
  Data.DB,
  Uni,
  InfraDB4D,
  InfraDB4D.Drivers.UniDAC,
  InfraDB4D.UnitTest.UniDAC.DataModule;

type

  TUniDACDmConnection = class(TUniDACDataModule)
  private
    FConnection: TUniConnection;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    property Connection: TUniConnection read FConnection write FConnection;
  end;

  TUniDACModel = class(TUniDACDataModule)
    Master: TUniQuery;
    Detail: TUniQuery;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

  TUniDACMasterController = class(TUniDACControllerAdapter);

  TUniDACDetailController = class(TUniDACControllerAdapter);

  TTestInfraDB4DUniDAC = class(TTestCase)
  private
    FUniDACDmConnection: TUniDACDmConnection;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestConnection();
    procedure TestConnectionSingleton();
    procedure TestConnectionManager();
    procedure TestController();
    procedure TestDetail();
  end;

implementation

{ TTestInfraDB4DUniDAC }

procedure TTestInfraDB4DUniDAC.SetUp;
begin
  inherited;
  FUniDACDmConnection := TUniDACDmConnection.Create(nil);
end;

procedure TTestInfraDB4DUniDAC.TearDown;
begin
  inherited;
  FreeAndNil(FUniDACDmConnection);
end;

procedure TTestInfraDB4DUniDAC.TestConnection;
var
  vConnection: TUniDACConnectionAdapter;
begin
  vConnection := TUniDACConnectionAdapter.Create;
  vConnection.Build(TUniDACComponentAdapter.Create(FUniDACDmConnection.FConnection), True);

  CheckTrue(vConnection.GetComponent <> nil);
  CheckTrue(vConnection.GetStatement <> nil);

  FreeAndNil(vConnection);
end;

procedure TTestInfraDB4DUniDAC.TestConnectionManager;
var
  vConnectionManager: TUniDACConnectionManagerAdapter;
  vConnection: TUniDACConnectionAdapter;
begin
  vConnectionManager := TUniDACConnectionManagerAdapter.Create;
  vConnection := TUniDACConnectionAdapter.Create;
  vConnection.Build(TUniDACComponentAdapter.Create(FUniDACDmConnection.FConnection));

  vConnectionManager.RegisterConnection('Conn1', vConnection);
  CheckTrue(vConnectionManager.Count = 1);
  CheckTrue(vConnectionManager.GetConnection('Conn1') <> nil);
  CheckTrue(vConnectionManager.ConnectionIsRegistered('Conn1'));

  vConnectionManager.RegisterConnection('Conn2', TUniDACConnectionAdapter);
  vConnectionManager.GetConnection('Conn2').Build(TUniDACComponentAdapter.Create(FUniDACDmConnection.FConnection));
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

procedure TTestInfraDB4DUniDAC.TestConnectionSingleton;
var
  vConnection: TUniDACConnectionAdapter;
begin
  vConnection := TUniDACSingletonConnectionAdapter.Get();

  CheckTrue(vConnection <> nil);

  vConnection.Build(TUniDACComponentAdapter.Create(FUniDACDmConnection.FConnection), True);

  CheckTrue(vConnection.GetComponent <> nil);
  CheckTrue(vConnection.GetStatement <> nil);
end;

procedure TTestInfraDB4DUniDAC.TestController;
var
  vModel: TUniDACModel;
  vMasterController: TUniDACMasterController;
  vConnection: TUniDACConnectionAdapter;
begin
  vConnection := TUniDACSingletonConnectionAdapter.Get();

  vModel := TUniDACModel.Create(nil);

  vMasterController := TUniDACMasterController.Create(vConnection, vModel, vModel.Master);
  CheckTrue(vMasterController.GetConnection <> nil);
  CheckTrue(vMasterController.GetDataSet <> nil);
  CheckTrue(vMasterController.GetModel<TUniDACModel>() <> nil);
  FreeAndNil(vMasterController);

  FreeAndNil(vModel);
end;

procedure TTestInfraDB4DUniDAC.TestDetail;
var
  vModel: TUniDACModel;
  vConnection: TUniDACConnectionAdapter;
  vMasterController: TUniDACMasterController;
begin
  vConnection := TUniDACSingletonConnectionAdapter.Get();

  vModel := TUniDACModel.Create(nil);

  vMasterController := TUniDACMasterController.Create(vConnection, vModel, vModel.Master);
  CheckTrue(vMasterController.GetConnection <> nil);
  CheckTrue(vMasterController.GetDataSet <> nil);
  CheckTrue(vMasterController.GetModel<TUniDACModel>() <> nil);

  vMasterController.GetDetails.RegisterDetail('Detail', TUniDACDetailController.Create(vConnection, vModel, vModel.Detail));
  CheckTrue(vMasterController.GetDetails.GetDetail('Detail').GetConnection <> nil);
  CheckTrue(vMasterController.GetDetails.GetDetail('Detail').GetDataSet <> nil);
  CheckTrue(vMasterController.GetDetails.GetDetail('Detail').GetModel<TUniDACModel>() <> nil);
  CheckTrue(vMasterController.GetDetails.GetDetail('Detail').GetMaster<TUniDACMasterController>() <> nil);
  CheckTrue(vMasterController.GetDetails.GetDetailAs<TUniDACDetailController>('Detail').GetDataSet <> nil);
  CheckTrue(vMasterController.GetDetails.GetDetailAs<TUniDACDetailController>('Detail').ClassName = 'TUniDACDetailController');
  CheckTrue(vMasterController.GetDetails.GetDetailByClass<TUniDACDetailController>().GetDataSet <> nil);
  CheckTrue(vMasterController.GetDetails.GetDetailByClass<TUniDACDetailController>().ClassName = 'TUniDACDetailController');

  FreeAndNil(vMasterController);

  FreeAndNil(vModel);
end;

{ TUniDACDmConnection }

procedure TUniDACDmConnection.AfterConstruction;
begin
  inherited;
  FConnection := TUniConnection.Create(nil);
end;

procedure TUniDACDmConnection.BeforeDestruction;
begin
  inherited;
  FreeAndNil(FConnection);
end;

{ TUniDACModel }

procedure TUniDACModel.AfterConstruction;
begin
  inherited;
  Master := TUniQuery.Create(nil);
  Detail := TUniQuery.Create(nil);
end;

procedure TUniDACModel.BeforeDestruction;
begin
  FreeAndNil(Master);
  FreeAndNil(Detail);
  inherited;
end;

initialization

RegisterTest(TTestInfraDB4DUniDAC.Suite);

end.
