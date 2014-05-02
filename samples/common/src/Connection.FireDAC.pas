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

unit Connection.FireDAC;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, Data.DB,
  FireDAC.Comp.Client, FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.Phys.IBBase,
  FireDAC.Phys.FB, InfraDB4D.Drivers.FireDAC, InfraDB4D;

type

  TConnectionFireDAC = class(TDataModule)
    FDConnection: TFDConnection;
    FDPhysFBDriverLink: TFDPhysFBDriverLink;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private

  public
    function GetDatabase(): TFireDACConnectionAdapter;
  end;

var
  ConnectionFireDAC: TConnectionFireDAC;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}


procedure TConnectionFireDAC.DataModuleCreate(Sender: TObject);
begin
  FDConnection.Connected := True;
  GetDatabase.Build(TFireDACComponentAdapter.Create(FDConnection), True);
end;

procedure TConnectionFireDAC.DataModuleDestroy(Sender: TObject);
begin
  FDConnection.Connected := False;
end;

function TConnectionFireDAC.GetDatabase: TFireDACConnectionAdapter;
begin
  Result := TFireDACSingletonConnectionAdapter.Get();
end;

end.
