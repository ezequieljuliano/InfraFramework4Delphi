unit Province.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Province.DAO, Data.DB, Vcl.ExtCtrls,
  Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Province.BC, Country.BC, Country.DAO;

type

  TProvinceView = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    DsoProvince: TDataSource;
    DsoCities: TDataSource;
    DBNavigator1: TDBNavigator;
    DBNavigator2: TDBNavigator;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    Panel1: TPanel;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    fProvinceBC: TProvinceBC;
    fCountryBC: TCountryBC;
  public
    { Public declarations }
  end;

implementation

uses
  DAL.Connection;

{$R *.dfm}

procedure TProvinceView.Button1Click(Sender: TObject);
var
  id: string;
begin
  if (fProvinceBC.Persistence.Province.State in [dsInsert, dsEdit]) then
  begin
    id := InputBox('Country', 'Id', '');
    fCountryBC.Persistence.FilterById(StrToIntDef(id, 0));
    if fProvinceBC.Persistence.Province.IsEmpty then
    begin
      ShowMessage('Not found!');
      Exit;
    end;
    fProvinceBC.Persistence.ProvinceCOUNTRYID.AsInteger := fCountryBC.Persistence.CountryID.AsInteger;
  end;
end;

procedure TProvinceView.FormCreate(Sender: TObject);
begin
  fProvinceBC := TProvinceBC.Create(TProvinceDAO.Create(DALConnection.GetSession));
  fCountryBC := TCountryBC.Create(TCountryDAO.Create(DALConnection.GetSession));

  DsoProvince.DataSet := fProvinceBC.Persistence.Province;
  DsoCities.DataSet := fProvinceBC.Persistence.City;

  fProvinceBC.Persistence.Province.Open;
  fProvinceBC.Persistence.City.Open;
end;

procedure TProvinceView.FormDestroy(Sender: TObject);
begin
  fProvinceBC.Free;
  fCountryBC.Free;
end;

end.
