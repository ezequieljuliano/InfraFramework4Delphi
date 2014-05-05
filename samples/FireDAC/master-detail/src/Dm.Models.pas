unit Dm.Models;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type

  TDmModels = class(TDataModule)
    DtsCustomer: TFDQuery;
    DtsCustomerCTR_CODE: TIntegerField;
    DtsCustomerCTR_NAME: TStringField;
    DsCustomer: TDataSource;
    DtsCustomerContact: TFDQuery;
    DtsCustomerContactCTC_CODE: TIntegerField;
    DtsCustomerContactCTC_NAME: TStringField;
    DtsCustomerContactCTR_CODE: TIntegerField;
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
