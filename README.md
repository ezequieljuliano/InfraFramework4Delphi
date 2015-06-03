Infra Framework For Delphi
=============================

The InfraFramework4Delphi it is an API that provides a base infrastructure for the Delphi application development using a layered architecture. 

It is important to stress that the InfraFramework4Delphi not forces any type of architecture for applications, which may consist of many layers as necessary. However, it is prudent not exaggerate! For those who do not know where to start, I suggest an architecture widely used by market standards in order to facilitate maintenance and to better modularize your project.

Usually, applications are composed of at least three layers, so it is common to separate the logic of presentation, business rules and persistence. The InfraFramework4Delphi provides mechanisms to make this clearer separation. For organizational reasons, it is recommended that no layer is circumvented. In practical terms, the presentation layer accesses the business layer, which, in turn, accesses the persistence.

Its premise is to facilitate the use layering without losing productivity, ie, enables the use of all the power of DBware components. In InfraFramework4Delphi the Persistence layer is represented by Data Modules with their corresponding data access components, the Business layer is represented by a derived class of TDriverController and is responsible for all business rule, and the View layer is represented by Form and components of interaction with the user.

The InfraFramework4Delphi further provides libraries useful auxiliary for developing any Delphi application and requires Delphi XE or greater.


Persistence Adapters Drivers
=================

The InfraFramework4Delphi is available for the following data access drivers:

- FireDAC
- IBX
- UniDAC


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
- InfraFramework4Delphi\src

Then you must add to your project the Persistence Module Data according to Driver Adapter used, so that you can make to your heritage DAO's:

- InfraFwk4D.Driver.FireDAC.Persistence.pas
- InfraFwk4D.Driver.IBX.Persistence.pas
- InfraFwk4D.Driver.UniDAC.Persistence.pas


InfraFramework4Delphi in 5 Minutes
==================================

Here is a step by step how to create a Delphi application into layers using the FireDAC components:

First you must create a Data Module responsible for the connection to your database. Example:

    uses InfraFwk4D.Driver.FireDAC, InfraFwk4D;

    TDatabaseFireDAC = class(TDataModule)
       FDConnection: TFDConnection;
       FDGUIxWaitCursor: TFDGUIxWaitCursor;
       FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
       procedure DataModuleCreate(Sender: TObject);
       procedure DataModuleDestroy(Sender: TObject);
    strict private
       class var SingletonDatabaseFireDAC: TDatabaseFireDAC;
    
       class constructor Create;
       class destructor Destroy;
    strict private
       FConnectionAdapter: TFireDACConnectionAdapter;
    
       function GetConnectionAdapter(): TFireDACConnectionAdapter;
    public
       class function GetAdapter(): TFireDACConnectionAdapter; static;
    end;
    
After you create your Persistence Layer (DAO - Data Access Object) inheriting the persistence module referring to components of data access. Add your Datasets, Fields and implement the GetConnection and ConfigureDataSetsConnection methods. Example:
    
    uses InfraFwk4D.Driver.FireDAC, 
         InfraFwk4D.Iterator.DataSet, 
         InfraFwk4D.Driver.FireDAC.Persistence;

    TCountryDAO = class(TFireDACPersistenceAdapter)
       Country: TFDQuery;
       CountryID: TIntegerField;
       CountryNAME: TStringField;
    strict protected
       function GetConnection(): TFireDACConnectionAdapter; override;
       procedure ConfigureDataSetsConnection(); override;
    public
       function FindByName(const pName: string): IIteratorDataSet;
    end;

Now create your Business Rules Layer. For that inherit the business module informing the Persistence Layer. Example:

    uses InfraFwk4D.Driver,
         Country.DAO, 
         InfraFwk4D.Iterator.DataSet;

    TCountryBC = class(TBusinessAdapter<TCountryDAO>)
    public
       function FindByName(const pName: string): IIteratorDataSet;
       procedure FilterById(const pId: Integer);
    end;

