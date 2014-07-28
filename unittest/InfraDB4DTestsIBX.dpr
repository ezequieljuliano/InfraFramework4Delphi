program InfraDB4DTestsIBX;
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
  InfraDB4D in '..\src\InfraDB4D.pas',
  InfraDB4D.Drivers.Base in '..\src\InfraDB4D.Drivers.Base.pas',
  InfraDB4D.Drivers.IBX in '..\src\InfraDB4D.Drivers.IBX.pas',
  InfraDB4D.UnitTest.IBX.DataModule in 'InfraDB4D.UnitTest.IBX.DataModule.pas' {IBXDataModule: TDataModule},
  InfraDB4D.UnitTest.IBX in 'InfraDB4D.UnitTest.IBX.pas';

{$R *.RES}


begin

  ReportMemoryLeaksOnShutdown := True;

  DUnitTestRunner.RunRegisteredTests;

end.
