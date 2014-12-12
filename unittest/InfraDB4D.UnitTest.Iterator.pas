unit InfraDB4D.UnitTest.Iterator;

interface

uses
  Data.DB,
  DBClient,
  TestFramework,
  InfraDB4D.Iterator,
  System.SysUtils;

type

  TestTIteratorDataSet = class(TTestCase)
  strict private
    function BuildDataSet(): TClientDataSet;
  published
    procedure TestIteratorWithDataSet();
    procedure TestIteratorWithBuildAsDataSet();
    procedure TestIteratorWithBuildAsGenericDataSet();
    procedure TestIteratorFillSameFields();
    procedure TestIteratorSetSameFieldsValues();
  end;

implementation

uses
  InfraDB4D;

{ TestTIteratorDataSet }

function TestTIteratorDataSet.BuildDataSet: TClientDataSet;
begin
  Result := TClientDataSet.Create(nil);
  Result.FieldDefs.Add('One', ftInteger);
  Result.FieldDefs.Add('Two', ftInteger);
  Result.FieldDefs.Add('Three', ftInteger);
  Result.CreateDataSet();
end;

procedure TestTIteratorDataSet.TestIteratorFillSameFields;
var
  Iterator1: IIteratorDataSet;
  Iterator2: IIteratorDataSet;
begin
  Iterator1 := TIteratorDataSetFactory.Get(
    { use metod BuildAsDataSet } BuildDataSet(), True { Parameter TRUE destroy CdsDataSet } );

  Iterator1.GetDataSet.Append;
  Iterator1.GetDataSet.FieldByName('One').AsInteger := 1;
  Iterator1.GetDataSet.FieldByName('Two').AsInteger := 2;
  Iterator1.GetDataSet.FieldByName('Three').AsInteger := 3;
  Iterator1.GetDataSet.Post;

  Iterator2 := TIteratorDataSetFactory.Get(
    { use metod BuildAsDataSet } BuildDataSet(), True { Parameter TRUE destroy CdsDataSet } );

  Iterator1.FillSameFields(Iterator2.GetDataSet);

  CheckTrue(
    (Iterator1.FieldByName('One').AsInteger = Iterator2.FieldByName('One').AsInteger) and
    (Iterator1.FieldByName('Two').AsInteger = Iterator2.FieldByName('Two').AsInteger) and
    (Iterator1.FieldByName('Three').AsInteger = Iterator2.FieldByName('Three').AsInteger)
    );

  Iterator1.GetDataSet.Edit;
  Iterator1.GetDataSet.FieldByName('One').AsInteger := 4;
  Iterator1.GetDataSet.FieldByName('Two').AsInteger := 5;
  Iterator1.GetDataSet.FieldByName('Three').AsInteger := 6;
  Iterator1.GetDataSet.Post;

  Iterator1.FillSameFields(Iterator2);

  CheckTrue(
    (Iterator1.FieldByName('One').AsInteger = Iterator2.FieldByName('One').AsInteger) and
    (Iterator1.FieldByName('Two').AsInteger = Iterator2.FieldByName('Two').AsInteger) and
    (Iterator1.FieldByName('Three').AsInteger = Iterator2.FieldByName('Three').AsInteger)
    );
end;

procedure TestTIteratorDataSet.TestIteratorSetSameFieldsValues;
var
  Iterator1: IIteratorDataSet;
  Iterator2: IIteratorDataSet;
begin
  Iterator2 := TIteratorDataSetFactory.Get(
    { use metod BuildAsDataSet } BuildDataSet(), True { Parameter TRUE destroy CdsDataSet } );

  Iterator2.GetDataSet.Append;
  Iterator2.GetDataSet.FieldByName('One').AsInteger := 1;
  Iterator2.GetDataSet.FieldByName('Two').AsInteger := 2;
  Iterator2.GetDataSet.FieldByName('Three').AsInteger := 3;
  Iterator2.GetDataSet.Post;

  Iterator1 := TIteratorDataSetFactory.Get(
    { use metod BuildAsDataSet } BuildDataSet(), True { Parameter TRUE destroy CdsDataSet } );

  Iterator1.SetSameFieldsValues(Iterator2.GetDataSet);

  CheckTrue(
    (Iterator1.FieldByName('One').AsInteger = Iterator2.FieldByName('One').AsInteger) and
    (Iterator1.FieldByName('Two').AsInteger = Iterator2.FieldByName('Two').AsInteger) and
    (Iterator1.FieldByName('Three').AsInteger = Iterator2.FieldByName('Three').AsInteger)
    );

  Iterator2.GetDataSet.Edit;
  Iterator2.GetDataSet.FieldByName('One').AsInteger := 4;
  Iterator2.GetDataSet.FieldByName('Two').AsInteger := 5;
  Iterator2.GetDataSet.FieldByName('Three').AsInteger := 6;
  Iterator2.GetDataSet.Post;

  Iterator1.SetSameFieldsValues(Iterator2);

  CheckTrue(
    (Iterator1.FieldByName('One').AsInteger = Iterator2.FieldByName('One').AsInteger) and
    (Iterator1.FieldByName('Two').AsInteger = Iterator2.FieldByName('Two').AsInteger) and
    (Iterator1.FieldByName('Three').AsInteger = Iterator2.FieldByName('Three').AsInteger)
    );
