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
  EMasterDoesNotExist = class(EInfraBaseException);
  EMasterDoesNotCompatible = class(EInfraBaseException);

  TGlobalCriticalSection = class sealed
  strict private
    class var SingletonCS: TCriticalSection;
    class constructor Create;
    class destructor Destroy;
  public
    class function GetInstance(): TCriticalSection; static;
  end;

implementation

{ TGlobalCriticalSection }

class constructor TGlobalCriticalSection.Create;
begin
  SingletonCS := TCriticalSection.Create();
end;

class destructor TGlobalCriticalSection.Destroy;
begin
  FreeAndNil(SingletonCS);
end;

class function TGlobalCriticalSection.GetInstance: TCriticalSection;
begin
  Result := SingletonCS;
end;

end.
