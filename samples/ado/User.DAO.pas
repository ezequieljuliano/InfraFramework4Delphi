unit User.DAO;

interface

uses
  SysUtils, Classes,
  InfraFwk4D.Driver.ADO, InfraFwk4D.Iterator.DataSet,
  InfraFwk4D.Driver.ADO.Persistence, DB,
{$IFDEF VER210}
  ADODB;
{$ELSE}
  Data.Win.ADODB, ADODB;
{$ENDIF}

type
  TUserDAO = class(TADOPersistenceAdapter)
    DtsUser: TADOQuery;
  strict protected
    function GetConnection(): TADOConnectionAdapter; override;
    procedure ConfigureDataSetsConnection(); override;
  private
    { Private declarations }
  public
    procedure FindByLogin(const pLogin: string);
  end;

var
  UserDAO: TUserDAO;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

uses
  SQLBuilder4D, Database.ADO;

{$R *.dfm}
{ TDataModule1 }

procedure TUserDAO.ConfigureDataSetsConnection;
begin
  inherited;

end;

procedure TUserDAO.FindByLogin(const pLogin: string);
begin
//  Result := Connection.Statement.Build(SQL.Select.AllColumns.From('usuario')
//    .Where('login').Like(SQL.Value(pLogin).Like(loContaining).Insensetive))
//    .AsIterator;

  QueryBuilder(DtsUser).Build(
    SQL.Where('login').Like(pLogin, loContaining)
    ).Activate;
end;

function TUserDAO.GetConnection: TADOConnectionAdapter;
begin
  Result := TDatabaseADO.GetAdapter;
end;

end.
