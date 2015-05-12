unit Country.DAO;

interface

uses
  System.SysUtils, System.Classes, Database.FireDAC, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  InfraFwk4D.Driver.FireDAC, InfraFwk4D.Iterator.DataSet, InfraFwk4D.Driver.FireDAC.Persistence;

type

  TCountryDAO = class(TFireDACPersistenceAdapter)
    Country: TFDQuery;
    CountryID: TIntegerField;
    CountryNAME: TStringField;
  strict protected
    function GetConnection(): TFireDACConnectionAdapter; override;
    procedure ConfigureDataSetsConnection(); override;
  public
    function FindByName(const pName: string): IIteratorDataSet;
  end;

implementation

uses
  SQLBuilder4D;

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}

{ TCountryDAO }

procedure TCountryDAO.ConfigureDataSetsConnection;
begin
  inherited;
  Country.Connection := Connection.Component.Connection;
end;

function TCountryDAO.FindByName(const pName: string): IIteratorDataSet;
begin
  Result := Connection.Statement.Build(
    SQL.Select.AllColumns.From('Country').Where('Name').Like(SQL.Value(pName).Like(loContaining).Insensetive)
    ).AsIterator;
end;

function TCountryDAO.GetConnection: TFireDACConnectionAdapter;
begin
  Result := TDatabaseFireDAC.GetAdapter;
end;

end.
