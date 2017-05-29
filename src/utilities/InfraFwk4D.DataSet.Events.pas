unit InfraFwk4D.DataSet.Events;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB;

type

  TNotifyEvent = reference to procedure(dataSet: TDataSet);
  TErrorEvent = reference to procedure(dataSet: TDataSet; e: EDatabaseError; var action: TDataAction);

  TNotifyEvents = class(TDictionary<string, TNotifyEvent>)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  TErrorEvents = class(TDictionary<string, TErrorEvent>)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  IDataSetEvents = interface
    ['{8FAB5F98-4A30-42A9-B4CA-A45E382F9EED}']
    function BeforeOpen: TNotifyEvents;
    function AfterOpen: TNotifyEvents;
    function BeforeClose: TNotifyEvents;
    function AfterClose: TNotifyEvents;
    function BeforeInsert: TNotifyEvents;
    function AfterInsert: TNotifyEvents;
    function BeforeEdit: TNotifyEvents;
    function AfterEdit: TNotifyEvents;
    function BeforePost: TNotifyEvents;
    function AfterPost: TNotifyEvents;
    function BeforeCancel: TNotifyEvents;
    function AfterCancel: TNotifyEvents;
    function BeforeDelete: TNotifyEvents;
    function AfterDelete: TNotifyEvents;
    function BeforeRefresh: TNotifyEvents;
    function AfterRefresh: TNotifyEvents;
    function BeforeScroll: TNotifyEvents;
    function AfterScroll: TNotifyEvents;
    function OnNewRecord: TNotifyEvents;
    function OnCalcFields: TNotifyEvents;
    function OnEditError: TErrorEvents;
    function OnPostError: TErrorEvents;
    function OnDeleteError: TErrorEvents;
  end;

  TDataSetEvents = class(TInterfacedObject, IDataSetEvents)
  private
    fDataSet: TDataSet;
    fBeforeOpen: TNotifyEvents;
    fAfterOpen: TNotifyEvents;
    fBeforeClose: TNotifyEvents;
    fAfterClose: TNotifyEvents;
    fBeforeInsert: TNotifyEvents;
    fAfterInsert: TNotifyEvents;
    fBeforeEdit: TNotifyEvents;
    fAfterEdit: TNotifyEvents;
    fBeforePost: TNotifyEvents;
    fAfterPost: TNotifyEvents;
    fBeforeCancel: TNotifyEvents;
    fAfterCancel: TNotifyEvents;
    fBeforeDelete: TNotifyEvents;
    fAfterDelete: TNotifyEvents;
    fBeforeRefresh: TNotifyEvents;
    fAfterRefresh: TNotifyEvents;
    fBeforeScroll: TNotifyEvents;
    fAfterScroll: TNotifyEvents;
    fOnNewRecord: TNotifyEvents;
    fOnCalcFields: TNotifyEvents;
    fOnEditError: TErrorEvents;
    fOnPostError: TErrorEvents;
    fOnDeleteError: TErrorEvents;
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
    function BeforeOpen: TNotifyEvents;
    function AfterOpen: TNotifyEvents;
    function BeforeClose: TNotifyEvents;
    function AfterClose: TNotifyEvents;
    function BeforeInsert: TNotifyEvents;
    function AfterInsert: TNotifyEvents;
    function BeforeEdit: TNotifyEvents;
    function AfterEdit: TNotifyEvents;
    function BeforePost: TNotifyEvents;
    function AfterPost: TNotifyEvents;
    function BeforeCancel: TNotifyEvents;
    function AfterCancel: TNotifyEvents;
    function BeforeDelete: TNotifyEvents;
    function AfterDelete: TNotifyEvents;
    function BeforeRefresh: TNotifyEvents;
    function AfterRefresh: TNotifyEvents;
    function BeforeScroll: TNotifyEvents;
    function AfterScroll: TNotifyEvents;
    function OnNewRecord: TNotifyEvents;
    function OnCalcFields: TNotifyEvents;
    function OnEditError: TErrorEvents;
    function OnPostError: TErrorEvents;
    function OnDeleteError: TErrorEvents;
  public
    constructor Create(const dataSet: TDataSet);
    destructor Destroy; override;
  end;

implementation

{ TDataSetEvents }

function TDataSetEvents.AfterCancel: TNotifyEvents;
begin
  if not Assigned(fAfterCancel) then fAfterCancel := TNotifyEvents.Create;
  Result := fAfterCancel;
