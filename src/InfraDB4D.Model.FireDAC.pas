unit InfraDB4D.Model.FireDAC;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  InfraDB4D,
  InfraDB4D.Model.Base,
  InfraDB4D.Drivers.FireDAC,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type

  TModelFireDAC = class(TModelBase)
    DataSet: TFDQuery;
  strict private

  public

  end;

implementation

{ %CLASSGROUP 'System.Classes.TPersistent' }

{$R *.dfm}

end.
