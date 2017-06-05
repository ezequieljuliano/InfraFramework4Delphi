unit Main.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus;

type

  TMainView = class(TForm)
    MainMenu1: TMainMenu;
    Cad1: TMenuItem;
    Country1: TMenuItem;
    Provinces1: TMenuItem;
    procedure Country1Click(Sender: TObject);
    procedure Provinces1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainView: TMainView;

implementation

uses
  Spring.Services, Country.View, Province.View;

{$R *.dfm}

procedure TMainView.Country1Click(Sender: TObject);
var
  countryView: TCountryView;
begin
  countryView := ServiceLocator.GetService<TCountryView>;
  try
    countryView.ShowModal;
  finally
    countryView.Free;
  end;
end;

procedure TMainView.Provinces1Click(Sender: TObject);
var
  provinceView: TProvinceView;
begin
  provinceView := ServiceLocator.GetService<TProvinceView>;
  try
    provinceView.ShowModal;
  finally
    provinceView.Free;
  end;
end;

end.
