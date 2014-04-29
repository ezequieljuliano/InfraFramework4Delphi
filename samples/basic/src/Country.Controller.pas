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

unit Country.Controller;

interface

uses
  InfraDB4D.Drivers.FireDAC, System.SysUtils;

type

  TCountryController = class(TFireDACControllerAdapter)
  public
    procedure ValidateFields();
  end;

implementation

{ TCountryController }

procedure TCountryController.ValidateFields;
begin
  if (GetDataSet.FieldByName('CTY_CODE').AsInteger = 0) then
    raise Exception.Create('Country Code is null!');
end;

end.
