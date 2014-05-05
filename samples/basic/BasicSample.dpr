program BasicSample;

uses
  Vcl.Forms,
  Main.View in 'src\Main.View.pas' {MainView} ,
  Connection.FireDAC in '..\common\src\Connection.FireDAC.pas' {ConnectionFireDAC: TDataModule} ,
  Country.Model in 'src\Country.Model.pas' {CountryModel: TDataModule} ,
  Country.Controller in 'src\Country.Controller.pas',
  Country.View in 'src\Country.View.pas' {CountryView} ,
  InfraDB4D.Model.Base in '..\..\src\InfraDB4D.Model.Base.pas' {ModelBase: TDataModule} ,
  InfraDB4D.Model.FireDAC in '..\..\src\InfraDB4D.Model.FireDAC.pas' {ModelFireDAC: TDataModule} ,
  Province.Model in 'src\Province.Model.pas' {ProvinceModel: TDataModule} ,
  Province.Controller in 'src\Province.Controller.pas',
  Dm.Models in 'src\Dm.Models.pas' {DmModels: TDataModule};

{$R *.res}


begin
  Application.Initialize;

  ReportMemoryLeaksOnShutdown := True;

  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainView, MainView);
  Application.CreateForm(TConnectionFireDAC, ConnectionFireDAC);
  Application.Run;

end.
