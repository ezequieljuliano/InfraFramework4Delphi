unit InfraFwk4D.UnitTest.IBX.BC;

interface

uses
  InfraFwk4D.Driver.IBX,
  InfraFwk4D.UnitTest.IBX.DAO;

type

  TIBXBC = class(TIBXBusinessAdapter<TIBXDAO>)

  end;

implementation

end.
