unit InfraFwk4D.UnitTest.Appender;

interface

uses
  InfraFwk4D.Message,
  Vcl.Forms,
  Winapi.Windows;

type

  TMessageAppender = class(TInterfacedObject, IMessageAppender)
  private
    const
    APP_NAME = 'MESSAGE APP';
  protected
    procedure Append(message: IMessage); overload;
    procedure Append(question: IQuestion); overload;
  public
    { public declarations }
  end;

implementation

{ TMessageAppender }

procedure TMessageAppender.Append(message: IMessage);
begin
  case message.GetSeverity of
    svInfo:
      Application.MessageBox(PChar(message.GetText), PChar(APP_NAME), MB_ICONINFORMATION + MB_OK);
    svWarn:
      Application.MessageBox(PChar(message.GetText), PChar(APP_NAME), MB_ICONWARNING + MB_OK);
    svError, svFatal:
      Application.MessageBox(PChar(message.GetText), PChar(APP_NAME), MB_ICONERROR + MB_OK);
  end;
end;

procedure TMessageAppender.Append(question: IQuestion);
var
  focus: Integer;
begin
  focus := MB_DEFBUTTON1;
  if (question.GetFocus = reNo) then
    focus := MB_DEFBUTTON2;
  case Application.MessageBox(PChar(question.GetText), PChar(APP_NAME), MB_ICONQUESTION + MB_YESNO + focus) of
    IDYES: question.SetResponse(reYes);
    IDNO: question.SetResponse(reNo);
  end;
end;

end.
