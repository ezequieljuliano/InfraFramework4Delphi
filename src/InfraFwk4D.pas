unit InfraFwk4D;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs;

type

  EInfraException = class(Exception);
  EComponentDoesNotExist = class(EInfraException);
  EStatementDoesNotExist = class(EInfraException);
  EConnectionAlreadyRegistered = class(EInfraException);
  EConnectionUnregistered = class(EInfraException);
  EPersistenceDoesNotExist = class(EInfraException);
  EDataSetDoesNotExist = class(EInfraException);
  EConnectionDoesNotExist = class(EInfraException);
  EOwnerBusinessDoesNotCompatible = class(EInfraException);
  EOwnerBusinessDoesNotExist = class(EInfraException);
  EDetailUnregistered = class(EInfraException);
  EDetailAlreadyRegistered = class(EInfraException);

function GlobalCriticalSection(): TCriticalSection;

implementation

type

  TGlobalCriticalSection = class sealed
  strict private
    class var SingletonCS: TCriticalSection;
    class constructor Create;
    class destructor Destroy;
  public
    class function GetInstance(): TCriticalSection; static;
  end;

function GlobalCriticalSection(): TCriticalSection;
begin
  Result := TGlobalCriticalSection.GetInstance();
end;

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
