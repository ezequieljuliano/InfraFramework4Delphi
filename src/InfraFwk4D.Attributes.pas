unit InfraFwk4D.Attributes;

interface

uses
  System.Classes;

type

  DataSetComponentAttribute = class(TCustomAttribute)
  strict private
    FComponentName: string;
  public
    constructor Create(const pComponentName: string);

    property ComponentName: string read FComponentName;
  end;

implementation

{ DataSetNameAttribute }

constructor DataSetComponentAttribute.Create(const pComponentName: string);
begin
  FComponentName := pComponentName;
end;

end.