end;

function TDataSetEvents.AfterClose: TNotifyEvents;
begin
  if not Assigned(fAfterClose) then fAfterClose := TNotifyEvents.Create;
  Result := fAfterClose;
end;

function TDataSetEvents.AfterDelete: TNotifyEvents;
begin
  if not Assigned(fAfterDelete) then fAfterDelete := TNotifyEvents.Create;
  Result := fAfterDelete;
end;

function TDataSetEvents.AfterEdit: TNotifyEvents;
begin
  if not Assigned(fAfterEdit) then fAfterEdit := TNotifyEvents.Create;
  Result := fAfterEdit;
end;

function TDataSetEvents.AfterInsert: TNotifyEvents;
begin
  if not Assigned(fAfterInsert) then fAfterInsert := TNotifyEvents.Create;
  Result := fAfterInsert;
end;

function TDataSetEvents.AfterOpen: TNotifyEvents;
begin
  if not Assigned(fAfterOpen) then fAfterOpen := TNotifyEvents.Create;
  Result := fAfterOpen;
end;

function TDataSetEvents.AfterPost: TNotifyEvents;
begin
  if not Assigned(fAfterPost) then fAfterPost := TNotifyEvents.Create;
  Result := fAfterPost;
end;

function TDataSetEvents.AfterRefresh: TNotifyEvents;
begin
  if not Assigned(fAfterRefresh) then fAfterRefresh := TNotifyEvents.Create;
  Result := fAfterRefresh;
end;

function TDataSetEvents.AfterScroll: TNotifyEvents;
begin
  if not Assigned(fAfterScroll) then fAfterScroll := TNotifyEvents.Create;
  Result := fAfterScroll;
end;

function TDataSetEvents.BeforeCancel: TNotifyEvents;
begin
  if not Assigned(fBeforeCancel) then fBeforeCancel := TNotifyEvents.Create;
  Result := fBeforeCancel;
end;

function TDataSetEvents.BeforeClose: TNotifyEvents;
begin
  if not Assigned(fBeforeClose) then fBeforeClose := TNotifyEvents.Create;
  Result := fBeforeClose;
end;

function TDataSetEvents.BeforeDelete: TNotifyEvents;
begin
  if not Assigned(fBeforeDelete) then fBeforeDelete := TNotifyEvents.Create;
  Result := fBeforeDelete;
end;

function TDataSetEvents.BeforeEdit: TNotifyEvents;
begin
  if not Assigned(fBeforeEdit) then fBeforeEdit := TNotifyEvents.Create;
  Result := fBeforeEdit;
end;

function TDataSetEvents.BeforeInsert: TNotifyEvents;
begin
  if not Assigned(fBeforeInsert) then fBeforeInsert := TNotifyEvents.Create;
  Result := fBeforeInsert;
end;

function TDataSetEvents.BeforeOpen: TNotifyEvents;
begin
  if not Assigned(fBeforeOpen) then fBeforeOpen := TNotifyEvents.Create;
  Result := fBeforeOpen;
end;

function TDataSetEvents.BeforePost: TNotifyEvents;
begin
  if not Assigned(fBeforePost) then fBeforePost := TNotifyEvents.Create;
  Result := fBeforePost;
end;

function TDataSetEvents.BeforeRefresh: TNotifyEvents;
begin
  if not Assigned(fBeforeRefresh) then fBeforeRefresh := TNotifyEvents.Create;
  Result := fBeforeRefresh;
end;

function TDataSetEvents.BeforeScroll: TNotifyEvents;
begin
  if not Assigned(fBeforeScroll) then fBeforeScroll := TNotifyEvents.Create;
  Result := fBeforeScroll;
end;

constructor TDataSetEvents.Create(const dataSet: TDataSet);
begin
  inherited Create;
  fDataSet := dataSet;
  // Events
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
  // Configuration
  Setup;
end;

