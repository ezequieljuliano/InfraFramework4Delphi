unit Country.Model;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Connection.FireDAC,
  InfraDB4D.Model.FireDAC;

type

  TCountryModel = class(TModelFireDAC)
    DataSetCTY_CODE: TIntegerField;
    DataSetCTY_NAME: TStringField;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}

end.
