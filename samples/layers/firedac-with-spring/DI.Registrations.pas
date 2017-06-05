unit DI.Registrations;

interface

uses
  Spring.Container;

procedure RegisterTypes(const container: TContainer);

implementation

uses
  Vcl.Forms,
  FireDAC.Comp.Client,
  InfraFwk4D.Persistence,
  InfraFwk4D.Persistence.Adapter.FireDAC,
  DAL.Connection,
  // DAOs - Data Access Objects
  Country.DAO,
  Province.DAO,
  // BCs - Business Controllers
  Country.BC,
  Province.BC,
  // Views
  Main.View,
  Country.View,
  Province.View;

procedure RegisterTypes(const container: TContainer);
begin
  container.RegisterType<TDALConnection>.Implements < IDBConnection < TFDConnection >>.AsSingleton;
  container.RegisterType<IDBSession, TFireDACSessionAdapter>.AsSingleton;

  // DAOs - Data Access Objects
  container.RegisterType<TCountryDAO>;
  container.RegisterType<TProvinceDAO>;

  // BCs - Business Controllers
  container.RegisterType<TCountryBC>;
  container.RegisterType<TProvinceBC>;

  // Views
  container.RegisterType<TMainView>.DelegateTo(
    function: TMainView
    begin
      Application.CreateForm(TMainView, Result);
    end)
    .AsSingleton;

  container.RegisterType<TCountryView>.DelegateTo(
    function: TCountryView
    begin
      Application.CreateForm(TCountryView, Result);
    end);

  container.RegisterType<TProvinceView>.DelegateTo(
    function: TProvinceView
    begin
      Application.CreateForm(TProvinceView, Result);
    end);

  container.Build;
end;

end.
