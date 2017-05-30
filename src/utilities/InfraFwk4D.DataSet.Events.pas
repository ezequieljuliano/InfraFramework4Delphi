unit InfraFwk4D.DataSet.Events;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB;

type

  TAnonymousNotifyEvent = reference to procedure(dataSet: TDataSet);
  TAnonymousErrorEvent  = reference to procedure(dataSet: TDataSet; e: EDatabaseError; var action: TDataAction);

  EDataSetEventsException = class(Exception)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  IDataSetNotifyEvents = interface
    ['{5001E840-432E-4833-B764-41E32BAA8DD2}']
    procedure Add(const key: string; const event: TDataSetNotifyEvent); overload;
    procedure Add(const key: string; const event: TAnonymousNotifyEvent); overload;
    procedure Remove(const key: string);
    procedure Clear;
    function Count: Integer;
    procedure Execute(dataSet: TDataSet);
  end;

  IDataSetErrorEvents = interface
    ['{50D8CC36-5F83-4767-A70C-98BD4E301D95}']
    procedure Add(const key: string; const event: TDataSetErrorEvent); overload;
    procedure Add(const key: string; const event: TAnonymousErrorEvent); overload;
    procedure Remove(const key: string);
    procedure Clear;
    function Count: Integer;
    procedure Execute(dataSet: TDataSet; e: EDatabaseError; var action: TDataAction);
  end;

  IDataSetEvents = interface
    ['{8FAB5F98-4A30-42A9-B4CA-A45E382F9EED}']
    function BeforeOpen: IDataSetNotifyEvents;
    function AfterOpen: IDataSetNotifyEvents;
    function BeforeClose: IDataSetNotifyEvents;
    function AfterClose: IDataSetNotifyEvents;
    function BeforeInsert: IDataSetNotifyEvents;
    function AfterInsert: IDataSetNotifyEvents;
    function BeforeEdit: IDataSetNotifyEvents;
    function AfterEdit: IDataSetNotifyEvents;
    function BeforePost: IDataSetNotifyEvents;
    function AfterPost: IDataSetNotifyEvents;
    function BeforeCancel: IDataSetNotifyEvents;
    function AfterCancel: IDataSetNotifyEvents;
    function BeforeDelete: IDataSetNotifyEvents;
    function AfterDelete: IDataSetNotifyEvents;
    function BeforeRefresh: IDataSetNotifyEvents;
    function AfterRefresh: IDataSetNotifyEvents;
    function BeforeScroll: IDataSetNotifyEvents;
    function AfterScroll: IDataSetNotifyEvents;
    function OnNewRecord: IDataSetNotifyEvents;
    function OnCalcFields: IDataSetNotifyEvents;
    function OnEditError: IDataSetErrorEvents;
    function OnPostError: IDataSetErrorEvents;
    function OnDeleteError: IDataSetErrorEvents;
  end;

  TDataSetEvents = class(TInterfacedObject, IDataSetEvents)
  private
    fDataSet: TDataSet;
    fBeforeOpen: IDataSetNotifyEvents;
    fAfterOpen: IDataSetNotifyEvents;
    fBeforeClose: IDataSetNotifyEvents;
    fAfterClose: IDataSetNotifyEvents;
    fBeforeInsert: IDataSetNotifyEvents;
    fAfterInsert: IDataSetNotifyEvents;
    fBeforeEdit: IDataSetNotifyEvents;
    fAfterEdit: IDataSetNotifyEvents;
    fBeforePost: IDataSetNotifyEvents;
    fAfterPost: IDataSetNotifyEvents;
    fBeforeCancel: IDataSetNotifyEvents;
    fAfterCancel: IDataSetNotifyEvents;
    fBeforeDelete: IDataSetNotifyEvents;
    fAfterDelete: IDataSetNotifyEvents;
    fBeforeRefresh: IDataSetNotifyEvents;
    fAfterRefresh: IDataSetNotifyEvents;
    fBeforeScroll: IDataSetNotifyEvents;
    fAfterScroll: IDataSetNotifyEvents;
    fOnNewRecord: IDataSetNotifyEvents;
    fOnCalcFields: IDataSetNotifyEvents;
    fOnEditError: IDataSetErrorEvents;
    fOnPostError: IDataSetErrorEvents;
    fOnDeleteError: IDataSetErrorEvents;
    procedure DoBeforeOpen(dataSet: TDataSet);
    procedure DoAfterOpen(dataSet: TDataSet);
    procedure DoBeforeClose(dataSet: TDataSet);
    procedure DoAfterClose(dataSet: TDataSet);
    procedure DoBeforeInsert(dataSet: TDataSet);
    procedure DoAfterInsert(dataSet: TDataSet);
    procedure DoBeforeEdit(dataSet: TDataSet);
    procedure DoAfterEdit(dataSet: TDataSet);
    procedure DoBeforePost(dataSet: TDataSet);
    procedure DoAfterPost(dataSet: TDataSet);
    procedure DoBeforeCancel(dataSet: TDataSet);
    procedure DoAfterCancel(dataSet: TDataSet);
    procedure DoBeforeDelete(dataSet: TDataSet);
    procedure DoAfterDelete(dataSet: TDataSet);
    procedure DoBeforeRefresh(dataSet: TDataSet);
    procedure DoAfterRefresh(dataSet: TDataSet);
    procedure DoBeforeScroll(dataSet: TDataSet);
    procedure DoAfterScroll(dataSet: TDataSet);
    procedure DoOnNewRecord(dataSet: TDataSet);
    procedure DoOnCalcFields(dataSet: TDataSet);
    procedure DoOnEditError(dataSet: TDataSet; e: EDatabaseError; var action: TDataAction);
    procedure DoOnPostError(dataSet: TDataSet; e: EDatabaseError; var action: TDataAction);
    procedure DoOnDeleteError(dataSet: TDataSet; e: EDatabaseError; var action: TDataAction);
    procedure Setup;
  protected
    function BeforeOpen: IDataSetNotifyEvents;
    function AfterOpen: IDataSetNotifyEvents;
    function BeforeClose: IDataSetNotifyEvents;
    function AfterClose: IDataSetNotifyEvents;
    function BeforeInsert: IDataSetNotifyEvents;
    function AfterInsert: IDataSetNotifyEvents;
    function BeforeEdit: IDataSetNotifyEvents;
    function AfterEdit: IDataSetNotifyEvents;
    function BeforePost: IDataSetNotifyEvents;
    function AfterPost: IDataSetNotifyEvents;
    function BeforeCancel: IDataSetNotifyEvents;
    function AfterCancel: IDataSetNotifyEvents;
    function BeforeDelete: IDataSetNotifyEvents;
    function AfterDelete: IDataSetNotifyEvents;
    function BeforeRefresh: IDataSetNotifyEvents;
    function AfterRefresh: IDataSetNotifyEvents;
    function BeforeScroll: IDataSetNotifyEvents;
    function AfterScroll: IDataSetNotifyEvents;
    function OnNewRecord: IDataSetNotifyEvents;
    function OnCalcFields: IDataSetNotifyEvents;
    function OnEditError: IDataSetErrorEvents;
    function OnPostError: IDataSetErrorEvents;
    function OnDeleteError: IDataSetErrorEvents;
  public
    constructor Create(const dataSet: TDataSet);
    destructor Destroy; override;
  end;

