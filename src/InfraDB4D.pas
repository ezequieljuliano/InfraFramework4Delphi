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
