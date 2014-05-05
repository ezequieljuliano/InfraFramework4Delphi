unit Country.Controller;

interface

uses
  InfraDB4D.Drivers.FireDAC, System.SysUtils;

type

  TCountryController = class(TFireDACControllerAdapter)
  public
    procedure ValidateFields();
  end;

implementation

{ TCountryController }

procedure TCountryController.ValidateFields;
begin
  if (GetDataSet.FieldByName('CTY_CODE').AsInteger = 0) then
    raise Exception.Create('Country Code is null!');
end;

end.
