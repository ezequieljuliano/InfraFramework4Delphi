unit InfraFwk4D.UnitTest.Observer;

interface

uses
  TestFramework,
  System.SysUtils,
  InfraFwk4D.Observer;

type

  TTestInfraFwkObserver = class(TTestCase)
  private
    { private declarations }
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  public
    { public declarations }
  published
    procedure TestObserver;
  end;

  TDataProcessor = class
  private
    FSubject: ISubject;
    FData: string;
    procedure SetData(const Value: string);
  protected
    { protected declarations }
  public
    constructor Create;
    destructor Destroy; override;

    function GetSubject: ISubject;

    property Data: string read FData write SetData;
  end;

implementation

{ TTestInfraFwkObserver }

procedure TTestInfraFwkObserver.SetUp;
begin
  inherited;
end;

procedure TTestInfraFwkObserver.TearDown;
begin
  inherited;
end;

procedure TTestInfraFwkObserver.TestObserver;
var
  dataProcessor: TDataProcessor;
  tmpData: string;
begin
  dataProcessor := TDataProcessor.Create;
  try
    dataProcessor.GetSubject.RegisterObserver('OnDataChange', TObserver.Create(
      procedure(sender: TObject)
      begin
        tmpData := (sender as TDataProcessor).Data;
      end
      ));

    CheckTrue(dataProcessor.GetSubject.GetObserver('OnDataChange') <> nil);

    dataProcessor.Data := 'Ezequiel';
    CheckEquals('Ezequiel', tmpData);

    dataProcessor.Data := 'Juliano';
    CheckEquals('Juliano', tmpData);
  finally
    dataProcessor.Free;
  end;
end;

{ TDataProcessor }

constructor TDataProcessor.Create;
begin
  inherited Create;
  FSubject := TSubject.Create(Self);
end;

destructor TDataProcessor.Destroy;
begin
  inherited Destroy;
end;

function TDataProcessor.GetSubject: ISubject;
begin
  Result := FSubject;
end;

procedure TDataProcessor.SetData(const Value: string);
begin
  FData := Value;
  FSubject.NotifyObservers;
end;

initialization

RegisterTest(TTestInfraFwkObserver.Suite);

end.