Finally, create a new Form to be the View Layer. The View Layer will interact with the Business Rules Layer. Example:

    uses Country.DAO, Country.BC; 

    TCountryView = class(TForm)
       DBGrid1: TDBGrid;
       DBNavigator1: TDBNavigator;
       DsoCountry: TDataSource;
       Panel1: TPanel;
       Button2: TButton;
       Button1: TButton;
       procedure FormCreate(Sender: TObject);
       procedure FormDestroy(Sender: TObject);
       procedure Button1Click(Sender: TObject);
       procedure Button2Click(Sender: TObject);
    private
       FCountryBC: TCountryBC;
    public
       { Public declarations }
    end;

    procedure TCountryView.FormCreate(Sender: TObject);
    begin
      FCountryBC := TCountryBC.Create(TCountryDAO);
      DsoCountry.DataSet := FCountryBC.Persistence.Country;
      FCountryBC.Persistence.Country.Open();
    end;
    
    procedure TCountryView.FormDestroy(Sender: TObject);
    begin
      FreeAndNil(FCountryBC);
    end;
    
    procedure TCountryView.Button1Click(Sender: TObject);
    var
      vName: string;
    begin
      vName := InputBox('Country', 'Name', '');
      with FCountryBC.FindByName(vName) do
      if not IsEmpty then
        ShowMessage('Country Id: ' + FieldByName('Id').AsString + ' Name: ' 
          + FieldByName('Name').AsString)
      else
        ShowMessage('Not found!');
    end;
    
    procedure TCountryView.Button2Click(Sender: TObject);
    var
      vId: string;
    begin
      vId := InputBox('Country', 'Id', '');
      FCountryBC.FilterById(StrToIntDef(vId, 0));
      if FCountryBC.Persistence.Country.IsEmpty then
        ShowMessage('Not found!');
    end;

# Message Context #

A well structured application, either on the Web or Desktop platform, should display informational message, warning, or error to the user after performing certain tasks. In summary, it must be programmed to exchange messages between different layers of an object oriented implementation. The implementation of the message context has been designed in a simple and flexible way, regardless of layer, leaving you free to implement their own solution or use the existing extensions.

**Creating Its Implementation**

The key to the message module is the IMessageAppender interface. To create a new mechanism for show messages, you only need to implement the interface in your application. Below is a sample implementation:

	  uses
        InfraFwk4D.Message.Context;

	  TMessageAppender = class(TInterfacedObject, IMessageAppender)
	  strict private
	  const
	    APP_NAME = 'APP TEST';
	  public
	    procedure Append(pMessage: IMessage); overload;
	    procedure Append(pQuestion: IQuestion); overload;
	  end;

	procedure TMessageAppender.Append(pMessage: IMessage);
	begin
	  case pMessage.Severity of
	    svInfo:
	      Application.MessageBox(PChar(pMessage.Text), 
            PChar(APP_NAME), MB_ICONINFORMATION + MB_OK);
	    svWarn:
	      Application.MessageBox(PChar(pMessage.Text), 
            PChar(APP_NAME), MB_ICONWARNING + MB_OK);
	    svError, svFatal:
	      Application.MessageBox(PChar(pMessage.Text), 
            PChar(APP_NAME), MB_ICONERROR + MB_OK);
	  end;
	end;
	
	procedure TMessageAppender.Append(pQuestion: IQuestion);
	var
	  vFocus: Integer;
	begin
	  vFocus := MB_DEFBUTTON1;
	  if (pQuestion.DefaultFocus = reNo) then
	    vFocus := MB_DEFBUTTON2;
	  case Application.MessageBox(PChar(pQuestion.Text), 
       PChar(APP_NAME), MB_ICONQUESTION + MB_YESNO + vFocus) of
	    IDYES: pQuestion.Response := reYes;
	    IDNO: pQuestion.Response := reNo;
	  end;
	end;

Now add in the message context of your appender:

	Message.Context.RegisterAppender(
	    function: IMessageAppender
	    begin
	      Result := TMessageAppender.Create;
	    end
	    );

After all configured to use the security context you simply add the Uses of InfraFwk4D.Message.Context.pas and use in their codes:

	 Message.Context.Show('Info Message', svInfo);
	 Message.Context.Show('Warn Message', svWarn);
	 Message.Context.Show('Error Message', svError);
	 Message.Context.Show('Fatal Message', svFatal);

	var
	  vResponse: TResponse;
	begin
	  vResponse := Message.Context.Question('Question?', reYes);