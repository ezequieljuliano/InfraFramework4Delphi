unit InfraFwk4D.UnitTest.FireDAC.DAO;

interface

uses
  System.SysUtils, System.Classes, InfraFwk4D.Driver.FireDAC.Persistence,
  InfraFwk4D.UnitTest.FireDAC.Connection, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  InfraFwk4D.Driver.FireDAC;

type

  TFireDACDAO = class(TFireDACPersistenceAdapter)
    Master: TFDQuery;
    Detail: TFDQuery;
  private
    { Private declarations }
  strict protected
    function GetConnection(): TFireDACConnectionAdapter; override;
    procedure ConfigureDataSetsConnection(); override;
  public
    { Public declarations }
  end;

implementation

{ %CLASSGROUP 'System.Classes.TPersistent' }

{$R *.dfm}

{ TFireDACDAO }

procedure TFireDACDAO.ConfigureDataSetsConnection;
begin
  inherited;
  Master.Connection := Connection.Component.Connection;
  Detail.Connection := Connection.Component.Connection;
end;

function TFireDACDAO.GetConnection: TFireDACConnectionAdapter;
begin
  Result := FireDACAdapter.SingletonConnection.Instance;
end;

end.
