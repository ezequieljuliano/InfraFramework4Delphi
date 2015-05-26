unit Database.FireDAC;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Stan.ExprFuncs, Data.DB, FireDAC.Comp.Client,
  FireDAC.VCLUI.Wait, FireDAC.Comp.UI, InfraFwk4D.Driver.FireDAC, InfraFwk4D, System.SyncObjs;

type

  TDatabaseFireDAC = class(TDataModule)
    FDConnection: TFDConnection;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  strict private
    class var SingletonDatabaseFireDAC: TDatabaseFireDAC;

    class constructor Create;
    class destructor Destroy;
  strict private
    FConnectionAdapter: TFireDACConnectionAdapter;

    function GetConnectionAdapter(): TFireDACConnectionAdapter;
  public
    class function GetAdapter(): TFireDACConnectionAdapter; static;
  end;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}

{ TDatabaseFireDAC }

class constructor TDatabaseFireDAC.Create;
begin
  SingletonDatabaseFireDAC := nil;
end;

procedure TDatabaseFireDAC.DataModuleCreate(Sender: TObject);
begin
  FConnectionAdapter := TFireDACConnectionAdapter.Create;
  FDConnection.Connected := True;
  FConnectionAdapter.Build(TFireDACComponentAdapter.Create(FDConnection), True);
end;

procedure TDatabaseFireDAC.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(FConnectionAdapter);
  FDConnection.Connected := False;
end;

class destructor TDatabaseFireDAC.Destroy;
begin
  if (SingletonDatabaseFireDAC <> nil) then
    FreeAndNil(SingletonDatabaseFireDAC);
end;

class function TDatabaseFireDAC.GetAdapter: TFireDACConnectionAdapter;
begin
  if (SingletonDatabaseFireDAC = nil) then
  begin
    Critical.Section.Enter;
    try
      SingletonDatabaseFireDAC := TDatabaseFireDAC.Create(nil);
    finally
      Critical.Section.Leave;
    end;
  end;
  Result := SingletonDatabaseFireDAC.GetConnectionAdapter();
end;

function TDatabaseFireDAC.GetConnectionAdapter: TFireDACConnectionAdapter;
begin
  Result := FConnectionAdapter;
end;

end.
