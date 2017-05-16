program FireDACSample;

uses
  Vcl.Forms,
  Main.View in 'Main.View.pas' {MainView} ,
  InfraFwk4D.Persistence.Template.FireDAC in '..\..\..\src\layers\InfraFwk4D.Persistence.Template.FireDAC.pas' {PersistenceTemplateFireDAC: TDataModule} ,
  DAL.Connection in 'DAL.Connection.pas' {DALConnection: TDataModule} ,
  Country.DAO in 'Country.DAO.pas' {CountryDAO: TDataModule} ,
  Country.BC in 'Country.BC.pas',
  Country.View in 'Country.View.pas' {CountryView} ,
  Province.BC in 'Province.BC.pas',
  Province.View in 'Province.View.pas' {ProvinceView} ,
  Province.DAO in 'Province.DAO.pas' {ProvinceDAO: TDataModule};

{$R *.res}

begin

  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDALConnection, DALConnection);
  Application.CreateForm(TMainView, MainView);
  Application.Run;

end.
