unit Main.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type

  TMainView = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainView: TMainView;

implementation

uses
  Country.View, Province.View;

{$R *.dfm}

procedure TMainView.Button1Click(Sender: TObject);
begin
  CountryView := TCountryView.Create(nil);
  try
    CountryView.ShowModal;
  finally
    CountryView.Release;
  end;
end;

procedure TMainView.Button2Click(Sender: TObject);
begin
  ProvinceView := TProvinceView.Create(nil);
  try
    ProvinceView.ShowModal;
  finally
    ProvinceView.Release;
  end;
end;

end.
