unit InfraFwk4D.UnitTest.IBX.BC;

interface

uses
  InfraFwk4D.Driver,
  InfraFwk4D.UnitTest.IBX.DAO;

type

  TIBXBC = class(TBusinessAdapter<TIBXDAO>)

  end;

implementation

end.
