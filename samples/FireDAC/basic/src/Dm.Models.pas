unit Dm.Models;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type

  TDmModels = class(TDataModule)
    DtsCountry: TFDQuery;
    DtsProvince: TFDQuery;
    DtsCountryCTY_CODE: TIntegerField;
    DtsCountryCTY_NAME: TStringField;
    DtsProvincePRO_CODE: TIntegerField;
    DtsProvincePRO_NAME: TStringField;
    DtsProvinceCTY_CODE: TIntegerField;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  Connection.FireDAC;

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}

end.
