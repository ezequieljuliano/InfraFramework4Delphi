unit Customer.Model;

interface

uses
  System.SysUtils, System.Classes, InfraDB4D.Model.FireDAC, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type

  TCustomerModel = class(TModelFireDAC)
    DataSetCTR_CODE: TIntegerField;
    DataSetCTR_NAME: TStringField;
    DsCustomer: TDataSource;
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
