unit InfraFwk4D.Message.Context;

interface

uses
  SysUtils;

type

  EMessageContextException = class(Exception);
  EMessageAppenderException = class(EMessageContextException);

  TSeverity = (svInfo, svWarn, svError, svFatal);

  TResponse = (reYes, reNo);

  IMessage = interface
    ['{7FA3858E-F765-4828-AA4B-50772F79AC01}']
    function GetText(): string;
    function GetSeverity(): TSeverity;

    property Text: string read GetText;
    property Severity: TSeverity read GetSeverity;
  end;

  IQuestion = interface
    ['{51429154-3587-4944-83C1-C484E8A488AF}']
    function GetText(): string;

    function GetResponse(): TResponse;
    procedure SetResponse(const pValue: TResponse);

    function GetDefaultFocus: TResponse;

    property Text: string read GetText;
    property Response: TResponse read GetResponse write SetResponse;
    property DefaultFocus: TResponse read GetDefaultFocus;
  end;

  IMessageAppender = interface
    ['{3847956F-2667-4CD9-B90A-2C77675F8270}']
    procedure Append(pMessage: IMessage); overload;
    procedure Append(pQuestion: IQuestion); overload;
  end;

  TMessageAppenderDelegate<TInterface: IMessageAppender> = reference to function: TInterface;

  IMessageContext = interface
    ['{0B3E6D99-87B4-45F5-8CF7-DC6F1F55CC68}']
    procedure RegisterAppender(pDelegate: TMessageAppenderDelegate<IMessageAppender>);

    procedure Show(const pText: string; const pSeverity: TSeverity); overload;
    procedure Show(pMessage: IMessage); overload;

    function Question(const pText: string; const pDefaultFocus: TResponse): TResponse; overload;
    function Question(pQuestion: IQuestion): TResponse; overload;
  end;

  Message = class sealed
  strict private
  const
    CanNotBeInstantiatedException = 'This class can not be instantiated!';
  strict private

    {$HINTS OFF}

    constructor Create;

    {$HINTS ON}

  public
    class function Context(): IMessageContext; static;

    class function New(const pText: string; const pSeverity: TSeverity): IMessage; static;
    class function NewQuestion(const pText: string; const pDefaultFocus: TResponse): IQuestion; static;
  end;

implementation

type

  TDefaultMessage = class(TInterfacedObject, IMessage)
  strict private
    FText: string;
    FSeverity: TSeverity;
    function GetText(): string;
    function GetSeverity(): TSeverity;
  public
    constructor Create(const pText: string; const pSeverity: TSeverity);

    property Text: string read GetText;
    property Severity: TSeverity read GetSeverity;
  end;

  TDefaultQuestion = class(TInterfacedObject, IQuestion)
  strict private
    FText: string;
    FResponse: TResponse;
    FDefaultFocus: TResponse;

    function GetText(): string;

    function GetResponse(): TResponse;
    procedure SetResponse(const pValue: TResponse);

    function GetDefaultFocus: TResponse;
  public
    constructor Create(const pText: string; const pDefaultFocus: TResponse);

    property Text: string read GetText;
    property Response: TResponse read GetResponse write SetResponse;
    property DefaultFocus: TResponse read GetDefaultFocus;
  end;

  TDefaultMessageAppender = class(TInterfacedObject, IMessageAppender)
  strict private
  const
    ClassNotFoundException = 'Message Appender not defined!';
  public
    procedure Append(pMessage: IMessage); overload;
    procedure Append(pQuestion: IQuestion); overload;
  end;

  TMessageContext = class(TInterfacedObject, IMessageContext)
  strict private
  type
    TRegistration<T: IMessageAppender> = class
    strict private
      FDelegate: TMessageAppenderDelegate<T>;
      FInstance: T;
    public
      property Delegate: TMessageAppenderDelegate<T> read FDelegate write FDelegate;
      property Instance: T read FInstance write FInstance;
    end;
  strict private
    FAppender: TRegistration<IMessageAppender>;
    function GetAppender(): IMessageAppender;
  public
    constructor Create();
    destructor Destroy; override;

    procedure RegisterAppender(pDelegate: TMessageAppenderDelegate<IMessageAppender>);

    procedure Show(const pText: string; const pSeverity: TSeverity); overload;
    procedure Show(pMessage: IMessage); overload;

    function Question(const pText: string; const pDefaultFocus: TResponse): TResponse; overload;
    function Question(pQuestion: IQuestion): TResponse; overload;
  end;

  TSingletonMessageContext = class sealed
  strict private
    class var Instance: IMessageContext;
    class constructor Create;
    class destructor Destroy;
  public
    class function GetInstance: IMessageContext; static;
  end;

  { TDefaultMessage }

