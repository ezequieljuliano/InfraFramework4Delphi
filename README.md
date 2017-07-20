Infra Framework For Delphi
=============================

The InfraFramework4Delphi it is an API that provides a base infrastructure for the Delphi application development using a layered architecture. 

It is important to stress that the InfraFramework4Delphi not forces any type of architecture for applications, which may consist of many layers as necessary. However, it is prudent not exaggerate! For those who do not know where to start, I suggest an architecture widely used by market standards in order to facilitate maintenance and to better modularize your project.

Usually, applications are composed of at least three layers, so it is common to separate the logic of presentation, business rules and persistence. The InfraFramework4Delphi provides mechanisms to make this clearer separation. For organizational reasons, it is recommended that no layer is circumvented. In practical terms, the presentation layer accesses the business layer, which, in turn, accesses the persistence.

Its premise is to facilitate the use layering without losing productivity, ie, enables the use of all the power of DBware components. In InfraFramework4Delphi the Persistence layer is represented by Data Modules with their corresponding data access components, the Business layer is represented by a derived class of TBusinessController and is responsible for all business rule, and the View layer is represented by Form and components of interaction with the user.

The InfraFramework4Delphi further provides libraries useful auxiliary for developing any Delphi application and requires Delphi 2010 or greater.


Persistence Adapters Drivers
=================

The InfraFramework4Delphi is available for the following data access drivers:

- FireDAC
- ADO


External Dependencies
=====================

The InfraFramework4Delphi makes use of some external dependencies. Therefore these dependences are included in the project within the "dependencies" folder. If you use the library parser you should add to the Path SQLBuilder4Delphi.

