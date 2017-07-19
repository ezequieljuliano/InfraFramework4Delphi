unit DAL.Connection;

interface

uses
  System.SysUtils, System.Classes,
  InfraFwk4D.Persistence, InfraFwk4D.Persistence.Adapter.ADO,
  Data.Win.ADODB, Data.DB;

type

  TDALConnection = class(TDataModule)
    ADOConnection: TADOConnection;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    fConnection: IDBConnection<TADOConnection>;
    fSession: IDBSession<TADOConnection>;
  public
    function GetSession: IDBSession<TADOConnection>;
  end;

var
  DALConnection: TDALConnection;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

procedure TDALConnection.DataModuleCreate(Sender: TObject);
begin
  ADOConnection.Connected := True;
  fConnection := TADOConnectionAdapter.Create(ADOConnection);
  fSession := TADOSessionAdapter.Create(fConnection);
end;

procedure TDALConnection.DataModuleDestroy(Sender: TObject);
begin
  ADOConnection.Connected := False;
end;

function TDALConnection.GetSession: IDBSession<TADOConnection>;
begin
  Result := fSession;
end;

end.
