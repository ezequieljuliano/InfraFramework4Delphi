unit Country.BC;

interface

uses
  InfraFwk4D.Driver.FireDAC, Country.DAO, InfraFwk4D.Attributes, InfraFwk4D.Iterator.DataSet;

type

  [DataSetComponent('Country')]
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
  QueryBuild(TSQLBuilder.Where('Id').Equal(pId));
end;

function TCountryBC.FindByName(const pName: string): IIteratorDataSet;
begin
  Result := Persistence.FindByName(pName);
end;

end.
