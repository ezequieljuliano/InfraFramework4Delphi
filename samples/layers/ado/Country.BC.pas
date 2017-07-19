unit Country.BC;

interface

uses
  InfraFwk4D.Business,
  InfraFwk4D.DataSet.Iterator,
  FireDAC.Comp.Client,
  Country.DAO;

type

  TCountryBC = class(TBusinessController<TCountryDAO>)
  private
    fCount: Integer;
  protected
    { protected declarations }
  public
    procedure ProcessCounting;
    property Count: Integer read fCount;
  end;

implementation

{ TCountryBC }

procedure TCountryBC.ProcessCounting;
begin
  fCount := 0;
  Persistence.FindAll.ForEach(
    procedure(iterator: IDataSetIterator)
    begin
      fCount := fCount + 1;
    end
    );
  NotifyObservers;
end;

end.
