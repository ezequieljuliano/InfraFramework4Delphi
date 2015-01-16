unit Country.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Country.DAO, Data.DB, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.StdCtrls, Vcl.Mask, Country.BC;

type

  TCountryView = class(TForm)
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    DsoCountry: TDataSource;
    Panel1: TPanel;
    Button2: TButton;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    FCountryBC: TCountryBC;
  public
    { Public declarations }
  end;

var
  CountryView: TCountryView;

implementation

{$R *.dfm}

procedure TCountryView.Button1Click(Sender: TObject);
var
  vName: string;
begin
  vName := InputBox('Country', 'Name', '');
  with FCountryBC.FindByName(vName) do
    if not IsEmpty then
      ShowMessage('Country Id: ' + FieldByName('Id').AsString + ' Name: ' + FieldByName('Name').AsString)
    else
      ShowMessage('Not found!');
end;

procedure TCountryView.Button2Click(Sender: TObject);
var
  vId: string;
begin
  vId := InputBox('Country', 'Id', '');
  FCountryBC.FilterById(StrToIntDef(vId, 0));
  if FCountryBC.Persistence.Country.IsEmpty then
    ShowMessage('Not found!');
end;

procedure TCountryView.FormCreate(Sender: TObject);
begin
  FCountryBC := TCountryBC.Create(TCountryDAO);
  DsoCountry.DataSet := FCountryBC.Persistence.Country;
  FCountryBC.Persistence.Country.Open();
end;

procedure TCountryView.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FCountryBC);
end;

end.
