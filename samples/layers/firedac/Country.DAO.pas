unit Country.DAO;

interface

uses
  System.SysUtils, System.Classes, InfraFwk4D.Persistence.Template.FireDAC, DAL.Connection, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, InfraFwk4D.DataSet.Iterator, SQLBuilder4D;

type

  TCountryDAO = class(TPersistenceTemplateFireDAC)
    Country: TFDQuery;
    CountryID: TIntegerField;
    CountryNAME: TStringField;
  private
    { Private declarations }
  public
    function FindByName(const name: string): IDataSetIterator;
    function FindById(const id: Integer): IDataSetIterator;
    function FindAll: IDataSetIterator;

    procedure FilterById(const id: Integer);
    procedure Desfilter;
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

{ TCountryDAO }

procedure TCountryDAO.Desfilter;
begin
  QueryChanger('Country').Restore.Activate;
end;

procedure TCountryDAO.FilterById(const id: Integer);
begin
  QueryChanger('Country').Add(SQL.Where('Id').Equal(id)).Activate;
end;

function TCountryDAO.FindAll: IDataSetIterator;
begin
  Result := GetSession.NewStatement.Build(
    SQL.Select.AllColumns.From('Country')
    ).AsIterator;
end;

function TCountryDAO.FindById(const id: Integer): IDataSetIterator;
begin
  Result := GetSession.NewStatement.Build(
    SQL.Select.AllColumns.From('Country').Where('Id').Equal(SQL.Value(':ID').Expression)
    ).AddOrSetParam('ID', id).AsIterator;
end;

function TCountryDAO.FindByName(const name: string): IDataSetIterator;
begin
  Result := GetSession.NewStatement.Build(
    SQL.Select.AllColumns.From('Country').Where('Name').Like(SQL.Value(name).Like(loContaining).Insensetive)
    ).AsIterator;
end;

end.
