unit User.DAO;

interface

uses
  SysUtils, Classes,
  InfraFwk4D.Driver.ADO, InfraFwk4D.Iterator.DataSet,
  InfraFwk4D.Driver.ADO.Persistence, DB,

  {$IFDEF VER210}

  ADODB;

  {$ELSE}

  Data.Win.ADODB;

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

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

uses
  SQLBuilder4D,
  Database.ADO;

{$R *.dfm}

{ TUserDAO }

procedure TUserDAO.ConfigureDataSetsConnection;
begin
  inherited;
  DtsUser.Connection := Connection.Component.Connection;
end;

procedure TUserDAO.FindByLogin(const pLogin: string);
begin
  QueryBuilder(DtsUser).Build(
    SQL.Where('login').Like(pLogin, loContaining)
    ).Activate;
end;

function TUserDAO.GetConnection: TADOConnectionAdapter;
begin
  Result := TDatabaseADO.GetAdapter;
end;

end.
