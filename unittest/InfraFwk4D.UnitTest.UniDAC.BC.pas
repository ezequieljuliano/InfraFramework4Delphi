unit InfraFwk4D.UnitTest.UniDAC.BC;

interface

uses
  InfraFwk4D.Driver.UniDAC, InfraFwk4D.UnitTest.UniDAC.DAO;

type

  TUniDACBC = class(TUniDACBusinessAdapter<TUniDACDAO>)

  end;

implementation

end.
