unit CustomerContact.Model;

interface

uses
  System.SysUtils, System.Classes, InfraDB4D.Model.FireDAC, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type

  TCustomerContactModel = class(TModelFireDAC)
    DataSetCTC_CODE: TIntegerField;
    DataSetCTC_NAME: TStringField;
    DataSetCTR_CODE: TIntegerField;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  Connection.FireDAC, Customer.Model;

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}

end.
