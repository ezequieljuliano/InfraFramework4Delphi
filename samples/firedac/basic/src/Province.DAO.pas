unit Province.DAO;

interface

uses
  System.SysUtils, System.Classes, Database.FireDAC, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  InfraFwk4D.Driver.FireDAC, InfraFwk4D.Driver.FireDAC.Persistence;

type

  TProvinceDAO = class(TFireDACPersistenceAdapter)
    Province: TFDQuery;
    City: TFDQuery;
    ProvinceID: TIntegerField;
    ProvinceNAME: TStringField;
    ProvinceCOUNTRYID: TIntegerField;
    CityID: TIntegerField;
    CityNAME: TStringField;
    CityPROVINCEID: TIntegerField;
    DsProvince: TDataSource;
  strict protected
    function GetConnection(): TFireDACConnectionAdapter; override;
    procedure ConfigureDataSetsConnection(); override;
  public
    property Connection: TFireDACConnectionAdapter read GetConnection;
  end;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}

{ TProvinceDAO }

procedure TProvinceDAO.ConfigureDataSetsConnection;
begin
  inherited;
  Province.Connection := Connection.Component.Connection;
  City.Connection := Connection.Component.Connection;
end;

function TProvinceDAO.GetConnection: TFireDACConnectionAdapter;
begin
  Result := TDatabaseFireDAC.GetAdapter;
end;

end.
