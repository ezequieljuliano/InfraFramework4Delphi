program BasicSampleADO;

uses
  Forms,
  Main.View in 'Main.View.pas' {Form3},
  InfraFwk4D.Driver.ADO in '..\..\src\InfraFwk4D.Driver.ADO.pas',
  InfraFwk4D.Driver.ADO.Persistence in '..\..\src\InfraFwk4D.Driver.ADO.Persistence.pas' {ADOPersistenceAdapter: TDataModule},
  InfraFwk4D.Driver in '..\..\src\InfraFwk4D.Driver.pas',
  InfraFwk4D.Iterator.DataSet in '..\..\src\InfraFwk4D.Iterator.DataSet.pas',
  InfraFwk4D.Message.Context in '..\..\src\InfraFwk4D.Message.Context.pas',
  InfraFwk4D in '..\..\src\InfraFwk4D.pas',
  SQLBuilder4D.Parser.GaSQLParser in '..\..\..\SQLBuilder4Delphi-master\src\SQLBuilder4D.Parser.GaSQLParser.pas',
  SQLBuilder4D.Parser in '..\..\..\SQLBuilder4Delphi-master\src\SQLBuilder4D.Parser.pas',
  SQLBuilder4D in '..\..\..\SQLBuilder4Delphi-master\src\SQLBuilder4D.pas',
  gaAdvancedSQLParser in '..\..\..\SQLBuilder4Delphi-master\dependencies\gaSQLParser\src\gaAdvancedSQLParser.pas',
  gaBasicSQLParser in '..\..\..\SQLBuilder4Delphi-master\dependencies\gaSQLParser\src\gaBasicSQLParser.pas',
  gaDeleteStm in '..\..\..\SQLBuilder4Delphi-master\dependencies\gaSQLParser\src\gaDeleteStm.pas',
  gaInsertStm in '..\..\..\SQLBuilder4Delphi-master\dependencies\gaSQLParser\src\gaInsertStm.pas',
  gaLnkList in '..\..\..\SQLBuilder4Delphi-master\dependencies\gaSQLParser\src\gaLnkList.pas',
  gaParserVisitor in '..\..\..\SQLBuilder4Delphi-master\dependencies\gaSQLParser\src\gaParserVisitor.pas',
  gaQueryParsersReg in '..\..\..\SQLBuilder4Delphi-master\dependencies\gaSQLParser\src\gaQueryParsersReg.pas',
  gaSelectStm in '..\..\..\SQLBuilder4Delphi-master\dependencies\gaSQLParser\src\gaSelectStm.pas',
  gaSQLExpressionParsers in '..\..\..\SQLBuilder4Delphi-master\dependencies\gaSQLParser\src\gaSQLExpressionParsers.pas',
  gaSQLFieldRefParsers in '..\..\..\SQLBuilder4Delphi-master\dependencies\gaSQLParser\src\gaSQLFieldRefParsers.pas',
  gaSQLParserConsts in '..\..\..\SQLBuilder4Delphi-master\dependencies\gaSQLParser\src\gaSQLParserConsts.pas',
  gaSQLParserHelperClasses in '..\..\..\SQLBuilder4Delphi-master\dependencies\gaSQLParser\src\gaSQLParserHelperClasses.pas',
  gaSQLSelectFieldParsers in '..\..\..\SQLBuilder4Delphi-master\dependencies\gaSQLParser\src\gaSQLSelectFieldParsers.pas',
  gaSQLTableRefParsers in '..\..\..\SQLBuilder4Delphi-master\dependencies\gaSQLParser\src\gaSQLTableRefParsers.pas',
  gaUpdateStm in '..\..\..\SQLBuilder4Delphi-master\dependencies\gaSQLParser\src\gaUpdateStm.pas',
  Database.ADO in 'Database.ADO.pas' {DatabaseADO: TDataModule},
  User.DAO in 'User.DAO.pas' {DmUserDAO: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
