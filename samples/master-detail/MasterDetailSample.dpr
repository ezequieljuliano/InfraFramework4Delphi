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

program MasterDetailSample;

uses
  Vcl.Forms,
  Main.View in 'src\Main.View.pas' {MainView} ,
  Connection.FireDAC in '..\common\src\Connection.FireDAC.pas' {ConnectionFireDAC: TDataModule} ,
  InfraDB4D.Model.Base in '..\..\src\InfraDB4D.Model.Base.pas' {ModelBase: TDataModule} ,
  InfraDB4D.Model.FireDAC in '..\..\src\InfraDB4D.Model.FireDAC.pas' {ModelFireDAC: TDataModule} ,
  Customer.Model in 'src\Customer.Model.pas' {CustomerModel: TDataModule} ,
  CustomerContact.Model in 'src\CustomerContact.Model.pas' {CustomerContactModel: TDataModule} ,
  Customer.Controller in 'src\Customer.Controller.pas',
  CustomerContact.Controller in 'src\CustomerContact.Controller.pas',
  Dm.Models in 'src\Dm.Models.pas' {DmModels: TDataModule} ,
  Customer.View in 'src\Customer.View.pas' {CustomerView};

{$R *.res}


begin

  Application.Initialize;

  ReportMemoryLeaksOnShutdown := True;

  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainView, MainView);
  Application.CreateForm(TConnectionFireDAC, ConnectionFireDAC);
  Application.Run;

end.
