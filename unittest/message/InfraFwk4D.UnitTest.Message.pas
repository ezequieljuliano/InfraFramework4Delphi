unit InfraFwk4D.UnitTest.Message;

interface

uses
  TestFramework,
  System.SysUtils,
  InfraFwk4D.Message,
  InfraFwk4D.Message.Impl,
  InfraFwk4D.UnitTest.Appender;

type

  TTestInfraFwkMessage = class(TTestCase)
  private
    { private declarations }
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  public
    { public declarations }
  published
    procedure TestDefaultMessage;
    procedure TestDeafultQuestion;
    procedure TestMessageContext;
  end;

implementation

{ TTestInfraFwkMessage }

procedure TTestInfraFwkMessage.SetUp;
begin
  inherited;

end;

procedure TTestInfraFwkMessage.TearDown;
begin
  inherited;

end;

procedure TTestInfraFwkMessage.TestDeafultQuestion;
var
  qst: IQuestion;
begin
  qst := TDefaultQuestion.Create('test question', reYes, []);
  CheckEqualsString('test question', qst.GetText);
  CheckTrue(qst.GetFocus = reYes);
  CheckTrue(qst.GetResponse = reYes);

  qst := TDefaultQuestion.Create('test question %d of %d', reYes, [1, 2]);
  CheckEqualsString('test question 1 of 2', qst.GetText);
  CheckTrue(qst.GetFocus = reYes);
  CheckTrue(qst.GetResponse = reYes);
end;

procedure TTestInfraFwkMessage.TestDefaultMessage;
var
  msg: IMessage;
begin
  msg := TDefaultMessage.Create('test info message', svInfo, []);
  CheckEqualsString('test info message', msg.GetText);
  CheckTrue(msg.GetSeverity = svInfo);

  msg := TDefaultMessage.Create('test warn message', svWarn);
  CheckEqualsString('test warn message', msg.GetText);
  CheckTrue(msg.GetSeverity = svWarn);

  msg := TDefaultMessage.Create('test error message', svError);
  CheckEqualsString('test error message', msg.GetText);
  CheckTrue(msg.GetSeverity = svError);

  msg := TDefaultMessage.Create('test fatal message', svFatal);
  CheckEqualsString('test fatal message', msg.GetText);
  CheckTrue(msg.GetSeverity = svFatal);

  msg := TDefaultMessage.Create('test message %d of %d', svInfo, [1, 2]);
  CheckEqualsString('test message 1 of 2', msg.GetText);
  CheckTrue(msg.GetSeverity = svInfo);
end;

procedure TTestInfraFwkMessage.TestMessageContext;
var
  msgCtx: IMessageContext;
begin
  msgCtx := TMessageContext.Create;
  msgCtx.RegisterAppender(TMessageAppender.Create);

  msgCtx.Display('test info message %d', svInfo, [1]);
  msgCtx.Display('test info message 2', svInfo);
  msgCtx.Display('test info message 3');

  CheckTrue(msgCtx.Ask('question %d?', reYes, [1]) = reYes);
  CheckTrue(msgCtx.Ask('question 2?', reYes) = reYes);
  CheckTrue(msgCtx.Ask('question 3?') = reYes);
end;

initialization

RegisterTest(TTestInfraFwkMessage.Suite);

end.
