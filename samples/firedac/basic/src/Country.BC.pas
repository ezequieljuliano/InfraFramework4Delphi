unit Country.BC;

interface

uses
  InfraFwk4D.Driver.FireDAC, Country.DAO, InfraFwk4D.Iterator.DataSet;

type

  TCountryBC = class(TFireDACBusinessAdapter<TCountryDAO>)
  public
    function FindByName(const pName: string): IIteratorDataSet;
    procedure FilterById(const pId: Integer);
  end;

implementation

uses
  SQLBuilder4D;

{ TCountryBC }

procedure TCountryBC.FilterById(const pId: Integer);
begin
  Persistence.QueryBuilder('Country').Build(TSQLBuilder.Where('Id').Equal(pId)).Activate;
end;

function TCountryBC.FindByName(const pName: string): IIteratorDataSet;
begin
  Result := Persistence.FindByName(pName);
end;

end.
