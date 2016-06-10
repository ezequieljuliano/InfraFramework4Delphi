unit InfraFwk4D.Message.Impl;

interface

uses
  System.SysUtils,
  InfraFwk4D.Message;

type

  TDefaultMessage = class(TInterfacedObject, IMessage)
  private
    fText: string;
    fSeverity: TSeverity;
  protected
    function GetText: string;
    function GetSeverity: TSeverity;
  public
    constructor Create(const text: string; const severity: TSeverity; const args: array of const); overload;
    constructor Create(const text: string; const severity: TSeverity); overload;
  end;

  TDefaultQuestion = class(TInterfacedObject, IQuestion)
  private
    fText: string;
    fFocus: TResponse;
    fResponse: TResponse;
  protected
    function GetText: string;
    function GetFocus: TResponse;
    function GetResponse: TResponse;
    function SetResponse(const value: TResponse): IQuestion;
  public
    constructor Create(const text: string; const focus: TResponse; const args: array of const); overload;
    constructor Create(const text: string; const focus: TResponse); overload;
  end;

  TDefaultMessageAppender = class(TInterfacedObject, IMessageAppender)
  private
    const
    CLASS_NOT_FOUND = 'Message Appender not defined!';
  protected
    procedure Append(message: IMessage); overload;
    procedure Append(question: IQuestion); overload;
  public
    { public declarations }
  end;

  TMessageContext = class(TInterfacedObject, IMessageContext)
  private
    fAppender: IMessageAppender;
  protected
    function GetAppender: IMessageAppender;

    procedure RegisterAppender(appender: IMessageAppender);

    procedure Display(const text: string; const severity: TSeverity; const args: array of const); overload;
    procedure Display(const text: string; const severity: TSeverity); overload;
    procedure Display(const text: string); overload;

    function Ask(const text: string; const focus: TResponse; const args: array of const): TResponse; overload;
    function Ask(const text: string; const focus: TResponse): TResponse; overload;
    function Ask(const text: string): TResponse; overload;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TDefaultMessage }

constructor TDefaultMessage.Create(const text: string; const severity: TSeverity; const args: array of const);
begin
  inherited Create;
  fText := Format(text, args);
  fSeverity := severity;
end;

constructor TDefaultMessage.Create(const text: string; const severity: TSeverity);
begin
  Create(text, severity, []);
end;

function TDefaultMessage.GetSeverity: TSeverity;
begin
  Result := fSeverity;
end;

function TDefaultMessage.GetText: string;
begin
  Result := fText;
end;

{ TDefaultQuestion }

constructor TDefaultQuestion.Create(const text: string; const focus: TResponse; const args: array of const);
begin
  inherited Create;
  fText := Format(text, args);
  fFocus := focus;
  fResponse := focus;
end;

constructor TDefaultQuestion.Create(const text: string; const focus: TResponse);
begin
  Create(text, focus, []);
end;

function TDefaultQuestion.GetFocus: TResponse;
begin
  Result := fFocus;
end;

function TDefaultQuestion.GetResponse: TResponse;
begin
  Result := fResponse;
end;

function TDefaultQuestion.GetText: string;
begin
  Result := fText;
end;

function TDefaultQuestion.SetResponse(const value: TResponse): IQuestion;
begin
  fResponse := value;
  Result := Self;
end;

{ TDefaultMessageAppender }

procedure TDefaultMessageAppender.Append(message: IMessage);
begin
  raise EMessageAppenderException.Create(CLASS_NOT_FOUND);
end;

procedure TDefaultMessageAppender.Append(question: IQuestion);
begin
  raise EMessageAppenderException.Create(CLASS_NOT_FOUND);
end;

{ TMessageContext }

function TMessageContext.Ask(const text: string): TResponse;
begin
  Result := Ask(text, reYes, []);
end;

constructor TMessageContext.Create;
begin
  inherited Create;
  fAppender := nil;
end;

function TMessageContext.Ask(const text: string; const focus: TResponse): TResponse;
begin
  Result := Ask(text, focus, []);
end;

function TMessageContext.Ask(const text: string; const focus: TResponse; const args: array of const): TResponse;
var
  question: IQuestion;
begin
  question := TDefaultQuestion.Create(text, focus, args);
  GetAppender.Append(question);
  Result := question.GetResponse;
end;

destructor TMessageContext.Destroy;
begin
  inherited Destroy;
end;

procedure TMessageContext.Display(const text: string);
begin
  Display(text, svInfo, []);
end;

function TMessageContext.GetAppender: IMessageAppender;
begin
  if not Assigned(fAppender) then
    fAppender := TDefaultMessageAppender.Create;
  Result := fAppender;
end;

procedure TMessageContext.Display(const text: string; const severity: TSeverity);
begin
  Display(text, severity, []);
end;

procedure TMessageContext.Display(const text: string; const severity: TSeverity; const args: array of const);
begin
  GetAppender.Append(TDefaultMessage.Create(text, severity, args));
end;

procedure TMessageContext.RegisterAppender(appender: IMessageAppender);
begin
  fAppender := appender;
end;

end.
