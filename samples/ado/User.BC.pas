unit User.BC;

interface

uses
  InfraFwk4D.Driver, User.DAO, InfraFwk4D.Iterator.DataSet;

type

  TUserBC = class(TBusinessAdapter<TUserDAO>)
  public
    procedure FindByLogin(const pName: string);
    procedure FilterById(const pId: Integer);
  end;

implementation

uses
  SQLBuilder4D;

{ TUserBC }

procedure TUserBC.FilterById(const pId: Integer);
begin
  Persistence.QueryBuilder('usuario').Build(SQL.Where('id').Equal(pId)).Activate;
end;

procedure TUserBC.FindByLogin(const pName: string);
begin
  Persistence.FindByLogin(pName);
end;

end.