implementation

type

  TDataSetNotifyEvents = class(TInterfacedObject, IDataSetNotifyEvents)
  private
    fDataSetNotifyEvents: TDictionary<string, TDataSetNotifyEvent>;
    fAnonymousNotifyEvents: TDictionary<string, TAnonymousNotifyEvent>;
  protected
    procedure Add(const key: string; const event: TDataSetNotifyEvent); overload;
    procedure Add(const key: string; const event: TAnonymousNotifyEvent); overload;
    procedure Remove(const key: string);
    procedure Clear;
    function Count: Integer;
    procedure Execute(dataSet: TDataSet);
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TDataSetErrorEvents = class(TInterfacedObject, IDataSetErrorEvents)
  private
    fDataSetErrorEvents: TDictionary<string, TDataSetErrorEvent>;
    fAnonymousErrorEvents: TDictionary<string, TAnonymousErrorEvent>;
  protected
    procedure Add(const key: string; const event: TDataSetErrorEvent); overload;
    procedure Add(const key: string; const event: TAnonymousErrorEvent); overload;
    procedure Remove(const key: string);
    procedure Clear;
    function Count: Integer;
    procedure Execute(dataSet: TDataSet; e: EDatabaseError; var action: TDataAction);
  public
    constructor Create;
    destructor Destroy; override;
  end;

  { TDataSetNotifyEvents }

