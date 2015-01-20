program InfraFwkTestsIBX;
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
  InfraFwk4D.UnitTest.IBX in 'InfraFwk4D.UnitTest.IBX.pas',
  InfraFwk4D.Driver in '..\src\InfraFwk4D.Driver.pas',
  InfraFwk4D.Iterator.DataSet in '..\src\InfraFwk4D.Iterator.DataSet.pas',
  InfraFwk4D in '..\src\InfraFwk4D.pas',
  InfraFwk4D.Driver.IBX in '..\src\InfraFwk4D.Driver.IBX.pas',
  InfraFwk4D.Driver.IBX.Persistence in '..\src\InfraFwk4D.Driver.IBX.Persistence.pas' {IBXPersistenceAdapter: TDataModule},
  InfraFwk4D.UnitTest.IBX.Connection in 'InfraFwk4D.UnitTest.IBX.Connection.pas' {IBXDmConnection: TDataModule},
  InfraFwk4D.UnitTest.IBX.DAO in 'InfraFwk4D.UnitTest.IBX.DAO.pas' {IBXDAO: TDataModule},
  InfraFwk4D.UnitTest.IBX.BC in 'InfraFwk4D.UnitTest.IBX.BC.pas';

{$R *.RES}

begin

  ReportMemoryLeaksOnShutdown := True;

  DUnitTestRunner.RunRegisteredTests;

end.
