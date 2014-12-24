unit Province.DAO;

interface

uses
  System.SysUtils, System.Classes, Database.FireDAC, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  InfraFwk4D.Driver.FireDAC;

type

  TProvinceDAO = class(TDataModule, IFireDACPersistenceAdapter)
    Province: TFDQuery;
    City: TFDQuery;
    ProvinceID: TIntegerField;
    ProvinceNAME: TStringField;
    ProvinceCOUNTRYID: TIntegerField;
    CityID: TIntegerField;
    CityNAME: TStringField;
    CityPROVINCEID: TIntegerField;
  private
    function GetConnection(): TFireDACConnectionAdapter;
  public
    property Connection: TFireDACConnectionAdapter read GetConnection;
  end;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}

{ TProvinceDAO }

function TProvinceDAO.GetConnection: TFireDACConnectionAdapter;
begin
  Result := TDatabaseFireDAC.GetAdapter;
end;

end.