procedure TDataSetNotifyEvents.Add(const key: string; const event: TDataSetNotifyEvent);
begin
  if fDataSetNotifyEvents.ContainsKey(key) or fAnonymousNotifyEvents.ContainsKey(key) then
    raise EDataSetEventsException.Create('This key already exists for another DataSet Event!');
  fDataSetNotifyEvents.AddOrSetValue(key, event);
end;

procedure TDataSetNotifyEvents.Add(const key: string; const event: TAnonymousNotifyEvent);
begin
  if fAnonymousNotifyEvents.ContainsKey(key) or fDataSetNotifyEvents.ContainsKey(key) then
    raise EDataSetEventsException.Create('This key already exists for another DataSet Event!');
  fAnonymousNotifyEvents.AddOrSetValue(key, event);
end;

procedure TDataSetNotifyEvents.Clear;
begin
  fDataSetNotifyEvents.Clear;
  fAnonymousNotifyEvents.Clear;
end;

function TDataSetNotifyEvents.Count: Integer;
begin
  Result := fDataSetNotifyEvents.Count + fAnonymousNotifyEvents.Count;
end;

constructor TDataSetNotifyEvents.Create;
begin
  inherited Create;
  fDataSetNotifyEvents := TDictionary<string, TDataSetNotifyEvent>.Create;
  fAnonymousNotifyEvents := TDictionary<string, TAnonymousNotifyEvent>.Create;
end;

destructor TDataSetNotifyEvents.Destroy;
begin
  fDataSetNotifyEvents.Free;
  fAnonymousNotifyEvents.Free;
  inherited Destroy;
end;

procedure TDataSetNotifyEvents.Execute(dataSet: TDataSet);
var
  p1: TPair<string, TDataSetNotifyEvent>;
  p2: TPair<string, TAnonymousNotifyEvent>;
begin
  for p1 in fDataSetNotifyEvents do
    p1.Value(dataSet);

  for p2 in fAnonymousNotifyEvents do
    p2.Value(dataSet);
end;

procedure TDataSetNotifyEvents.Remove(const key: string);
begin
  if fDataSetNotifyEvents.ContainsKey(key) then
    fDataSetNotifyEvents.Remove(key);

  if fAnonymousNotifyEvents.ContainsKey(key) then
    fAnonymousNotifyEvents.Remove(key);
end;

{ TDataSetErrorEvents }

procedure TDataSetErrorEvents.Add(const key: string; const event: TDataSetErrorEvent);
begin
  if fDataSetErrorEvents.ContainsKey(key) or fAnonymousErrorEvents.ContainsKey(key) then
    raise EDataSetEventsException.Create('This key already exists for another DataSet Event!');
  fDataSetErrorEvents.AddOrSetValue(key, event);
end;

procedure TDataSetErrorEvents.Add(const key: string; const event: TAnonymousErrorEvent);
begin
  if fAnonymousErrorEvents.ContainsKey(key) or fDataSetErrorEvents.ContainsKey(key) then
    raise EDataSetEventsException.Create('This key already exists for another DataSet Event!');
  fAnonymousErrorEvents.AddOrSetValue(key, event);
end;

procedure TDataSetErrorEvents.Clear;
begin
  fDataSetErrorEvents.Clear;
  fAnonymousErrorEvents.Clear;
