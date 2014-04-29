(*
  Copyright 2014 Ezequiel Juliano Müller | Microsys Sistemas Ltda

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*)

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
    FController: TFireDACControllerAdapter;
    FDestroyController: Boolean;
  public
    constructor Create(const pOwner: TComponent; const pController: TFireDACControllerAdapter); reintroduce; overload;
    constructor Create(const pOwner: TComponent; const pControllerClass: TFireDACDBControllerClass;
      const pConnection: TFireDACConnectionAdapter); reintroduce; overload;
    destructor Destroy; override;

    function GetController<T: TFireDACControllerAdapter>(): T;
  end;

implementation

{ %CLASSGROUP 'System.Classes.TPersistent' }

{$R *.dfm}

{ TDMICRUDFireDAC }

constructor TModelFireDAC.Create(const pOwner: TComponent;
  const pController: TFireDACControllerAdapter);
begin
  inherited Create(pOwner);
  DataSet.Close;
  FDestroyController := False;
  FController := pController;
  FController.SetDataSet(DataSet);
  DataSet.Connection := FController.GetConnection.GetComponent.GetCompConnection;
end;

constructor TModelFireDAC.Create(const pOwner: TComponent;
  const pControllerClass: TFireDACDBControllerClass;
  const pConnection: TFireDACConnectionAdapter);
begin
  inherited Create(pOwner);
  DataSet.Close;
  FDestroyController := True;
  FController := pControllerClass.Create(pConnection, DataSet);
  DataSet.Connection := FController.GetConnection.GetComponent.GetCompConnection;
end;

destructor TModelFireDAC.Destroy;
begin
  if FDestroyController then
    FreeAndNil(FController);
  inherited Destroy();
end;

function TModelFireDAC.GetController<T>: T;
begin
  Result := T(FController);
end;

end.
