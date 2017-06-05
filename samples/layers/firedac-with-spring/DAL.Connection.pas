unit DAL.Connection;

interface

uses
  // System
  System.SysUtils, System.Classes, Data.DB,
  // FireDAC
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.Comp.Client,
  // InfraFwk4D
  InfraFwk4D.Persistence;

type

  EDALConnectionException = class(Exception)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  TDALConnection = class(TDataModule, IDBConnection<TFDConnection>)
    FDConnection: TFDConnection;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { private declarations }
  protected
    function GetOwner: IDB; reintroduce;
    function GetComponent: TFDConnection;
  public
    { public declarations }
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

procedure TDALConnection.DataModuleCreate(Sender: TObject);
begin
  FDConnection.Connected := True;
end;

procedure TDALConnection.DataModuleDestroy(Sender: TObject);
begin
  FDConnection.Connected := False;
end;

function TDALConnection.GetComponent: TFDConnection;
begin
  if not Assigned(FDConnection) then
    raise EDALConnectionException.CreateFmt('Database Connection Component Not Found in %s!', [Self.ClassName]);
  Result := FDConnection;
end;

function TDALConnection.GetOwner: IDB;
begin
  Result := nil;
end;

end.