end;

function TDataSetErrorEvents.Count: Integer;
begin
  Result := fDataSetErrorEvents.Count + fAnonymousErrorEvents.Count;
end;

constructor TDataSetErrorEvents.Create;
begin
  inherited Create;
  fDataSetErrorEvents := TDictionary<string, TDataSetErrorEvent>.Create;
  fAnonymousErrorEvents := TDictionary<string, TAnonymousErrorEvent>.Create;
end;

destructor TDataSetErrorEvents.Destroy;
begin
  fDataSetErrorEvents.Free;
  fAnonymousErrorEvents.Free;
  inherited Destroy;
end;

procedure TDataSetErrorEvents.Execute(dataSet: TDataSet; e: EDatabaseError; var action: TDataAction);
var
  p1: TPair<string, TDataSetErrorEvent>;
  p2: TPair<string, TAnonymousErrorEvent>;
begin
  for p1 in fDataSetErrorEvents do
    p1.Value(dataSet, e, action);

  for p2 in fAnonymousErrorEvents do
    p2.Value(dataSet, e, action);
end;

procedure TDataSetErrorEvents.Remove(const key: string);
begin
  if fDataSetErrorEvents.ContainsKey(key) then
    fDataSetErrorEvents.Remove(key);

  if fAnonymousErrorEvents.ContainsKey(key) then
    fAnonymousErrorEvents.Remove(key);
end;

{ TDataSetEvents }

function TDataSetEvents.AfterCancel: IDataSetNotifyEvents;
begin
  if not Assigned(fAfterCancel) then fAfterCancel := TDataSetNotifyEvents.Create;
  Result := fAfterCancel;
end;

function TDataSetEvents.AfterClose: IDataSetNotifyEvents;
begin
  if not Assigned(fAfterClose) then fAfterClose := TDataSetNotifyEvents.Create;
  Result := fAfterClose;
end;

function TDataSetEvents.AfterDelete: IDataSetNotifyEvents;
begin
  if not Assigned(fAfterDelete) then fAfterDelete := TDataSetNotifyEvents.Create;
  Result := fAfterDelete;
end;

function TDataSetEvents.AfterEdit: IDataSetNotifyEvents;
begin
  if not Assigned(fAfterEdit) then fAfterEdit := TDataSetNotifyEvents.Create;
  Result := fAfterEdit;
end;

function TDataSetEvents.AfterInsert: IDataSetNotifyEvents;
begin
  if not Assigned(fAfterInsert) then fAfterInsert := TDataSetNotifyEvents.Create;
  Result := fAfterInsert;
end;

function TDataSetEvents.AfterOpen: IDataSetNotifyEvents;
begin
  if not Assigned(fAfterOpen) then fAfterOpen := TDataSetNotifyEvents.Create;
  Result := fAfterOpen;
end;

function TDataSetEvents.AfterPost: IDataSetNotifyEvents;
begin
  if not Assigned(fAfterPost) then fAfterPost := TDataSetNotifyEvents.Create;
  Result := fAfterPost;
end;

function TDataSetEvents.AfterRefresh: IDataSetNotifyEvents;
begin
  if not Assigned(fAfterRefresh) then fAfterRefresh := TDataSetNotifyEvents.Create;
  Result := fAfterRefresh;
end;

function TDataSetEvents.AfterScroll: IDataSetNotifyEvents;
begin
  if not Assigned(fAfterScroll) then fAfterScroll := TDataSetNotifyEvents.Create;
  Result := fAfterScroll;
end;

function TDataSetEvents.BeforeCancel: IDataSetNotifyEvents;
begin
  if not Assigned(fBeforeCancel) then fBeforeCancel := TDataSetNotifyEvents.Create;
  Result := fBeforeCancel;
end;

function TDataSetEvents.BeforeClose: IDataSetNotifyEvents;
begin
  if not Assigned(fBeforeClose) then fBeforeClose := TDataSetNotifyEvents.Create;
  Result := fBeforeClose;
end;

