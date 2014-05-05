unit Main.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type

  TMainView = class(TForm)
    Button5: TButton;
    Button1: TButton;
    Button2: TButton;
    procedure Button5Click(Sender: TObject);
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
  Customer.Model, CustomerContact.Model, Customer.Controller, CustomerContact.Controller,
  Dm.Models, Customer.View, Connection.FireDAC;

{$R *.dfm}


procedure TMainView.Button1Click(Sender: TObject);
var
  vCustomerView: TCustomerView;
  vCustomerController: TCustomerController;
  vContactController: TCustomerContactController;
begin
  vCustomerView := TCustomerView.Create(nil);
  vCustomerController := TCustomerController.Create(ConnectionFireDAC.GetDatabase, TCustomerModel, 'DataSet');
  try
    vContactController := TCustomerContactController.Create(ConnectionFireDAC.GetDatabase, TCustomerContactModel, 'DataSet');
    vCustomerController.GetDetails.RegisterDetail('Contact', vContactController, True);

    vCustomerView.DsCustomer.DataSet := vCustomerController.GetDataSet;
    vCustomerView.DsCustomerContact.DataSet := vCustomerController.GetDetails.GetDetail('Contact').GetDataSet;

    vCustomerController.GetDataSet.Open();
    vCustomerController.GetDetails.OpenAll();

    vCustomerView.ShowModal;
  finally
    FreeAndNil(vCustomerController);
    FreeAndNil(vCustomerView);
  end;
end;

procedure TMainView.Button2Click(Sender: TObject);
var
  vModels: TDmModels;
  vCustomerView: TCustomerView;
  vCustomerController: TCustomerController;
begin
  vModels := TDmModels.Create(nil);
  vCustomerView := TCustomerView.Create(nil);
  vCustomerController := TCustomerController.Create(ConnectionFireDAC.GetDatabase, vModels, vModels.DtsCustomer);
  try
    vCustomerController.GetDetails.RegisterDetail('Contact',
      TCustomerContactController.Create(ConnectionFireDAC.GetDatabase, vModels, vModels.DtsCustomerContact), True);

    vCustomerView.DsCustomer.DataSet := vCustomerController.GetDataSet;
    vCustomerView.DsCustomerContact.DataSet := vCustomerController.GetDetails.GetDetail('Contact').GetDataSet;

    vCustomerController.GetDataSet.Open();
    vCustomerController.GetDetails.OpenAll();

    vCustomerView.ShowModal;
  finally
    FreeAndNil(vModels);
    FreeAndNil(vCustomerView);
    FreeAndNil(vCustomerController);
  end;
end;

procedure TMainView.Button5Click(Sender: TObject);
var
  vCustomerView: TCustomerView;
  vCustomerController: TCustomerController;
begin
  vCustomerView := TCustomerView.Create(nil);
  vCustomerController := TCustomerController.Create(ConnectionFireDAC.GetDatabase, TCustomerModel, 'DataSet');
  try
    vCustomerController.GetDetails.RegisterDetail('Contact',
      TCustomerContactController.Create(ConnectionFireDAC.GetDatabase, TCustomerContactModel, 'DataSet'), True);

    vCustomerView.DsCustomer.DataSet := vCustomerController.GetDataSet;
    vCustomerView.DsCustomerContact.DataSet := vCustomerController.GetDetails.GetDetail('Contact').GetDataSet;

    vCustomerController.GetDataSet.Open();
    vCustomerController.GetDetails.OpenAll();

    vCustomerView.ShowModal;
  finally
    FreeAndNil(vCustomerController);
    FreeAndNil(vCustomerView);
  end;
end;

end.
