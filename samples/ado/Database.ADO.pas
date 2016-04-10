unit Database.ADO;

interface

uses
  SysUtils, Classes, ADODB,
  InfraFwk4D.Driver.ADO, InfraFwk4D, SyncObjs, DB;

type

  TDatabaseADO = class(TDataModule)
    FADOConnection: TADOConnection;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  strict private
    class var SingletonDatabaseFireDAC: TDatabaseADO;

    class constructor Create;
    class destructor Destroy;
  strict private
    FConnectionAdapter: TADOConnectionAdapter;

    function GetConnectionAdapter(): TADOConnectionAdapter;
  public
    class function GetAdapter(): TADOConnectionAdapter; static;
  end;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}
{ TDatabaseADO }

class constructor TDatabaseADO.Create;
begin
  SingletonDatabaseFireDAC := nil;
end;

procedure TDatabaseADO.DataModuleCreate(Sender: TObject);
begin
  FConnectionAdapter := TADOConnectionAdapter.Create;
  FADOConnection.Connected := True;
  FConnectionAdapter.Build(TADOComponentAdapter.Create(FADOConnection), True);
end;

procedure TDatabaseADO.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(FConnectionAdapter);
  FADOConnection.Connected := False;
end;

class destructor TDatabaseADO.Destroy;
begin
  if (SingletonDatabaseFireDAC <> nil) then
    FreeAndNil(SingletonDatabaseFireDAC);
end;

class function TDatabaseADO.GetAdapter: TADOConnectionAdapter;
begin
  if (SingletonDatabaseFireDAC = nil) then
  begin
    Critical.Section.Enter;
    try
      SingletonDatabaseFireDAC := TDatabaseADO.Create(nil);
    finally
      Critical.Section.Leave;
    end;
  end;
  Result := SingletonDatabaseFireDAC.GetConnectionAdapter();
end;

function TDatabaseADO.GetConnectionAdapter: TADOConnectionAdapter;
begin
  Result := FConnectionAdapter;
end;

end.
