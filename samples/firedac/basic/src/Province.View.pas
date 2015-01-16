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
    FProvinceBC: TProvinceBC;
    FCountryBC: TCountryBC;
  public
    { Public declarations }
  end;

var
  ProvinceView: TProvinceView;

implementation

{$R *.dfm}

procedure TProvinceView.Button1Click(Sender: TObject);
var
  vId: string;
begin
  if (FProvinceBC.Persistence.Province.State in [dsInsert, dsEdit]) then
  begin
    vId := InputBox('Country', 'Id', '');
    FCountryBC.FilterById(StrToIntDef(vId, 0));
    if FProvinceBC.Persistence.Province.IsEmpty then
    begin
      ShowMessage('Not found!');
      Exit;
    end;
    FProvinceBC.Persistence.ProvinceCOUNTRYID.AsInteger := FCountryBC.Persistence.CountryID.AsInteger;
  end;
end;

procedure TProvinceView.FormCreate(Sender: TObject);
begin
  FProvinceBC := TProvinceBC.Create(TProvinceDAO);
  FCountryBC := TCountryBC.Create(TCountryDAO);

  DsoProvince.DataSet := FProvinceBC.Persistence.Province;
  DsoCities.DataSet := FProvinceBC.Persistence.City;

  FProvinceBC.Persistence.Province.Open();
  FProvinceBC.Persistence.City.Open();
end;

procedure TProvinceView.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FProvinceBC);
  FreeAndNil(FCountryBC);
end;

end.
