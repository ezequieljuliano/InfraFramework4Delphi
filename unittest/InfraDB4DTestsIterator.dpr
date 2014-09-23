program InfraDB4DTestsIterator;
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
  InfraDB4D.UnitTest.Iterator in 'InfraDB4D.UnitTest.Iterator.pas',
  InfraDB4D.Iterator in '..\src\InfraDB4D.Iterator.pas',
  InfraDB4D in '..\src\InfraDB4D.pas',
  InfraDB4D.Iterator.Impl in '..\src\InfraDB4D.Iterator.Impl.pas';

{$R *.RES}

begin

  ReportMemoryLeaksOnShutdown := True;

  DUnitTestRunner.RunRegisteredTests;

end.
