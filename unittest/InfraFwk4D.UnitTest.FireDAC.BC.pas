unit InfraFwk4D.UnitTest.FireDAC.BC;

interface

uses
  InfraFwk4D.Driver.FireDAC, InfraFwk4D.UnitTest.FireDAC.DAO;

type

  TFireDACBC = class(TFireDACBusinessAdapter<TFireDACDAO>)

  end;

implementation

end.
