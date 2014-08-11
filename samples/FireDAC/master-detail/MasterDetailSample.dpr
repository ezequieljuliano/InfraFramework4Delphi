program MasterDetailSample;

uses
  Vcl.Forms,
  Main.View in 'src\Main.View.pas' {MainView},
  Connection.FireDAC in '..\common\src\Connection.FireDAC.pas' {ConnectionFireDAC: TDataModule},
  Customer.Model in 'src\Customer.Model.pas' {CustomerModel: TDataModule},
  CustomerContact.Model in 'src\CustomerContact.Model.pas' {CustomerContactModel: TDataModule},
  Customer.Controller in 'src\Customer.Controller.pas',
  CustomerContact.Controller in 'src\CustomerContact.Controller.pas',
  Dm.Models in 'src\Dm.Models.pas' {DmModels: TDataModule},
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
