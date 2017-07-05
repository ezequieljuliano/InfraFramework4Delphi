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
    Button3: TButton;
    Label1: TLabel;
    Button4: TButton;
    Button5: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    fCountryBC: TCountryBC;
  public
    { public declarations }
  end;

implementation

uses
  DAL.Connection;

{$R *.dfm}

procedure TCountryView.Button1Click(Sender: TObject);
var
  name: string;
begin
  name := InputBox('Country', 'Name', '');
  with fCountryBC.Persistence.FindByName(name) do
    if not IsEmpty then
      ShowMessage('Country Id: ' + FieldByName('Id').AsString + ' Name: ' + FieldByName('Name').AsString)
    else
      ShowMessage('Not found!');
end;

procedure TCountryView.Button2Click(Sender: TObject);
var
  id: string;
begin
  id := InputBox('Country', 'Id', '');
  fCountryBC.Persistence.FilterById(StrToIntDef(id, 0));
  if fCountryBC.Persistence.Country.IsEmpty then
    ShowMessage('Not found!');
end;

procedure TCountryView.Button3Click(Sender: TObject);
begin
  fCountryBC.Persistence.Desfilter;
end;

procedure TCountryView.Button4Click(Sender: TObject);
begin
  fCountryBC.ProcessCounting;
end;

procedure TCountryView.Button5Click(Sender: TObject);
var
  id: string;
begin
  id := InputBox('Country', 'Id', '');
  with fCountryBC.Persistence.FindById(id.ToInteger) do
    if not IsEmpty then
      ShowMessage('Country Id: ' + FieldByName('Id').AsString + ' Name: ' + FieldByName('Name').AsString)
    else
      ShowMessage('Not found!');
end;

procedure TCountryView.FormCreate(Sender: TObject);
begin
  fCountryBC := TCountryBC.Create(TCountryDAO.Create(DALConnection.GetSession));
  DsoCountry.DataSet := fCountryBC.Persistence.Country;
  fCountryBC.Persistence.Country.Open;
  fCountryBC.RegisterObserver('OnCount',
    procedure(bc: TObject)
    begin
      Label1.Caption := 'Country Count: ' + (bc as TCountryBC).Count.ToString;
    end
    );
end;

procedure TCountryView.FormDestroy(Sender: TObject);
begin
  fCountryBC.Free;
end;

end.
