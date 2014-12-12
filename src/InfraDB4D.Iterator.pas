unit InfraDB4D.Iterator;

interface

uses
  System.SysUtils,
  Data.DB,
  System.Generics.Collections;

type

  IIterator<T: TDataSet> = interface
    ['{D992FC27-DD57-42D4-8E14-EF087B742BDC}']
    function HasNext(): Boolean;
    function RecIndex: Integer;
    function IsEmpty(): Boolean;
    function Fields: TFields;
    function FieldByName(const pFieldName: string): TField;

    procedure FillSameFields(const pTarget: T); overload;
    procedure FillSameFields(const pTarget: IIterator<T>); overload;
    procedure SetSameFieldsValues(const pProvider: T); overload;
    procedure SetSameFieldsValues(const pProvider: IIterator<T>); overload;

    function GetDataSet: T;
  end;

  TIteratorFactory<T: TDataSet> = class
  public
    class function Get(const pDataSet: T): IIterator<T>; overload; static;
    class function Get(const pDataSet: T; const pDestroyDataSet: Boolean): IIterator<T>; overload; static;
  end;

  IIteratorDataSet = interface(IIterator<TDataSet>)
    ['{754D235E-8941-4534-A193-C5696DABDB34}']
  end;

  TIteratorDataSetFactory = class
  public
    class function Get(const pDataSet: TDataSet): IIteratorDataSet; overload; static;
    class function Get(const pDataSet: TDataSet; const pDestroyDataSet: Boolean): IIteratorDataSet; overload; static;
  end;

implementation

uses
  InfraDB4D.Iterator.Impl;

{ TIteratorFactory<T> }

class function TIteratorFactory<T>.Get(const pDataSet: T): IIterator<T>;
begin
  Result := TIterator<T>.Create(pDataSet, False);
end;

class function TIteratorFactory<T>.Get(const pDataSet: T; const pDestroyDataSet: Boolean): IIterator<T>;
begin
  Result := TIterator<T>.Create(pDataSet, pDestroyDataSet);
end;

{ TIteratorDataSetFactory }

class function TIteratorDataSetFactory.Get(const pDataSet: TDataSet): IIteratorDataSet;
begin
  Result := TIteratorDataSet.Create(pDataSet, False);
end;

class function TIteratorDataSetFactory.Get(const pDataSet: TDataSet; const pDestroyDataSet: Boolean): IIteratorDataSet;
begin
  Result := TIteratorDataSet.Create(pDataSet, pDestroyDataSet);
end;

end.
