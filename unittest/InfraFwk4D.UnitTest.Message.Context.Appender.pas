unit InfraFwk4D.UnitTest.Message.Context.Appender;

interface

uses
  InfraFwk4D.Message.Context;

type

  TMessageAppender = class(TInterfacedObject, IMessageAppender)
  strict private
  const
    APP_NAME = 'APP TEST';
  public
    procedure Append(pMessage: IMessage); overload;
    procedure Append(pQuestion: IQuestion); overload;
  end;

implementation

uses
  Vcl.Forms,
  Winapi.Windows;

procedure MessageAppenderRegister();
begin
  Message.Context.RegisterAppender(
    function: IMessageAppender
    begin
      Result := TMessageAppender.Create;
    end
    );
end;

{ TMessageAppender }

procedure TMessageAppender.Append(pMessage: IMessage);
begin
  case pMessage.Severity of
    svInfo:
      Application.MessageBox(PChar(pMessage.Text), PChar(APP_NAME), MB_ICONINFORMATION + MB_OK);
    svWarn:
      Application.MessageBox(PChar(pMessage.Text), PChar(APP_NAME), MB_ICONWARNING + MB_OK);
    svError, svFatal:
      Application.MessageBox(PChar(pMessage.Text), PChar(APP_NAME), MB_ICONERROR + MB_OK);
  end;
end;

procedure TMessageAppender.Append(pQuestion: IQuestion);
var
  vFocus: Integer;
begin
  vFocus := MB_DEFBUTTON1;
  if (pQuestion.DefaultFocus = reNo) then
    vFocus := MB_DEFBUTTON2;
  case Application.MessageBox(PChar(pQuestion.Text), PChar(APP_NAME), MB_ICONQUESTION + MB_YESNO + vFocus) of
    IDYES: pQuestion.Response := reYes;
    IDNO: pQuestion.Response := reNo;
  end;
end;

initialization

MessageAppenderRegister();

end.
