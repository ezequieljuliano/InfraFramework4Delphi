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
    procedure CityNewRecord(DataSet: TDataSet);
  public
    procedure AfterConstruction; override;
  end;

implementation

{ TProvinceBC }

procedure TProvinceBC.AfterConstruction;
begin
  inherited AfterConstruction;
  Persistence.City.OnNewRecord := CityNewRecord;
end;

procedure TProvinceBC.CityNewRecord(DataSet: TDataSet);
begin
  Persistence.CityPROVINCEID.AsInteger := Persistence.ProvinceID.AsInteger;
end;

end.
