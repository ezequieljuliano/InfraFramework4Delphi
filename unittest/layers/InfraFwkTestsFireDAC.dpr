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
  InfraFwk4D.UnitTest.FireDAC in 'InfraFwk4D.UnitTest.FireDAC.pas',
  InfraFwk4D.Persistence in '..\..\src\layers\InfraFwk4D.Persistence.pas',
  InfraFwk4D.DataSet.Iterator in '..\..\src\utilities\InfraFwk4D.DataSet.Iterator.pas',
  InfraFwk4D.Persistence.Base in '..\..\src\layers\InfraFwk4D.Persistence.Base.pas',
  InfraFwk4D.Persistence.Adapter.FireDAC in '..\..\src\layers\InfraFwk4D.Persistence.Adapter.FireDAC.pas',
  InfraFwk4D.Business in '..\..\src\layers\InfraFwk4D.Business.pas',
  InfraFwk4D.Persistence.Template.FireDAC in '..\..\src\layers\InfraFwk4D.Persistence.Template.FireDAC.pas' {PersistenceTemplateFireDAC: TDataModule},
  InfraFwk4D.View in '..\..\src\layers\InfraFwk4D.View.pas',
  InfraFwk4D.Observer in '..\..\src\utilities\InfraFwk4D.Observer.pas',
  InfraFwk4D.DataSet.Events in '..\..\src\utilities\InfraFwk4D.DataSet.Events.pas';

{$R *.RES}

begin

  ReportMemoryLeaksOnShutdown := True;

  DUnitTestRunner.RunRegisteredTests;

end.
