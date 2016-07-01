unit InfraFwk4D.Validation;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections;

type

  EValidationException = class(Exception);

  ConstraintAttribute = class(TCustomAttribute)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  ConstraintAttributeClass = class of ConstraintAttribute;

  IValidation = interface(IInvokable)
    ['{C17A91EC-29F3-4FDB-A7FE-9CA4F84340D9}']
  end;

  IConstraintValidator = interface(IValidation)
    ['{765B05D8-7481-4E96-B5F0-1740A218FD4B}']
    procedure Initialize(const attribute: ConstraintAttribute; const obj: TObject);
    function IsValid(const value: TValue): Boolean;
    function ProcessingMessage(const msg: string): string;
  end;

  IConstraintViolation = interface(IValidation)
    ['{37BBE61D-A2F3-44C0-8122-D775E514D8C0}']
    function GetMessage: string;
    function GetClass: TClass;
    function GetObject: TObject;
    function GetInvalidValue: TValue;
    function GetValueOwnersName: string;
  end;

  IValidatorContext = interface(IValidation)
    ['{0A0C3DAC-94AF-4A98-94DF-4A9C89EFF4D1}']
    procedure RegisterConstraintValidator(const attribute: ConstraintAttributeClass; const validatedBy: IConstraintValidator);
    procedure RegisterConstraintMessage(const attribute: ConstraintAttributeClass; const msg: string);

    function Validate(const obj: TObject): TList<IConstraintViolation>;
  end;

implementation

end.
