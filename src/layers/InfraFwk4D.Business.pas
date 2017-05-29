unit InfraFwk4D.Business;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  System.Generics.Collections,
  InfraFwk4D.Observer,
  InfraFwk4D.DataSet.Events;

type

  EBusinessException = class(Exception)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  TBusinessController<T: TDataModule> = class
  private
    fPersistence: T;
    fOwnsPersistence: Boolean;
    fSubject: ISubject;
    fEvents: TDictionary<string, IDataSetEvents>;
  protected
    function GetPersistence: T;
    function GetObserver(const key: string): IObserver;

    function GetEvents(const dataSet: TDataSet): IDataSetEvents; overload;
    function GetEvents(const dataSetName: string): IDataSetEvents; overload;

    procedure NotifyObservers;
  public
    constructor Create(const persistence: T); overload;
    constructor Create(const persistence: T; const ownsPersistence: Boolean); overload;
    destructor Destroy; override;

    procedure RegisterObserver(const key: string; const observer: IObserver); overload;
    procedure RegisterObserver(const key: string; const notifyEvent: TProc<TObject>); overload;
    procedure UnregisterObserver(const key: string);

    property Persistence: T read GetPersistence;
    property OwnsPersistence: Boolean read fOwnsPersistence write fOwnsPersistence;
  end;

implementation

{ TBusinessController<T> }

constructor TBusinessController<T>.Create(const persistence: T);
begin
  Create(persistence, True);
end;

constructor TBusinessController<T>.Create(const persistence: T; const ownsPersistence: Boolean);
begin
  inherited Create;
  fPersistence := persistence;
  fOwnsPersistence := ownsPersistence;
  fSubject := TSubject.Create(Self);
  fEvents := TDictionary<string, IDataSetEvents>.Create;
end;

destructor TBusinessController<T>.Destroy;
begin
  if (fOwnsPersistence) and Assigned(fPersistence) then
    fPersistence.Free;
  fEvents.Free;
  inherited Destroy;
end;

function TBusinessController<T>.GetEvents(const dataSet: TDataSet): IDataSetEvents;
begin
  if not fEvents.ContainsKey(dataSet.Name) then
    fEvents.AddOrSetValue(dataSet.Name, TDataSetEvents.Create(dataSet));
  Result := fEvents.Items[dataSet.Name];
end;

function TBusinessController<T>.GetEvents(const dataSetName: string): IDataSetEvents;
begin
  Result := GetEvents(GetPersistence.FindComponent(dataSetName) as TDataSet);
end;

function TBusinessController<T>.GetObserver(const key: string): IObserver;
begin
  Result := fSubject.GetObserver(key);
end;

function TBusinessController<T>.GetPersistence: T;
begin
  if not Assigned(fPersistence) then
    raise EBusinessException.CreateFmt('Persistence layer not defined in %s!', [Self.ClassName]);
  Result := fPersistence;
end;

procedure TBusinessController<T>.NotifyObservers;
begin
  fSubject.NotifyObservers;
end;

procedure TBusinessController<T>.RegisterObserver(const key: string; const observer: IObserver);
begin
  fSubject.RegisterObserver(key, observer);
end;

procedure TBusinessController<T>.RegisterObserver(const key: string; const notifyEvent: TProc<TObject>);
begin
  fSubject.RegisterObserver(key, notifyEvent);
end;

procedure TBusinessController<T>.UnregisterObserver(const key: string);
begin
  fSubject.UnregisterObserver(key);
end;

end.
