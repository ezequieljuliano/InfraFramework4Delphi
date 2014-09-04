unit InfraDB4D.Iterator;

interface

uses
  System.SysUtils,
  Data.DB;

type
  IIteratorDataSet = interface
    function HasNext(): Boolean;
    function Fields: TFields;
    function FieldByName( const pFieldName: string ): TField;

    function RecIndex: Integer;
    function GetDataSet: TDataSet;
  end;

  TIteratorDataSetFactory = class
  public
    class function Get( const pDataSet: TDataSet ): IIteratorDataSet; overload; static;
    class function Get( const pDataSet: TDataSet; const pDestroyDataSet: Boolean ): IIteratorDataSet; overload;
  end;


implementation

{ TIteratorDataSet }

type

  TIteratorDataSet = class(TInterfacedObject, IIteratorDataSet)
  strict private
    CurrentCount: Integer;
    DataSet: TDataSet;
    DestroyDataSet: Boolean;

    function HasNext(): Boolean;
    function Fields: TFields;
    function FieldByName( const pFieldName: string ): TField;

    function RecIndex: Integer;

    function GetDataSet: TDataSet;

    destructor Destroy(); override;
  private
    constructor Create( const pDataSet: TDataSet; const pDestroyDataSet: Boolean ); overload;
  end;


constructor TIteratorDataSet.Create(const pDataSet: TDataSet; const pDestroyDataSet: Boolean);
begin
  DataSet:= pDataSet;

  if ( not ( DataSet.Active ) ) then
    DataSet.Open;

  DataSet.First();
  CurrentCount:= 0;

  DestroyDataSet:= False;
  DestroyDataSet:= pDestroyDataSet;
end;

function TIteratorDataSet.GetDataSet: TDataSet;
begin
  Result:= DataSet;
end;

destructor TIteratorDataSet.Destroy;
begin
  if ( DestroyDataSet ) then
    FreeAndNil( DataSet);

  inherited;
end;

function TIteratorDataSet.FieldByName(const pFieldName: string): TField;
begin
  Result:= DataSet.FieldByName( pFieldName );
end;

function TIteratorDataSet.Fields: TFields;
begin
  Result:= DataSet.Fields;
end;


function TIteratorDataSet.HasNext: Boolean;
begin
  if ( CurrentCount = 0 ) then
    CurrentCount:= 1
  else
    Inc( CurrentCount );

  if ( CurrentCount > 1 ) then
    DataSet.Next();

  Result:= not DataSet.Eof;
end;


function TIteratorDataSet.RecIndex: Integer;
begin
  Result:= CurrentCount;
end;


{ TIteratorDataSetFactory }

class function TIteratorDataSetFactory.Get(
  const pDataSet: TDataSet): IIteratorDataSet;
begin
  Result:=  TIteratorDataSet.Create( pDataSet, False );
end;

class function TIteratorDataSetFactory.Get(const pDataSet: TDataSet;
  const pDestroyDataSet: Boolean): IIteratorDataSet;
begin
  Result:=  TIteratorDataSet.Create( pDataSet, pDestroyDataSet );
end;

end.
