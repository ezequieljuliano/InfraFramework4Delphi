program InfraFwkTestsMessageContext;
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
  InfraFwk4D.Message.Context in '..\src\InfraFwk4D.Message.Context.pas',
  InfraFwk4D.UnitTest.Message.Context in 'InfraFwk4D.UnitTest.Message.Context.pas',
  InfraFwk4D.UnitTest.Message.Context.Appender in 'InfraFwk4D.UnitTest.Message.Context.Appender.pas';

{$R *.RES}

begin

  ReportMemoryLeaksOnShutdown := True;

  DUnitTestRunner.RunRegisteredTests;

end.
