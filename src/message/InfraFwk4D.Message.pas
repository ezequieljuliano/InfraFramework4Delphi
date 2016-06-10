unit InfraFwk4D.Message;

interface

uses
  System.SysUtils;

type

  EMessageException = class(Exception);
  EMessageAppenderException = class(EMessageException);

  TSeverity = (svInfo, svWarn, svError, svFatal);
  TResponse = (reYes, reNo);

  IMessage = interface
    ['{02F3F1DC-3856-4253-B2CC-50CAB3A6CA06}']
    function GetText: string;
    function GetSeverity: TSeverity;
  end;

  IQuestion = interface
    ['{B9C8B8B7-4197-4573-89E4-E52CE0AD76E8}']
    function GetText: string;
    function GetFocus: TResponse;
    function GetResponse: TResponse;
    function SetResponse(const value: TResponse): IQuestion;
  end;

  IMessageAppender = interface
    ['{2F8FB12C-0208-4B5F-B863-E7F45C990743}']
    procedure Append(message: IMessage); overload;
    procedure Append(question: IQuestion); overload;
  end;

  IMessageContext = interface
    ['{78EC5B84-CF72-4BBB-9DB5-EC319CD20235}']
    procedure RegisterAppender(appender: IMessageAppender);

    procedure Display(const text: string; const severity: TSeverity; const args: array of const); overload;
    procedure Display(const text: string; const severity: TSeverity); overload;
    procedure Display(const text: string); overload;

    function Ask(const text: string; const focus: TResponse; const args: array of const): TResponse; overload;
    function Ask(const text: string; const focus: TResponse): TResponse; overload;
    function Ask(const text: string): TResponse; overload;
  end;

implementation

end.
