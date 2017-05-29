unit Province.BC;

interface

uses
  InfraFwk4D.Business,
  InfraFwk4D.DataSet.Iterator,
  Province.DAO,
  Data.DB;

type

  TProvinceBC = class(TBusinessController<TProvinceDAO>)
  private
    { private declarations }
  public
    procedure AfterConstruction; override;
  end;

implementation

{ TProvinceBC }

procedure TProvinceBC.AfterConstruction;
begin
  inherited AfterConstruction;
  GetEvents(Persistence.City).OnNewRecord.Add('AutoIncCity',
    procedure(dataSet: TDataSet)
    begin
      Persistence.CityPROVINCEID.AsInteger := Persistence.ProvinceID.AsInteger;
    end
    );
end;

end.