function TDataSetEvents.BeforeDelete: IDataSetNotifyEvents;
begin
  if not Assigned(fBeforeDelete) then fBeforeDelete := TDataSetNotifyEvents.Create;
  Result := fBeforeDelete;
end;

function TDataSetEvents.BeforeEdit: IDataSetNotifyEvents;
begin
  if not Assigned(fBeforeEdit) then fBeforeEdit := TDataSetNotifyEvents.Create;
  Result := fBeforeEdit;
end;

function TDataSetEvents.BeforeInsert: IDataSetNotifyEvents;
begin
  if not Assigned(fBeforeInsert) then fBeforeInsert := TDataSetNotifyEvents.Create;
  Result := fBeforeInsert;
end;

function TDataSetEvents.BeforeOpen: IDataSetNotifyEvents;
begin
  if not Assigned(fBeforeOpen) then fBeforeOpen := TDataSetNotifyEvents.Create;
  Result := fBeforeOpen;
end;

function TDataSetEvents.BeforePost: IDataSetNotifyEvents;
begin
  if not Assigned(fBeforePost) then fBeforePost := TDataSetNotifyEvents.Create;
  Result := fBeforePost;
end;

function TDataSetEvents.BeforeRefresh: IDataSetNotifyEvents;
begin
  if not Assigned(fBeforeRefresh) then fBeforeRefresh := TDataSetNotifyEvents.Create;
  Result := fBeforeRefresh;
end;

function TDataSetEvents.BeforeScroll: IDataSetNotifyEvents;
begin
  if not Assigned(fBeforeScroll) then fBeforeScroll := TDataSetNotifyEvents.Create;
  Result := fBeforeScroll;
end;

constructor TDataSetEvents.Create(const dataSet: TDataSet);
begin
  inherited Create;
  fDataSet := dataSet;
  fBeforeOpen := nil;
  fAfterOpen := nil;
  fBeforeClose := nil;
  fAfterClose := nil;
  fBeforeInsert := nil;
  fAfterInsert := nil;
  fBeforeEdit := nil;
  fAfterEdit := nil;
  fBeforePost := nil;
  fAfterPost := nil;
  fBeforeCancel := nil;
  fAfterCancel := nil;
  fBeforeDelete := nil;
  fAfterDelete := nil;
  fBeforeRefresh := nil;
  fAfterRefresh := nil;
  fBeforeScroll := nil;
  fAfterScroll := nil;
  fOnNewRecord := nil;
  fOnCalcFields := nil;
  fOnEditError := nil;
  fOnPostError := nil;
  fOnDeleteError := nil;
  Setup;
end;

destructor TDataSetEvents.Destroy;
begin
  inherited Destroy;
end;

procedure TDataSetEvents.DoAfterCancel(dataSet: TDataSet);
begin
  Self.AfterCancel.Execute(dataSet);
end;

procedure TDataSetEvents.DoAfterClose(dataSet: TDataSet);
begin
  Self.AfterClose.Execute(dataSet);
end;

procedure TDataSetEvents.DoAfterDelete(dataSet: TDataSet);
begin
  Self.AfterDelete.Execute(dataSet);
end;

procedure TDataSetEvents.DoAfterEdit(dataSet: TDataSet);
begin
  Self.AfterEdit.Execute(dataSet);
end;

procedure TDataSetEvents.DoAfterInsert(dataSet: TDataSet);
begin
  Self.AfterInsert.Execute(dataSet);
end;

procedure TDataSetEvents.DoAfterOpen(dataSet: TDataSet);
begin
  Self.AfterOpen.Execute(dataSet);
end;

procedure TDataSetEvents.DoAfterPost(dataSet: TDataSet);
begin
  Self.AfterPost.Execute(dataSet);
end;

procedure TDataSetEvents.DoAfterRefresh(dataSet: TDataSet);
begin
  Self.AfterRefresh.Execute(dataSet);
end;

procedure TDataSetEvents.DoAfterScroll(dataSet: TDataSet);
begin
  Self.AfterScroll.Execute(dataSet);
