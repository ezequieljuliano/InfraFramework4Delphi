unit Province.DAO;

interface

uses
  System.SysUtils, System.Classes, InfraFwk4D.Persistence.Template.FireDAC, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type

  TProvinceDAO = class(TPersistenceTemplateFireDAC)
    Province: TFDQuery;
    City: TFDQuery;
    ProvinceID: TIntegerField;
    ProvinceNAME: TStringField;
    ProvinceCOUNTRYID: TIntegerField;
    CityID: TIntegerField;
    CityNAME: TStringField;
    CityPROVINCEID: TIntegerField;
    DsProvince: TDataSource;
  private
    { Private declarations }
  public
    { public declarations }
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

end.
