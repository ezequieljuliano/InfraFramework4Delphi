(*
  Copyright 2014 Ezequiel Juliano Müller | Microsys Sistemas Ltda

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*)

unit InfraDB4D.UnitTest.FireDAC;

interface

uses
  TestFramework,
  System.Classes,
  System.SysUtils,
  System.TypInfo,
  InfraDB4D,
  InfraDB4D.Model.Base,
  InfraDB4D.Drivers.FireDAC,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Def;

type

  TFireDACDmConnection = class(TModelBase)
  private
    FConnection: TFDConnection;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    property Connection: TFDConnection read FConnection write FConnection;
  end;

  TFireDACModel = class(TModelBase)
    Master: TFDQuery;
    Detail: TFDQuery;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

  TFireDACMasterController = class(TFireDACControllerAdapter);

  TFireDACDetailController = class(TFireDACControllerAdapter);

  TTestInfraDB4DFireDAC = class(TTestCase)
  private
    FFireDACDmConnection: TFireDACDmConnection;
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

{ TTestInfraDB4D }

procedure TTestInfraDB4DFireDAC.SetUp;
begin
  inherited;
  FFireDACDmConnection := TFireDACDmConnection.Create(nil);
end;

procedure TTestInfraDB4DFireDAC.TearDown;
begin
  inherited;
  FreeAndNil(FFireDACDmConnection);
end;

procedure TTestInfraDB4DFireDAC.TestConnection;
var
  vConnection: TFireDACConnectionAdapter;
begin
  vConnection := TFireDACConnectionAdapter.Create;
  vConnection.Build(TFireDACComponentAdapter.Create(FFireDACDmConnection.FConnection), True);

  CheckTrue(vConnection.GetComponent <> nil);
  CheckTrue(vConnection.GetStatement <> nil);

  FreeAndNil(vConnection);
end;

procedure TTestInfraDB4DFireDAC.TestConnectionManager;
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

procedure TTestInfraDB4DFireDAC.TestConnectionSingleton;
var
  vConnection: TFireDACConnectionAdapter;
begin
  vConnection := TFireDACSingletonConnectionAdapter.Get();

  CheckTrue(vConnection <> nil);

  vConnection.Build(TFireDACComponentAdapter.Create(FFireDACDmConnection.FConnection), True);

  CheckTrue(vConnection.GetComponent <> nil);
  CheckTrue(vConnection.GetStatement <> nil);
end;

procedure TTestInfraDB4DFireDAC.TestController;
var
  vModel: TFireDACModel;
  vMasterController: TFireDACMasterController;
  vConnection: TFireDACConnectionAdapter;
begin
  vConnection := TFireDACSingletonConnectionAdapter.Get();

  vModel := TFireDACModel.Create(nil);

  vMasterController := TFireDACMasterController.Create(vConnection, vModel, vModel.Master);
  CheckTrue(vMasterController.GetConnection <> nil);
  CheckTrue(vMasterController.GetDataSet <> nil);
  CheckTrue(vMasterController.GetModel<TFireDACModel>() <> nil);
  FreeAndNil(vMasterController);

  FreeAndNil(vModel);
end;

procedure TTestInfraDB4DFireDAC.TestDetail;
var
  vModel: TFireDACModel;
  vConnection: TFireDACConnectionAdapter;
  vMasterController: TFireDACMasterController;
begin
  vConnection := TFireDACSingletonConnectionAdapter.Get();

  vModel := TFireDACModel.Create(nil);

  vMasterController := TFireDACMasterController.Create(vConnection, vModel, vModel.Master);
  CheckTrue(vMasterController.GetConnection <> nil);
  CheckTrue(vMasterController.GetDataSet <> nil);
  CheckTrue(vMasterController.GetModel<TFireDACModel>() <> nil);

  vMasterController.GetDetails.RegisterDetail('Detail',
    TFireDACDetailController.Create(vConnection, vModel, vModel.Detail)
    );
  CheckTrue(vMasterController.GetDetails.GetDetail('Detail').GetConnection <> nil);
  CheckTrue(vMasterController.GetDetails.GetDetail('Detail').GetDataSet <> nil);
  CheckTrue(vMasterController.GetDetails.GetDetail('Detail').GetModel<TFireDACModel>() <> nil);

  FreeAndNil(vMasterController);

  FreeAndNil(vModel);
end;

{ TFireDACDmConnection }

procedure TFireDACDmConnection.AfterConstruction;
begin
  inherited;
  FConnection := TFDConnection.Create(nil);
end;

procedure TFireDACDmConnection.BeforeDestruction;
begin
  FreeAndNil(FConnection);
  inherited;
end;

{ TFireDACMasterDetailModel }

procedure TFireDACModel.AfterConstruction;
begin
  inherited;
  Master := TFDQuery.Create(nil);
  Detail := TFDQuery.Create(nil);
end;

procedure TFireDACModel.BeforeDestruction;
begin
  FreeAndNil(Master);
  FreeAndNil(Detail);
  inherited;
end;

initialization

RegisterTest(TTestInfraDB4DFireDAC.Suite);

end.