- SQLBuilder4Delphi: [https://github.com/ezequieljuliano/SQLBuilder4Delphi](https://github.com/ezequieljuliano/SQLBuilder4Delphi)


Samples
=========

Within the project there are a few examples of API usage. In addition there are also some unit tests that can aid in the use of InfraFramework4Delphi.


Using InfraFramework4Delphi
==========================

Using this API will is very simple, you simply add the Search Path of your IDE or your project the following directories:

- InfraFramework4Delphi\dependencies\SQLBuilder4Delphi\dependencies\gaSQLParser\src
- InfraFramework4Delphi\dependencies\SQLBuilder4Delphi\src
- InfraFramework4Delphi\src\layers
- InfraFramework4Delphi\src\utilities


InfraFramework4Delphi in 5 Minutes
==================================

Here is a step by step how to create a Delphi application into layers using the FireDAC components:

First you must create a Data Module responsible for the connection to your database. Example:

    uses 
	  InfraFwk4D.Persistence, 
      InfraFwk4D.Persistence.Adapter.FireDAC;

	type
	
	  TDALConnection = class(TDataModule)
	    FDConnection: TFDConnection;
	    FDGUIxWaitCursor: TFDGUIxWaitCursor;
	    FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
	    procedure DataModuleCreate(Sender: TObject);
	    procedure DataModuleDestroy(Sender: TObject);
	  private
	    fConnection: IDBConnection<TFDConnection>;
	    fSession: IDBSession;
	  public
	    function GetSession: IDBSession;
	  end;
    
After you create your Persistence Layer (DAO - Data Access Object) and your Datasets and Fields. Example:
    
    uses 
      InfraFwk4D.Persistence.Template.FireDAC {You can use a ready-made template or build your own}, 
      InfraFwk4D.DataSet.Iterator, 
      InfraFwk4D.Persistence;

	  TCountryDAO = class(TPersistenceTemplateFireDAC)
	    Country: TFDQuery;
	    CountryID: TIntegerField;
	    CountryNAME: TStringField;
	  private
	    { Private declarations }
	  public
	    function FindByName(const name: string): IDataSetIterator;
	    function FindById(const id: Integer): IDataSetIterator;
	    function FindAll: IDataSetIterator;
	
	    procedure FilterById(const id: Integer);
	    procedure Desfilter;
	
	    procedure UpdateNameById(const name: string; const id: Integer);
	  end;

Now create your Business Rules Layer. For that inherit the business module informing the Persistence Layer. Example:

    uses 
      InfraFwk4D.Business,
      Country.DAO;

	  TCountryBC = class(TBusinessController<TCountryDAO>)
	  private
	    fCount: Integer;
	  protected
	    { protected declarations }
	  public
	    procedure ProcessCounting;
	    property Count: Integer read fCount;
	  end;

Finally, create a new Form to be the View Layer. The View Layer will interact with the Business Rules Layer. Example:

    uses 
      Country.DAO, 
      Country.BC; 

	type
	
	  TCountryView = class(TForm)
	    DBGrid1: TDBGrid;
	    DBNavigator1: TDBNavigator;
	    DsoCountry: TDataSource;
	    Panel1: TPanel;
	    Button2: TButton;
	    Button1: TButton;
	    Button3: TButton;
	    Label1: TLabel;
	    Button4: TButton;
	    Button5: TButton;
	    Button6: TButton;
	    procedure FormCreate(Sender: TObject);
	    procedure Button1Click(Sender: TObject);
	    procedure Button2Click(Sender: TObject);
	    procedure Button3Click(Sender: TObject);
	    procedure Button4Click(Sender: TObject);
	    procedure FormDestroy(Sender: TObject);
	    procedure Button5Click(Sender: TObject);
	    procedure Button6Click(Sender: TObject);
	  private
	    fCountryBC: TCountryBC;
	  public
	    { public declarations }
	  end;

# Message Context #

A well structured application, either on the Web or Desktop platform, should display informational message, warning, or error to the user after performing certain tasks. In summary, it must be programmed to exchange messages between different layers of an object oriented implementation. The implementation of the message context has been designed in a simple and flexible way, regardless of layer, leaving you free to implement their own solution or use the existing extensions.

**Creating Its Implementation**

The key to the message module is the IMessageAppender interface. To create a new mechanism for show messages, you only need to implement the interface in your application. Below is a sample implementation:

	uses
	  InfraFwk4D.Message,
	  Vcl.Forms,
	  Winapi.Windows;
	
	type
	
	  TMessageAppender = class(TInterfacedObject, IMessageAppender)
	  private
	    const APP_NAME = 'MESSAGE APP';
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

Now add in the message context of your appender:

	uses
      InfraFwk4D.Message,
      InfraFwk4D.Message.Impl;

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


# Validator Context #

Validator Context allows to express and validate application constraints. The default metadata source are annotations. Enables you to incorporate validation into your application data through an easy-to-use and customize API.

Examples:

	  uses
        InfraFwk4D.Validation.Default.Attributes; 

      TEntity = class
	  private
	    [AssertFalse]
	    fFalseValue: Boolean;
	
	    fTrueValue: Boolean;
	
	    [Max(20)]
	    fMaxValue: Integer;
	
	    fMinValue: Integer;
	
	    [Size(5, 10)]
	    fSizeValue: string;
	
	    [NotNull]
	    fNotNullValue: string;
	
	    [Null]
	    fNullValue: string;
	
	    [Past]
	    fPastValue: TDateTime;
	
	    [Present]
	    fPresentValue: TDateTime;
	
	    [Future]
	    fFutureValue: TDateTime;
	
	    [DecimalMax(20.5)]
	    fDecimalMaxValue: Double;
	
	    [DecimalMin(10.5)]
	    fDecimalMinValue: Double;
	
	    [NotNullWhen('fMaxValue', 20)]
	    fNotNullWhenValue: string;
	
	    [NotNullWhen('fFalseValue', False)]
	    fNotNullWhenBooleanValue: string;
	
	    [NotNullIn('fMaxValue', '10;20;30')]
	    fNotNullInValues: string;
	
	    [AssertIn('10;20;30')]
	    fAssertInValue: string;
	  public
	    constructor Create;
	
	    property FalseValue: Boolean read fFalseValue write fFalseValue;
	
	    [AssertTrue]
	    property TrueValue: Boolean read fTrueValue write fTrueValue;
	    property MaxValue: Integer read fMaxValue write fMaxValue;
	
	    [Min(5)]
	    property MinValue: Integer read fMinValue write fMinValue;
	
	    property SizeValue: string read fSizeValue write fSizeValue;
	    property NotNullValue: string read fNotNullValue write fNotNullValue;
	    property NullValue: string read fNullValue write fNullValue;
	    property PastValue: TDateTime read fPastValue write fPastValue;
	    property PresentValue: TDateTime read fPresentValue write fPresentValue;
	    property FutureValue: TDateTime read fFutureValue write fFutureValue;
	    property DecimalMaxValue: Double read fDecimalMaxValue write fDecimalMaxValue;
	    property DecimalMinValue: Double read fDecimalMinValue write fDecimalMinValue;
	    property NotNullWhenValue: string read fNotNullWhenValue write fNotNullWhenValue;
	    property NotNullWhenBooleanValue: string read fNotNullWhenBooleanValue write fNotNullWhenBooleanValue;
	    property NotNullInValues: string read fNotNullInValues write fNotNullInValues;
	    property AssertInValue: string read fAssertInValue write fAssertInValue;
	  end;


	  TModel = class(TDataModule)
	    Entity: TClientDataSet;
	
	    [AssertFalse]
	    EntityFalseValue: TBooleanField;
	
	    [AssertTrue]
	    EntityTrueValue: TBooleanField;
	
	    [Max(20)]
	    EntityMaxValue: TIntegerField;
	
	    [Min(5)]
	    EntityMinValue: TIntegerField;
	
	    [Size(5, 10)]
	    EntitySizeValue: TStringField;
	
	    [NotNull]
	    EntityNotNullValue: TStringField;
	
	    [Null]
	    EntityNullValue: TStringField;
	
	    [Past]
	    EntityPastValue: TDateField;
	
	    [Present]
	    EntityPresentValue: TDateField;
	
	    [Future]
	    EntityFutureValue: TDateField;
	
	    [DecimalMax(20.5)]
	    EntityDecimalMaxValue: TFloatField;
	
	    [DecimalMin(10.5)]
	    EntityDecimalMinValue: TFloatField;
	
	    [NotNullWhen('EntityMaxValue', '20')]
	    EntityNotNullWhenValue: TStringField;
	
	    [NotNullWhen('EntityFalseValue', False)]
	    EntityNotNullWhenBooleanValue: TStringField;
	
	    [NotNullIn('EntityMaxValue', '10;20;30;40')]
	    EntityNotNullInValues: TStringField;
	
	    [AssertIn('10;20;30')]
	    EntityAssertInValue: TStringField;
	
	    procedure DataModuleCreate(Sender: TObject);
	  private
	    { Private declarations }
	  public
	    { Public declarations }
	  end;