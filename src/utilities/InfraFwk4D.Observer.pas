unit InfraFwk4D.Observer;

interface

uses
  System.SysUtils,
  System.Generics.Collections;

type

  EObserverException = class(Exception)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  IObserver = interface
    ['{6B577B7F-9811-428D-9935-A6185AE6202A}']
    procedure Notify(const sender: TObject);
  end;

  ISubject = interface
    ['{F28FC61E-904F-4390-A883-95A982F1068D}']
    procedure RegisterObserver(const key: string; const observer: IObserver); overload;
    procedure RegisterObserver(const key: string; const notifyEvent: TProc<TObject>); overload;
    procedure UnregisterObserver(const key: string);
    procedure NotifyObservers;
    function  GetObserver(const key: string): IObserver;
  end;

  TObserver = class(TInterfacedObject, IObserver)
  private
    fNotifyEvent: TProc<TObject>;
  protected
    procedure Notify(const sender: TObject);
  public
    constructor Create(const notifyEvent: TProc<TObject>);
  end;

  TSubject = class(TInterfacedObject, ISubject)
  private
    fOwner: TObject;
    fObservers: TDictionary<string, IObserver>;
  protected
    procedure RegisterObserver(const key: string; const observer: IObserver); overload;
    procedure RegisterObserver(const key: string; const notifyEvent: TProc<TObject>); overload;
    procedure UnregisterObserver(const key: string);
    procedure NotifyObservers;
    function  GetObserver(const key: string): IObserver;
  public
    constructor Create(const owner: TObject);
    destructor Destroy; override;
  end;

implementation

{ TObserver }

constructor TObserver.Create(const notifyEvent: TProc<TObject>);
begin
  inherited Create;
  fNotifyEvent := notifyEvent;
end;

procedure TObserver.Notify(const sender: TObject);
begin
  fNotifyEvent(sender);
end;

{ TSubject }

constructor TSubject.Create(const owner: TObject);
begin
  inherited Create;
  fOwner := owner;
  fObservers := TDictionary<string, IObserver>.Create;
end;

destructor TSubject.Destroy;
begin
  fObservers.Free;
  inherited Destroy;
end;

function TSubject.GetObserver(const key: string): IObserver;
begin
  if not fObservers.ContainsKey(key) then
    raise EObserverException.CreateFmt('Observer %s not registered!', [key]);
  Result := fObservers.Items[key];
end;

procedure TSubject.NotifyObservers;
var
  pair: TPair<string, IObserver>;
begin
  for pair in fObservers do
    pair.Value.Notify(fOwner);
end;

procedure TSubject.RegisterObserver(const key: string; const notifyEvent: TProc<TObject>);
begin
  RegisterObserver(key, TObserver.Create(notifyEvent));
end;

procedure TSubject.RegisterObserver(const key: string; const observer: IObserver);
begin
  if fObservers.ContainsKey(key) then
    raise EObserverException.CreateFmt('There is already an Observer registered with the key %s!', [key]);
  fObservers.AddOrSetValue(key, observer);
end;

procedure TSubject.UnregisterObserver(const key: string);
begin
  if fObservers.ContainsKey(key) then
    fObservers.Remove(key);
end;

end.
