unit Country.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Connection.FireDAC, Data.DB,
  Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Vcl.DBCtrls;

type

  TCountryView = class(TForm)
    DBNavigator1: TDBNavigator;
    DBGrid1: TDBGrid;
    DsCountry: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CountryView: TCountryView;

implementation

uses
  Country.Model;

{$R *.dfm}

end.