end;

procedure TDataSetEvents.DoBeforeCancel(dataSet: TDataSet);
begin
  Self.BeforeCancel.Execute(dataSet);
end;

procedure TDataSetEvents.DoBeforeClose(dataSet: TDataSet);
begin
  Self.BeforeClose.Execute(dataSet);
end;

procedure TDataSetEvents.DoBeforeDelete(dataSet: TDataSet);
begin
  Self.BeforeDelete.Execute(dataSet);
end;

procedure TDataSetEvents.DoBeforeEdit(dataSet: TDataSet);
begin
  Self.BeforeEdit.Execute(dataSet);
end;

procedure TDataSetEvents.DoBeforeInsert(dataSet: TDataSet);
begin
  Self.BeforeInsert.Execute(dataSet);
end;

procedure TDataSetEvents.DoBeforeOpen(dataSet: TDataSet);
begin
  Self.BeforeOpen.Execute(dataSet);
end;

procedure TDataSetEvents.DoBeforePost(dataSet: TDataSet);
begin
  Self.BeforePost.Execute(dataSet);
end;

procedure TDataSetEvents.DoBeforeRefresh(dataSet: TDataSet);
begin
  Self.BeforeRefresh.Execute(dataSet);
end;

procedure TDataSetEvents.DoBeforeScroll(dataSet: TDataSet);
begin
  Self.BeforeScroll.Execute(dataSet);
end;

procedure TDataSetEvents.DoOnCalcFields(dataSet: TDataSet);
begin
  Self.OnCalcFields.Execute(dataSet);
end;

procedure TDataSetEvents.DoOnDeleteError(dataSet: TDataSet; e: EDatabaseError; var action: TDataAction);
begin
  Self.OnDeleteError.Execute(dataSet, e, action);
end;

procedure TDataSetEvents.DoOnEditError(dataSet: TDataSet; e: EDatabaseError; var action: TDataAction);
begin
  Self.OnEditError.Execute(dataSet, e, action);
end;

procedure TDataSetEvents.DoOnNewRecord(dataSet: TDataSet);
begin
  Self.OnNewRecord.Execute(dataSet);
end;

procedure TDataSetEvents.DoOnPostError(dataSet: TDataSet; e: EDatabaseError; var action: TDataAction);
begin
  Self.OnPostError.Execute(dataSet, e, action);
end;

function TDataSetEvents.OnCalcFields: IDataSetNotifyEvents;
begin
  if not Assigned(fOnCalcFields) then fOnCalcFields := TDataSetNotifyEvents.Create;
  Result := fOnCalcFields;
end;

function TDataSetEvents.OnDeleteError: IDataSetErrorEvents;
begin
  if not Assigned(fOnDeleteError) then fOnDeleteError := TDataSetErrorEvents.Create;
  Result := fOnDeleteError;
end;

function TDataSetEvents.OnEditError: IDataSetErrorEvents;
begin
  if not Assigned(fOnEditError) then fOnEditError := TDataSetErrorEvents.Create;
  Result := fOnEditError;
end;

function TDataSetEvents.OnNewRecord: IDataSetNotifyEvents;
begin
  if not Assigned(fOnNewRecord) then fOnNewRecord := TDataSetNotifyEvents.Create;
  Result := fOnNewRecord;
end;

function TDataSetEvents.OnPostError: IDataSetErrorEvents;
begin
  if not Assigned(fOnPostError) then fOnPostError := TDataSetErrorEvents.Create;
  Result := fOnPostError;
end;

