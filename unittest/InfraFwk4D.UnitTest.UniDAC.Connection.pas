unit InfraFwk4D.UnitTest.UniDAC.Connection;

interface

uses
  System.SysUtils, System.Classes, Data.DB, DBAccess, Uni;

type

  TUniDACDmConnection = class(TDataModule)
    UniConnection: TUniConnection;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{ %CLASSGROUP 'System.Classes.TPersistent' }

{$R *.dfm}

end.
