program InfraFwkTestsFireDAC;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  InfraFwk4D in '..\src\InfraFwk4D.pas',
  InfraFwk4D.Driver in '..\src\InfraFwk4D.Driver.pas',
  InfraFwk4D.Iterator.DataSet in '..\src\InfraFwk4D.Iterator.DataSet.pas',
  InfraFwk4D.Driver.FireDAC in '..\src\InfraFwk4D.Driver.FireDAC.pas',
  InfraFwk4D.UnitTest.FireDAC in 'InfraFwk4D.UnitTest.FireDAC.pas',
  InfraFwk4D.Driver.FireDAC.Persistence in '..\src\InfraFwk4D.Driver.FireDAC.Persistence.pas' {FireDACPersistenceAdapter: TDataModule},
  InfraFwk4D.UnitTest.FireDAC.Connection in 'InfraFwk4D.UnitTest.FireDAC.Connection.pas' {FireDACDmConnection: TDataModule},
  InfraFwk4D.UnitTest.FireDAC.DAO in 'InfraFwk4D.UnitTest.FireDAC.DAO.pas' {FireDACDAO: TDataModule},
  InfraFwk4D.UnitTest.FireDAC.BC in 'InfraFwk4D.UnitTest.FireDAC.BC.pas';

{$R *.RES}

begin

  ReportMemoryLeaksOnShutdown := True;

  DUnitTestRunner.RunRegisteredTests;

end.
