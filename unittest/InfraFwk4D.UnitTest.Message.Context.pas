unit InfraFwk4D.UnitTest.Message.Context;

interface

uses
  TestFramework,
  System.Classes,
  System.SysUtils,
  InfraFwk4D.Message.Context;

type

  TTestInfraFwkMessageContext = class(TTestCase)
  private

  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestMessages();
    procedure TestQuestions();
  end;

implementation

{ TTestInfraFwkMessageContext }

procedure TTestInfraFwkMessageContext.SetUp;
begin
  inherited;

end;

procedure TTestInfraFwkMessageContext.TearDown;
begin
  inherited;

end;

procedure TTestInfraFwkMessageContext.TestMessages;
begin
  Message.Context.Show('Info Message', svInfo);
  Message.Context.Show('Warn Message', svWarn);
  Message.Context.Show('Error Message', svError);
  Message.Context.Show('Fatal Message', svFatal);
end;

procedure TTestInfraFwkMessageContext.TestQuestions;
var
  vResponse: TResponse;
begin
  vResponse := Message.Context.Question('Question?', reYes);
  CheckTrue(vResponse = reYes);

  vResponse := Message.Context.Question('Question?', reNo);
  CheckTrue(vResponse = reNo);
end;

initialization

RegisterTest(TTestInfraFwkMessageContext.Suite);

end.
