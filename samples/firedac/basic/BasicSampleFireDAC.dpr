program BasicSampleFireDAC;

uses
  Vcl.Forms,
  Main.View in 'src\Main.View.pas' {MainView},
  Database.FireDAC in '..\common\src\Database.FireDAC.pas' {DatabaseFireDAC: TDataModule},
  Country.DAO in 'src\Country.DAO.pas' {CountryDAO: TDataModule},
  Country.BC in 'src\Country.BC.pas',
  Country.View in 'src\Country.View.pas' {CountryView},
  Province.DAO in 'src\Province.DAO.pas' {ProvinceDAO: TDataModule},
  Province.BC in 'src\Province.BC.pas',
  Province.View in 'src\Province.View.pas' {ProvinceView},
  InfraFwk4D.Driver.FireDAC in '..\..\..\src\InfraFwk4D.Driver.FireDAC.pas',
  InfraFwk4D.Driver.FireDAC.Persistence in '..\..\..\src\InfraFwk4D.Driver.FireDAC.Persistence.pas' {FireDACPersistenceAdapter: TDataModule},
  InfraFwk4D.Driver in '..\..\..\src\InfraFwk4D.Driver.pas',
  InfraFwk4D.Iterator.DataSet in '..\..\..\src\InfraFwk4D.Iterator.DataSet.pas',
  InfraFwk4D in '..\..\..\src\InfraFwk4D.pas';

{$R *.res}

begin

  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainView, MainView);
  Application.Run;

end.
