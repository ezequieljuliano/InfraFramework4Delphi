unit InfraDB4D.UnitTest.IBX;

interface

uses
  TestFramework,
  System.Classes,
  System.SysUtils,
  System.TypInfo,
  InfraDB4D,
  InfraDB4D.Drivers.IBX,
  InfraDB4D.UnitTest.IBX.DataModule,
  Data.DB,
  IBX.IBDatabase,
  IBX.IBCustomDataSet;

type

  TIBXDmConnection = class(TIBXDataModule)
  private
    FConnection: TIBDatabase;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    property Connection: TIBDatabase read FConnection write FConnection;
  end;

  TIBXModel = class(TIBXDataModule)
    Master: TIBDataSet;
    Detail: TIBDataSet;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

  TIBXMasterController = class(TIBXControllerAdapter);

  TIBXDetailController = class(TIBXControllerAdapter);

  TTestInfraDB4DIBX = class(TTestCase)
  private
    FIBXDmConnection: TIBXDmConnection;
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

{ TIBXDmConnection }

procedure TIBXDmConnection.AfterConstruction;
begin
  inherited;
  FConnection := TIBDatabase.Create(nil);
end;

procedure TIBXDmConnection.BeforeDestruction;
begin
  FreeAndNil(FConnection);
  inherited;
end;

{ TIBXModel }

procedure TIBXModel.AfterConstruction;
begin
  inherited;
  Master := TIBDataSet.Create(nil);
  Detail := TIBDataSet.Create(nil);
end;

procedure TIBXModel.BeforeDestruction;
begin
  FreeAndNil(Master);
  FreeAndNil(Detail);
  inherited;
end;

{ TTestInfraDB4DIBX }

procedure TTestInfraDB4DIBX.SetUp;
begin
  inherited;
  FIBXDmConnection := TIBXDmConnection.Create(nil);
end;

procedure TTestInfraDB4DIBX.TearDown;
begin
  inherited;
  FreeAndNil(FIBXDmConnection);
end;

procedure TTestInfraDB4DIBX.TestConnection;
var
  vConnection: TIBXConnectionAdapter;
begin
  vConnection := TIBXConnectionAdapter.Create;
  vConnection.Build(TIBXComponentAdapter.Create(FIBXDmConnection.FConnection), True);

  CheckTrue(vConnection.GetComponent <> nil);
  CheckTrue(vConnection.GetStatement <> nil);

  FreeAndNil(vConnection);
end;

procedure TTestInfraDB4DIBX.TestConnectionManager;
var
  vConnectionManager: TIBXConnectionManagerAdapter;
  vConnection: TIBXConnectionAdapter;
begin
  vConnectionManager := TIBXConnectionManagerAdapter.Create;
  vConnection := TIBXConnectionAdapter.Create;
  vConnection.Build(TIBXComponentAdapter.Create(FIBXDmConnection.FConnection));

  vConnectionManager.RegisterConnection('Conn1', vConnection);
  CheckTrue(vConnectionManager.Count = 1);
  CheckTrue(vConnectionManager.GetConnection('Conn1') <> nil);
  CheckTrue(vConnectionManager.ConnectionIsRegistered('Conn1'));

  vConnectionManager.RegisterConnection('Conn2', TIBXConnectionAdapter);
  vConnectionManager.GetConnection('Conn2').Build(TIBXComponentAdapter.Create(FIBXDmConnection.FConnection));
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

procedure TTestInfraDB4DIBX.TestConnectionSingleton;
var
  vConnection: TIBXConnectionAdapter;
begin
  vConnection := TIBXSingletonConnectionAdapter.Get();

  CheckTrue(vConnection <> nil);

  vConnection.Build(TIBXComponentAdapter.Create(FIBXDmConnection.FConnection), True);

  CheckTrue(vConnection.GetComponent <> nil);
  CheckTrue(vConnection.GetStatement <> nil);
end;

procedure TTestInfraDB4DIBX.TestController;
var
  vModel: TIBXModel;
  vMasterController: TIBXMasterController;
  vConnection: TIBXConnectionAdapter;
begin
  vConnection := TIBXSingletonConnectionAdapter.Get();

  vModel := TIBXModel.Create(nil);

  vMasterController := TIBXMasterController.Create(vConnection, vModel, vModel.Master);
  CheckTrue(vMasterController.GetConnection <> nil);
  CheckTrue(vMasterController.GetDataSet <> nil);
  CheckTrue(vMasterController.GetModel<TIBXModel>() <> nil);
  FreeAndNil(vMasterController);

  FreeAndNil(vModel);
end;

procedure TTestInfraDB4DIBX.TestDetail;
var
  vModel: TIBXModel;
  vConnection: TIBXConnectionAdapter;
  vMasterController: TIBXMasterController;
begin
  vConnection := TIBXSingletonConnectionAdapter.Get();

  vModel := TIBXModel.Create(nil);

  vMasterController := TIBXMasterController.Create(vConnection, vModel, vModel.Master);
  CheckTrue(vMasterController.GetConnection <> nil);
  CheckTrue(vMasterController.GetDataSet <> nil);
  CheckTrue(vMasterController.GetModel<TIBXModel>() <> nil);

  vMasterController.GetDetails.RegisterDetail('Detail', TIBXDetailController.Create(vConnection, vModel, vModel.Detail));
  CheckTrue(vMasterController.GetDetails.GetDetail('Detail').GetConnection <> nil);
  CheckTrue(vMasterController.GetDetails.GetDetail('Detail').GetDataSet <> nil);
  CheckTrue(vMasterController.GetDetails.GetDetail('Detail').GetModel<TIBXModel>() <> nil);
  CheckTrue(vMasterController.GetDetails.GetDetail('Detail').GetMaster<TIBXMasterController>() <> nil);
  CheckTrue(vMasterController.GetDetails.GetDetailAs<TIBXDetailController>('Detail').GetDataSet <> nil);
  CheckTrue(vMasterController.GetDetails.GetDetailAs<TIBXDetailController>('Detail').ClassName = 'TIBXDetailController');
  CheckTrue(vMasterController.GetDetails.GetDetailByClass<TIBXDetailController>().GetDataSet <> nil);
  CheckTrue(vMasterController.GetDetails.GetDetailByClass<TIBXDetailController>().ClassName = 'TIBXDetailController');

  FreeAndNil(vMasterController);

  FreeAndNil(vModel);
end;

initialization

RegisterTest(TTestInfraDB4DIBX.Suite);

end.
