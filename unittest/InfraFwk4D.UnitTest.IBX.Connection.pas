unit InfraFwk4D.UnitTest.IBX.Connection;

interface

uses
  System.SysUtils,
  System.Classes,
  IBX.IBDatabase,
  Data.DB;

type

  TIBXDmConnection = class(TDataModule)
    IBDatabase: TIBDatabase;
    IBTransaction: TIBTransaction;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{ %CLASSGROUP 'System.Classes.TPersistent' }

{$R *.dfm}

end.