destructor TDataSetEvents.Destroy;
begin
  if Assigned(fBeforeOpen) then fBeforeOpen.Free;
  if Assigned(fAfterOpen) then fAfterOpen.Free;
  if Assigned(fBeforeClose) then fBeforeClose.Free;
  if Assigned(fAfterClose) then fAfterClose.Free;
  if Assigned(fBeforeInsert) then fBeforeInsert.Free;
  if Assigned(fAfterInsert) then fAfterInsert.Free;
  if Assigned(fBeforeEdit) then fBeforeEdit.Free;
  if Assigned(fAfterEdit) then fAfterEdit.Free;
  if Assigned(fBeforePost) then fBeforePost.Free;
  if Assigned(fAfterPost) then fAfterPost.Free;
  if Assigned(fBeforeCancel) then fBeforeCancel.Free;
  if Assigned(fAfterCancel) then fAfterCancel.Free;
  if Assigned(fBeforeDelete) then fBeforeDelete.Free;
  if Assigned(fAfterDelete) then fAfterDelete.Free;
  if Assigned(fBeforeRefresh) then fBeforeRefresh.Free;
  if Assigned(fAfterRefresh) then fAfterRefresh.Free;
  if Assigned(fBeforeScroll) then fBeforeScroll.Free;
  if Assigned(fAfterScroll) then fAfterScroll.Free;
  if Assigned(fOnNewRecord) then fOnNewRecord.Free;
  if Assigned(fOnCalcFields) then fOnCalcFields.Free;
  if Assigned(fOnEditError) then fOnEditError.Free;
  if Assigned(fOnPostError) then fOnPostError.Free;
  if Assigned(fOnDeleteError) then fOnDeleteError.Free;
  inherited Destroy;
end;

procedure TDataSetEvents.DoAfterCancel(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.AfterCancel do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoAfterClose(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.AfterClose do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoAfterDelete(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.AfterDelete do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoAfterEdit(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.AfterEdit do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoAfterInsert(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.AfterInsert do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoAfterOpen(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.AfterOpen do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoAfterPost(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.AfterPost do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoAfterRefresh(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.AfterRefresh do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoAfterScroll(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.AfterScroll do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoBeforeCancel(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.BeforeCancel do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoBeforeClose(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.BeforeClose do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoBeforeDelete(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.BeforeDelete do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoBeforeEdit(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.BeforeEdit do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoBeforeInsert(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.BeforeInsert do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoBeforeOpen(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.BeforeOpen do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoBeforePost(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.BeforePost do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoBeforeRefresh(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.BeforeRefresh do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoBeforeScroll(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.BeforeScroll do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoOnCalcFields(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.OnCalcFields do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoOnDeleteError(dataSet: TDataSet; e: EDatabaseError; var action: TDataAction);
var
  event: TPair<string, TErrorEvent>;
begin
  for event in Self.OnDeleteError do
    event.Value(dataSet, e, action);
end;

procedure TDataSetEvents.DoOnEditError(dataSet: TDataSet; e: EDatabaseError; var action: TDataAction);
var
  event: TPair<string, TErrorEvent>;
begin
  for event in Self.OnEditError do
    event.Value(dataSet, e, action);
end;

procedure TDataSetEvents.DoOnNewRecord(dataSet: TDataSet);
var
  event: TPair<string, TNotifyEvent>;
begin
  for event in Self.OnNewRecord do
    event.Value(dataSet);
end;

procedure TDataSetEvents.DoOnPostError(dataSet: TDataSet; e: EDatabaseError; var action: TDataAction);
var
  event: TPair<string, TErrorEvent>;
begin
  for event in Self.OnPostError do
    event.Value(dataSet, e, action);
end;

function TDataSetEvents.OnCalcFields: TNotifyEvents;
begin
  if not Assigned(fOnCalcFields) then fOnCalcFields := TNotifyEvents.Create;
  Result := fOnCalcFields;
end;

function TDataSetEvents.OnDeleteError: TErrorEvents;
begin
  if not Assigned(fOnDeleteError) then fOnDeleteError := TErrorEvents.Create;
  Result := fOnDeleteError;
end;

function TDataSetEvents.OnEditError: TErrorEvents;
begin
  if not Assigned(fOnEditError) then fOnEditError := TErrorEvents.Create;
  Result := fOnEditError;
end;

function TDataSetEvents.OnNewRecord: TNotifyEvents;
begin
  if not Assigned(fOnNewRecord) then fOnNewRecord := TNotifyEvents.Create;
  Result := fOnNewRecord;
end;

function TDataSetEvents.OnPostError: TErrorEvents;
begin
  if not Assigned(fOnPostError) then fOnPostError := TErrorEvents.Create;
  Result := fOnPostError;
end;

procedure TDataSetEvents.Setup;
begin
  // Adds standard methods of DataSet
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
  // Reconfigures the DataSet
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
