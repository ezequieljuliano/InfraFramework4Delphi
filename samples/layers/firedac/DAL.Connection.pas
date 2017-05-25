unit DAL.Connection;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI, Data.DB, FireDAC.Comp.Client, InfraFwk4D.Persistence, InfraFwk4D.Persistence.Adapter.FireDAC;

type

  TDALConnection = class(TDataModule)
    FDConnection: TFDConnection;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    fConnection: IDBConnection<TFDConnection>;
    fSession: IDBSession;
  public
    function GetSession: IDBSession;
  end;

var
  DALConnection: TDALConnection;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

procedure TDALConnection.DataModuleCreate(Sender: TObject);
begin
  FDConnection.Connected := True;
  fConnection := TFireDACConnectionAdapter.Create(FDConnection);
  fSession := TFireDACSessionAdapter.Create(fConnection);
end;

procedure TDALConnection.DataModuleDestroy(Sender: TObject);
begin
  FDConnection.Connected := False;
end;

function TDALConnection.GetSession: IDBSession;
begin
  Result := fSession;
end;

end.
