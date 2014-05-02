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

unit InfraDB4D;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs;

type

  EInfraBaseException = class(Exception);
  EComponentDoesNotExist = class(EInfraBaseException);
  EStatementDoesNotExist = class(EInfraBaseException);
  EConnectionUnregistered = class(EInfraBaseException);
  EConnectionAlreadyRegistered = class(EInfraBaseException);
  EDetailUnregistered = class(EInfraBaseException);
  EDetailAlreadyRegistered = class(EInfraBaseException);
  EDataSetDoesNotExist = class(EInfraBaseException);
  EConnectionDoesNotExist = class(EInfraBaseException);
  EModelDoesNotExist = class(EInfraBaseException);

  TGlobalCriticalSection = class sealed
  public
    class function GetInstance(): TCriticalSection; static;
  end;

implementation

var
  _vCriticalSection: TCriticalSection;

  { TGlobalCriticalSection }

class function TGlobalCriticalSection.GetInstance: TCriticalSection;
begin
  Result := _vCriticalSection;
end;

initialization

_vCriticalSection := TCriticalSection.Create();

finalization

FreeAndNil(_vCriticalSection);

end.
