program ADOSample;

uses
  Vcl.Forms,
  Main.View in 'Main.View.pas' {MainView},
  DAL.Connection in 'DAL.Connection.pas' {DALConnection: TDataModule},
  Country.DAO in 'Country.DAO.pas' {CountryDAO: TDataModule},
  Country.BC in 'Country.BC.pas',
  Country.View in 'Country.View.pas' {CountryView},
  InfraFwk4D.Persistence.Template.ADO in '..\..\..\src\layers\InfraFwk4D.Persistence.Template.ADO.pas' {PersistenceTemplateADO: TDataModule};

{$R *.res}

begin

  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDALConnection, DALConnection);
  Application.CreateForm(TMainView, MainView);
  Application.Run;

end.
