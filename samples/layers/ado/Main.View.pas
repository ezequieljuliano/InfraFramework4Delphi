unit Main.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB, Data.Win.ADODB;

type

  TMainView = class(TForm)
    MainMenu1: TMainMenu;
    Cad1: TMenuItem;
    Country1: TMenuItem;
    procedure Country1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainView: TMainView;

implementation

uses
  Country.View;

{$R *.dfm}

procedure TMainView.Country1Click(Sender: TObject);
var
  countryView: TCountryView;
begin
  countryView := TCountryView.Create(nil);
  try
    countryView.ShowModal;
  finally
    countryView.Free;
  end;
end;

end.
