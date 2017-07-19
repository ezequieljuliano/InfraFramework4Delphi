unit Country.DAO;

interface

uses
  System.SysUtils, System.Classes, InfraFwk4D.Persistence.Template.ADO, DAL.Connection,
  Data.DB, InfraFwk4D.DataSet.Iterator, SQLBuilder4D, Data.Win.ADODB;

type

  TCountryDAO = class(TPersistenceTemplateADO)
    Country: TADOQuery;
    Countryid: TAutoIncField;
    Countryname: TWideStringField;
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
  GetDelegate.QueryChanger('Country').Restore.Activate;
end;

procedure TCountryDAO.FilterById(const id: Integer);
begin
  GetDelegate.QueryChanger('Country').Add(SQL.Where('id').Equal(id)).Activate;
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
    SQL.Select.AllColumns.From('Country').Where('id').Equal(SQL.Value(':ID').Expression)
    ).AddOrSetParam('ID', id).AsIterator;
end;

function TCountryDAO.FindByName(const name: string): IDataSetIterator;
begin
  Result := GetSession.NewStatement.Build(
    SQL.Select.AllColumns.From('Country').Where('Name').Like(SQL.Value(name).Like(loContaining).Insensetive)
    ).AsIterator;
end;

end.
