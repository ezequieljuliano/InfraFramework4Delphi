program InfraFwkTestsDataSetEvents;
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
  InfraFwk4D.UnitTest.DataSet.Events in 'InfraFwk4D.UnitTest.DataSet.Events.pas',
  InfraFwk4D.DataSet.Events in '..\..\src\utilities\InfraFwk4D.DataSet.Events.pas';

{ R *.RES }

begin

  ReportMemoryLeaksOnShutdown := True;

  DUnitTestRunner.RunRegisteredTests;

end.