end;

procedure TestTIteratorDataSet.TestIteratorWithBuildAsDataSet;
var
  Iterator: IIteratorDataSet;
begin

  Iterator := TIteratorDataSetFactory.Get(
    { use metod BuildAsDataSet } BuildDataSet(), True { Parameter TRUE destroy CdsDataSet } );

  CheckTrue(Iterator.IsEmpty());

  while (Iterator.HasNext) do // loop in dataset - Don't is need to use TDataSet.Next
  begin
    Iterator.RecIndex; // get index current record dataset
    // your code
  end;
end;

procedure TestTIteratorDataSet.TestIteratorWithBuildAsGenericDataSet;
var
  Iterator: IIterator<TClientDataSet>;
begin

  Iterator := TIteratorFactory<TClientDataSet>.Get(
    { use metod BuildAsDataSet } BuildDataSet(), True { Parameter TRUE destroy CdsDataSet } );

  CheckTrue(Iterator.IsEmpty());

  while (Iterator.HasNext) do // loop in dataset - Don't is need to use TDataSet.Next
  begin
    Iterator.RecIndex; // get index current record dataset
    // your code
  end;
end;

procedure TestTIteratorDataSet.TestIteratorWithDataSet;
var
  Iterator: IIteratorDataSet;
  CdsDataSet: TClientDataSet;

  procedure AddValueInDataSet(const pCity, pState: string; const pPosition: Integer);
  begin
    CdsDataSet.Insert();
    CdsDataSet.FieldByName('City').AsString := pCity;
    CdsDataSet.FieldByName('State').AsString := pState;
    CdsDataSet.FieldByName('Position').AsInteger := pPosition;
    CdsDataSet.Post();
  end;

begin
  // You can to use any class inherited TDataSet
  // I will create a TClientDataSet for example

  CdsDataSet := TClientDataSet.Create(nil);

  CdsDataSet.FieldDefs.Add('City', ftString, 20);
  CdsDataSet.FieldDefs.Add('State', ftString, 2);
  CdsDataSet.FieldDefs.Add('Position', ftInteger);
  CdsDataSet.CreateDataSet;

  AddValueInDataSet('São Paulo', 'SP', 1);
  AddValueInDataSet('Maravilha', 'SC', 2);
  AddValueInDataSet('São Miguel do Oeste', 'SC', 3);

  CdsDataSet.IndexFieldNames := 'City'; // order dataset for test

  Iterator := TIteratorDataSetFactory.Get(CdsDataSet, True { Parameter TRUE destroy CdsDataSet } );

  CheckFalse(Iterator.IsEmpty());

  while (Iterator.HasNext) do // loop in dataset - Don't is need to use TDataSet.Next
  begin

    if (Iterator.RecIndex = 1) then // get index current record dataset
    begin
      CheckEquals('Maravilha', Iterator.FieldByName('City').AsString, 'RecIndex = ' + Iterator.RecIndex.ToString); // acess field in dataset
      CheckEquals('SC', Iterator.FieldByName('State').AsString, 'RecIndex = ' + Iterator.RecIndex.ToString);
      CheckEquals(2, Iterator.FieldByName('Position').AsInteger, 'RecIndex = ' + Iterator.RecIndex.ToString);
    end
    else
      if (Iterator.RecIndex = 2) then
    begin
      CheckEquals('São Miguel do Oeste', Iterator.FieldByName('City').AsString, 'RecIndex = ' + Iterator.RecIndex.ToString);
      CheckEquals('SC', Iterator.FieldByName('State').AsString, 'RecIndex = ' + Iterator.RecIndex.ToString);
      CheckEquals(3, Iterator.FieldByName('Position').AsInteger, 'RecIndex = ' + Iterator.RecIndex.ToString);
    end
    else
      if (Iterator.RecIndex = 1) then
    begin
      CheckEquals('São Paulo', Iterator.FieldByName('City').AsString, 'RecIndex = ' + Iterator.RecIndex.ToString);
      CheckEquals('SP', Iterator.FieldByName('State').AsString, 'RecIndex = ' + Iterator.RecIndex.ToString);
      CheckEquals(1, Iterator.FieldByName('Position').AsInteger, 'RecIndex = ' + Iterator.RecIndex.ToString);
    end;
  end;

end;

initialization

// Register any test cases with the test runner
RegisterTest(TestTIteratorDataSet.Suite);

end.
