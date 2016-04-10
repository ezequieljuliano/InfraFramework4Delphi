unit User.DAO;

interface

uses
  SysUtils, Classes,
  InfraFwk4D.Driver.ADO, InfraFwk4D.Iterator.DataSet,
  InfraFwk4D.Driver.ADO.Persistence, ADODB, DB;

type
  TDmUserDAO = class(TADOPersistenceAdapter)
    ADOQuery1: TADOQuery;
  strict protected
    function GetConnection(): TADOConnectionAdapter; override;
    procedure ConfigureDataSetsConnection(); override;
  private
    { Private declarations }
  public
    procedure FindByLogin(const pLogin: string);
  end;

var
  DmUserDAO: TDmUserDAO;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

uses
  SQLBuilder4D, Database.ADO;

{$R *.dfm}
{ TDataModule1 }

procedure TDmUserDAO.ConfigureDataSetsConnection;
begin
  inherited;

end;

procedure TDmUserDAO.FindByLogin(const pLogin: string);
begin
//  Result := Connection.Statement.Build(SQL.Select.AllColumns.From('usuario')
//    .Where('login').Like(SQL.Value(pLogin).Like(loContaining).Insensetive))
//    .AsIterator;

  QueryBuilder(ADOQuery1).Build(
    SQL.Where('login').Like(pLogin, loContaining)
    ).Activate;
end;

function TDmUserDAO.GetConnection: TADOConnectionAdapter;
begin
  Result := TDatabaseADO.GetAdapter;
end;

end.
