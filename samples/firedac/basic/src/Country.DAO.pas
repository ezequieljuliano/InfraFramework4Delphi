unit Country.DAO;

interface

uses
  System.SysUtils, System.Classes, Database.FireDAC, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  InfraFwk4D.Driver.FireDAC, InfraFwk4D.Iterator.DataSet;

type

  TCountryDAO = class(TDataModule, IFireDACPersistenceAdapter)
    Country: TFDQuery;
    CountryID: TIntegerField;
    CountryNAME: TStringField;
  private
    function GetConnection(): TFireDACConnectionAdapter;
  public
    function FindByName(const pName: string): IIteratorDataSet;

    property Connection: TFireDACConnectionAdapter read GetConnection;
  end;

implementation

uses
  SQLBuilder4D;

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}

{ TCountryDAO }

function TCountryDAO.FindByName(const pName: string): IIteratorDataSet;
begin
  Result := Connection.Statement.Build(
    TSQLBuilder.Select.AllColumns.From('Country').Where('Name').Like(pName, False, loContaining)
    ).AsIterator;
end;

function TCountryDAO.GetConnection: TFireDACConnectionAdapter;
begin
  Result := TDatabaseFireDAC.GetAdapter;
end;

end.
