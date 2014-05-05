unit Customer.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.ExtCtrls, Vcl.DBCtrls;

type

  TCustomerView = class(TForm)
    DBNavigator1: TDBNavigator;
    DBNavigator2: TDBNavigator;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    DsCustomer: TDataSource;
    DsCustomerContact: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  Dm.Models, Customer.Model, CustomerContact.Model;

{$R *.dfm}

end.
