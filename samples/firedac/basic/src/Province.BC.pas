unit Province.BC;

interface

uses
  InfraFwk4D.Driver.FireDAC, Province.DAO, InfraFwk4D.Attributes, InfraFwk4D.Iterator.DataSet,
  Data.DB;

type

  [DataSetComponent('Province')]
  TProvinceBC = class(TFireDACBusinessAdapter<TProvinceDAO>)
  public
    procedure AfterConstruction; override;
  end;

  [DataSetComponent('City')]
  TCityBC = class(TFireDACBusinessAdapter<TProvinceDAO>)
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
  Details.RegisterDetail('City', TCityBC.Create(Persistence, False), True);
end;

{ TCityBC }

procedure TCityBC.AfterConstruction;
begin
  inherited;
  DataSet.OnNewRecord := CityNewRecord;
end;

procedure TCityBC.CityNewRecord(DataSet: TDataSet);
begin
  Persistence.CityPROVINCEID.AsInteger := Persistence.ProvinceID.AsInteger;
end;

end.