constructor TDefaultMessage.Create(const pText: string; const pSeverity: TSeverity);
begin
  FText := pText;
  FSeverity := pSeverity;
end;

function TDefaultMessage.GetSeverity: TSeverity;
begin
  Result := FSeverity;
end;

function TDefaultMessage.GetText: string;
begin
  Result := FText;
end;

{ TMessageContext }

procedure TMessageContext.Show(const pText: string; const pSeverity: TSeverity);
begin
  Show(TDefaultMessage.Create(pText, pSeverity));
end;

procedure TMessageContext.Show(pMessage: IMessage);
begin
  GetAppender.Append(pMessage);
end;

constructor TMessageContext.Create;
begin
  FAppender := TRegistration<IMessageAppender>.Create();
end;

destructor TMessageContext.Destroy;
begin
  FreeAndNil(FAppender);
  inherited;
end;

function TMessageContext.GetAppender: IMessageAppender;
begin
  if (FAppender.Instance = nil) then
  begin
    if Assigned(FAppender.Delegate()) then
      FAppender.Instance := FAppender.Delegate();

    if (FAppender.Instance = nil) then
      FAppender.Instance := TDefaultMessageAppender.Create();
  end;
  Result := FAppender.Instance;
end;

function TMessageContext.Question(const pText: string; const pDefaultFocus: TResponse): TResponse;
begin
  Result := Question(TDefaultQuestion.Create(pText, pDefaultFocus));
end;

function TMessageContext.Question(pQuestion: IQuestion): TResponse;
begin
  GetAppender.Append(pQuestion);
  Result := pQuestion.Response;
end;

procedure TMessageContext.RegisterAppender(pDelegate: TMessageAppenderDelegate<IMessageAppender>);
begin
  FAppender.Delegate := pDelegate;
end;

{ TDefaultMessageAppender }

procedure TDefaultMessageAppender.Append(pMessage: IMessage);
begin
  raise EMessageAppenderException.Create(ClassNotFoundException);
end;

procedure TDefaultMessageAppender.Append(pQuestion: IQuestion);
begin
  raise EMessageAppenderException.Create(ClassNotFoundException);
end;

{ Message }

class function Message.Context: IMessageContext;
begin
  Result := TSingletonMessageContext.GetInstance;
end;

constructor Message.Create;
begin
  raise EMessageContextException.Create(CanNotBeInstantiatedException);
end;

class function Message.New(const pText: string; const pSeverity: TSeverity): IMessage;
begin
  Result := TDefaultMessage.Create(pText, pSeverity);
end;

class function Message.NewQuestion(const pText: string; const pDefaultFocus: TResponse): IQuestion;
begin
  Result := TDefaultQuestion.Create(pText, pDefaultFocus);
end;

{ TSingletonMessageContext }

class constructor TSingletonMessageContext.Create;
begin
  Instance := TMessageContext.Create;
end;

class destructor TSingletonMessageContext.Destroy;
begin
  Instance := nil;
end;

class function TSingletonMessageContext.GetInstance: IMessageContext;
begin
  Result := Instance;
end;

{ TDefaultQuestion }

constructor TDefaultQuestion.Create(const pText: string; const pDefaultFocus: TResponse);
begin
  FText := pText;
  FDefaultFocus := pDefaultFocus;
  FResponse := reYes;
end;

function TDefaultQuestion.GetDefaultFocus: TResponse;
begin
  Result := FDefaultFocus;
end;

function TDefaultQuestion.GetResponse: TResponse;
begin
  Result := FResponse;
end;

function TDefaultQuestion.GetText: string;
begin
  Result := FText;
end;

procedure TDefaultQuestion.SetResponse(const pValue: TResponse);
begin
  FResponse := pValue;
end;

end.
