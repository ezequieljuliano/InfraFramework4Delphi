program InfraFwkTestsUniDAC;
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
  InfraFwk4D.UnitTest.UniDAC in 'InfraFwk4D.UnitTest.UniDAC.pas',
  InfraFwk4D.Driver in '..\src\InfraFwk4D.Driver.pas',
  InfraFwk4D.Iterator.DataSet in '..\src\InfraFwk4D.Iterator.DataSet.pas',
  InfraFwk4D in '..\src\InfraFwk4D.pas',
  InfraFwk4D.Driver.UniDAC in '..\src\InfraFwk4D.Driver.UniDAC.pas',
  InfraFwk4D.Driver.UniDAC.Persistence in '..\src\InfraFwk4D.Driver.UniDAC.Persistence.pas' {UniDACPersistenceAdapter: TDataModule},
  InfraFwk4D.UnitTest.UniDAC.Connection in 'InfraFwk4D.UnitTest.UniDAC.Connection.pas' {UniDACDmConnection: TDataModule},
  InfraFwk4D.UnitTest.UniDAC.DAO in 'InfraFwk4D.UnitTest.UniDAC.DAO.pas' {UniDACDAO: TDataModule},
  InfraFwk4D.UnitTest.UniDAC.BC in 'InfraFwk4D.UnitTest.UniDAC.BC.pas';

{$R *.RES}

begin

  ReportMemoryLeaksOnShutdown := True;

  DUnitTestRunner.RunRegisteredTests;

end.
