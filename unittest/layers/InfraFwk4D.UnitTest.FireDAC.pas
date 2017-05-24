unit InfraFwk4D.UnitTest.FireDAC;

interface

uses
  TestFramework,
  System.SysUtils,
  FireDAC.DApt,
  FireDAC.Comp.Client,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.Phys.Intf,
  InfraFwk4D.Persistence,
  InfraFwk4D.Persistence.Adapter.FireDAC,
  InfraFwk4D.Persistence.Template.FireDAC,
  InfraFwk4D.Business;

type

  TTestDAO = class(TPersistenceTemplateFireDAC)
  private
    fMaster: TFDQuery;
    fDetail: TFDQuery;
  protected
    { protected declarations }
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    property Master: TFDQuery read fMaster;
    property Detail: TFDQuery read fDetail;
  end;

  TTestBC = class(TBusinessController<TTestDAO>)
  private
    FData: string;
    procedure SetData(const Value: string);
  protected
    { protected declarations }
  public
    property Data: string read FData write SetData;
  end;

  TTestInfraFwkFireDAC = class(TTestCase)
  private
    fDatabase: TFDConnection;
    fConnection: IDBConnection<TFDConnection>;
    fSession: IDBSession<TFDConnection>;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestConnection;
    procedure TestSession;
    procedure TestPersistence;
    procedure TestBusiness;
    procedure TestView;
  end;

implementation

{ TTestInfraFwkFireDAC }

procedure TTestInfraFwkFireDAC.SetUp;
begin
  inherited;
  fDatabase := TFDConnection.Create(nil);
  fConnection := TFireDACConnectionAdapter.Create(fDatabase);
  fSession := TFireDACSessionAdapter.Create(fConnection);
end;

procedure TTestInfraFwkFireDAC.TearDown;
begin
  inherited;
  fDatabase.Free;
end;

procedure TTestInfraFwkFireDAC.TestBusiness;
var
  bc: TTestBC;
  dao: TTestDAO;
begin
  bc := TTestBC.Create(TTestDAO.Create(fSession));
  CheckTrue(bc.OwnsPersistence);
  bc.Free;

  bc := TTestBC.Create(TTestDAO.Create(fSession), True);
  CheckTrue(bc.OwnsPersistence);
  bc.Free;

  dao := TTestDAO.Create(fSession);
  bc := TTestBC.Create(dao, False);
  CheckFalse(bc.OwnsPersistence);
  bc.Free;
  dao.Free;

  bc := TTestBC.Create(TTestDAO.Create(fSession));
  CheckTrue(bc.OwnsPersistence);
  CheckTrue(bc.Persistence <> nil);
  bc.Free;
end;

procedure TTestInfraFwkFireDAC.TestConnection;
begin
  CheckTrue(fConnection <> nil);
  CheckTrue(fConnection.GetComponent <> nil);
end;

procedure TTestInfraFwkFireDAC.TestPersistence;
var
  dao: TTestDAO;
begin
  dao := TTestDAO.Create(fSession);
  CheckTrue(dao <> nil);
  dao.Free;
end;

procedure TTestInfraFwkFireDAC.TestSession;
begin
  CheckTrue(fSession <> nil);
  CheckTrue(fSession.GetConnection <> nil);
  CheckTrue(fSession.GetConnection.GetComponent <> nil);
  CheckTrue(fSession.NewStatement <> nil);
end;

procedure TTestInfraFwkFireDAC.TestView;
var
  bc: TTestBC;
  tmpData: string;
begin
  bc := TTestBC.Create(TTestDAO.Create(fSession));
  bc.RegisterObserver('OnDataChange',
    procedure(sender: TObject)
    begin
      tmpData := (sender as TTestBC).Data;
    end
    );

  bc.Data := 'Ezequiel';
  CheckEquals('Ezequiel', tmpData);

  bc.Data := 'Juliano';
  CheckEquals('Juliano', tmpData);

  bc.Free;
end;

{ TTestDAO }

procedure TTestDAO.AfterConstruction;
begin
  inherited AfterConstruction;
  fMaster := TFDQuery.Create(nil);
  fDetail := TFDQuery.Create(nil);
end;

procedure TTestDAO.BeforeDestruction;
begin
  fMaster.Free;
  fDetail.Free;
  inherited BeforeDestruction;
end;

{ TTestBC }

procedure TTestBC.SetData(const Value: string);
begin
  FData := Value;
  NotifyObservers;
end;

initialization

RegisterTest(TTestInfraFwkFireDAC.Suite);

end.
