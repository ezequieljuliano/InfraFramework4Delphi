unit InfraDB4D.UnitTest.UniDAC.DataModule;

interface

uses
  System.SysUtils, System.Classes;

type
  TUniDACDataModule = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  UniDACDataModule: TUniDACDataModule;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

end.