procedure TDataSetEvents.Setup;
begin
  if Assigned(fDataSet.BeforeOpen) then Self.BeforeOpen.Add('Default', fDataSet.BeforeOpen);
  if Assigned(fDataSet.AfterOpen) then Self.AfterOpen.Add('Default', fDataSet.AfterOpen);
  if Assigned(fDataSet.BeforeClose) then Self.BeforeClose.Add('Default', fDataSet.BeforeClose);
  if Assigned(fDataSet.AfterClose) then Self.AfterClose.Add('Default', fDataSet.AfterClose);
  if Assigned(fDataSet.BeforeInsert) then Self.BeforeInsert.Add('Default', fDataSet.BeforeInsert);
  if Assigned(fDataSet.AfterInsert) then Self.AfterInsert.Add('Default', fDataSet.AfterInsert);
  if Assigned(fDataSet.BeforeEdit) then Self.BeforeEdit.Add('Default', fDataSet.BeforeEdit);
  if Assigned(fDataSet.AfterEdit) then Self.AfterEdit.Add('Default', fDataSet.AfterEdit);
  if Assigned(fDataSet.BeforePost) then Self.BeforePost.Add('Default', fDataSet.BeforePost);
  if Assigned(fDataSet.AfterPost) then Self.AfterPost.Add('Default', fDataSet.AfterPost);
  if Assigned(fDataSet.BeforeCancel) then Self.BeforeCancel.Add('Default', fDataSet.BeforeCancel);
  if Assigned(fDataSet.AfterCancel) then Self.AfterCancel.Add('Default', fDataSet.AfterCancel);
  if Assigned(fDataSet.BeforeDelete) then Self.BeforeDelete.Add('Default', fDataSet.BeforeDelete);
  if Assigned(fDataSet.AfterDelete) then Self.AfterDelete.Add('Default', fDataSet.AfterDelete);
  if Assigned(fDataSet.BeforeRefresh) then Self.BeforeRefresh.Add('Default', fDataSet.BeforeRefresh);
  if Assigned(fDataSet.AfterRefresh) then Self.AfterRefresh.Add('Default', fDataSet.AfterRefresh);
  if Assigned(fDataSet.BeforeScroll) then Self.BeforeScroll.Add('Default', fDataSet.BeforeScroll);
  if Assigned(fDataSet.AfterScroll) then Self.AfterScroll.Add('Default', fDataSet.AfterScroll);
  if Assigned(fDataSet.OnNewRecord) then Self.OnNewRecord.Add('Default', fDataSet.OnNewRecord);
  if Assigned(fDataSet.OnCalcFields) then Self.OnCalcFields.Add('Default', fDataSet.OnCalcFields);
  if Assigned(fDataSet.OnEditError) then Self.OnEditError.Add('Default', fDataSet.OnEditError);
  if Assigned(fDataSet.OnPostError) then Self.OnPostError.Add('Default', fDataSet.OnPostError);
  if Assigned(fDataSet.OnDeleteError) then Self.OnDeleteError.Add('Default', fDataSet.OnDeleteError);

  fDataSet.BeforeOpen := DoBeforeOpen;
  fDataSet.AfterOpen := DoAfterOpen;
  fDataSet.BeforeClose := DoBeforeClose;
  fDataSet.AfterClose := DoAfterClose;
  fDataSet.BeforeInsert := DoBeforeInsert;
  fDataSet.AfterInsert := DoAfterInsert;
  fDataSet.BeforeEdit := DoBeforeEdit;
  fDataSet.AfterEdit := DoAfterEdit;
  fDataSet.BeforePost := DoBeforePost;
  fDataSet.AfterPost := DoAfterPost;
  fDataSet.BeforeCancel := DoBeforeCancel;
  fDataSet.AfterCancel := DoAfterCancel;
  fDataSet.BeforeDelete := DoBeforeDelete;
  fDataSet.AfterDelete := DoAfterDelete;
  fDataSet.BeforeRefresh := DoBeforeRefresh;
  fDataSet.AfterRefresh := DoAfterRefresh;
  fDataSet.BeforeScroll := DoBeforeScroll;
  fDataSet.AfterScroll := DoAfterScroll;
  fDataSet.OnNewRecord := DoOnNewRecord;
  fDataSet.OnCalcFields := DoOnCalcFields;
  fDataSet.OnEditError := DoOnEditError;
  fDataSet.OnPostError := DoOnPostError;
  fDataSet.OnDeleteError := DoOnDeleteError;
end;

end.
