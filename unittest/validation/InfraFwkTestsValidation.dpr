program InfraFwkTestsValidation;
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
  InfraFwk4D.UnitTest.Validation in 'InfraFwk4D.UnitTest.Validation.pas',
  InfraFwk4D.Validation in '..\..\src\validation\InfraFwk4D.Validation.pas',
  InfraFwk4D.Validation.Default.Attributes in '..\..\src\validation\InfraFwk4D.Validation.Default.Attributes.pas',
  InfraFwk4D.Validation.Default.Validators in '..\..\src\validation\InfraFwk4D.Validation.Default.Validators.pas',
  InfraFwk4D.Validation.Core in '..\..\src\validation\InfraFwk4D.Validation.Core.pas',
  InfraFwk4D.UnitTest.Validation.DataModule in 'InfraFwk4D.UnitTest.Validation.DataModule.pas' {Model: TDataModule},
  InfraFwk4D.UnitTest.Validation.Entity in 'InfraFwk4D.UnitTest.Validation.Entity.pas';

{$R *.RES}

begin

  ReportMemoryLeaksOnShutdown := True;

  DUnitTestRunner.RunRegisteredTests;

end.
