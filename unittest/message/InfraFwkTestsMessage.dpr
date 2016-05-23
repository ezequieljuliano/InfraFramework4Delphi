program InfraFwkTestsMessage;
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
  InfraFwk4D.UnitTest.Message in 'InfraFwk4D.UnitTest.Message.pas',
  InfraFwk4D.Message in '..\..\src\message\InfraFwk4D.Message.pas',
  InfraFwk4D.Message.Impl in '..\..\src\message\InfraFwk4D.Message.Impl.pas',
  InfraFwk4D.UnitTest.Appender in 'InfraFwk4D.UnitTest.Appender.pas';

{$R *.RES}

begin

  ReportMemoryLeaksOnShutdown := True;

  DUnitTestRunner.RunRegisteredTests;

end.
