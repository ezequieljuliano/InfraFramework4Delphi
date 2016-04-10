program BasicSampleADO;

uses
  Forms,
  Main.View in 'Main.View.pas' {Form3},
  Database.ADO in 'Database.ADO.pas' {DatabaseADO: TDataModule},
  User.DAO in 'User.DAO.pas' {UserDAO: TDataModule},
  User.BC in 'User.BC.pas',
  InfraFwk4D.Driver.ADO.Persistence in '..\..\src\InfraFwk4D.Driver.ADO.Persistence.pas' {ADOPersistenceAdapter: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
