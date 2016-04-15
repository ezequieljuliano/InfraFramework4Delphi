unit InfraFwk4D;

interface

uses
  SysUtils,
  Classes,
  SyncObjs;

type

  EInfraException = class(Exception);
  EComponentDoesNotExist = class(EInfraException);
  EStatementDoesNotExist = class(EInfraException);
  EConnectionAlreadyRegistered = class(EInfraException);
  EConnectionUnregistered = class(EInfraException);
  EPersistenceDoesNotExist = class(EInfraException);
  EDataSetDoesNotExist = class(EInfraException);

  Critical = class sealed
  strict private
  const
    CanNotBeInstantiatedException = 'This class can not be instantiated!';
  strict private

    {$HINTS OFF}

    constructor Create;

    {$HINTS ON}

  public
    class function Section(): TCriticalSection; static;
  end;

implementation

type

  TSingletonCriticalSection = class sealed
  strict private
    class var Instance: TCriticalSection;
    class constructor Create;
    class destructor Destroy;
  public
    class function GetInstance: TCriticalSection; static;
  end;

  { Critical }

constructor Critical.Create;
begin
  raise EInfraException.Create(CanNotBeInstantiatedException);
end;

class function Critical.Section: TCriticalSection;
begin
  Result := TSingletonCriticalSection.GetInstance;
end;

{ TSingletonCriticalSection }

class constructor TSingletonCriticalSection.Create;
begin
  Instance := TCriticalSection.Create();
end;

class destructor TSingletonCriticalSection.Destroy;
begin
  FreeAndNil(Instance);
end;

class function TSingletonCriticalSection.GetInstance: TCriticalSection;
begin
  Result := Instance;
end;

end.
