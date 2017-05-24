unit InfraFwk4D.UnitTest.DataSet.Iterator;

interface

uses
  TestFramework,
  System.SysUtils,
  Data.DB,
  Datasnap.DBClient,
  InfraFwk4D.DataSet.Iterator;

type

  TTestInfraFwkDataSetIterator = class(TTestCase)
  private
    function CreateDataSet: TClientDataSet;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestIteratorDataSet;
    procedure TestIteratorOwnsDataSet;
    procedure TestIteratorDataSetLoop;
  end;

implementation

{ TTestInfraFwkDataSetIterator }

function TTestInfraFwkDataSetIterator.CreateDataSet: TClientDataSet;
begin
  Result := TClientDataSet.Create(nil);
  Result.FieldDefs.Add('One', ftInteger);
  Result.FieldDefs.Add('Two', ftInteger);
  Result.FieldDefs.Add('Three', ftInteger);
  Result.CreateDataSet;
end;

procedure TTestInfraFwkDataSetIterator.SetUp;
begin
  inherited;
end;

procedure TTestInfraFwkDataSetIterator.TearDown;
begin
  inherited;
end;

procedure TTestInfraFwkDataSetIterator.TestIteratorDataSet;
var
  ds: TClientDataSet;
  it: IDataSetIterator;
begin
  ds := CreateDataSet;
  try
    it := TDataSetIterator.Create(ds, False);
    CheckTrue(it.GetDataSet <> nil);
    CheckTrue(it.IsEmpty);
    CheckFalse(it.HasNext);
    CheckTrue(it.FieldByName('One') <> nil);
    CheckTrue(it.Fields <> nil);
  finally
    ds.Free;
  end;
end;

procedure TTestInfraFwkDataSetIterator.TestIteratorOwnsDataSet;
var
  it: IDataSetIterator;
begin
  it := TDataSetIterator.Create(CreateDataSet);
  CheckTrue(it.GetDataSet <> nil);
  CheckTrue(it.IsEmpty);
  CheckFalse(it.HasNext);
  CheckTrue(it.FieldByName('One') <> nil);
  CheckTrue(it.Fields <> nil);
end;

procedure TTestInfraFwkDataSetIterator.TestIteratorDataSetLoop;
var
  ds: TClientDataSet;
  it: IDataSetIterator;

  procedure AddValue(const city, state: string; const position: Integer);
  begin
    ds.Insert;
    ds.FieldByName('City').AsString := city;
    ds.FieldByName('State').AsString := state;
    ds.FieldByName('Position').AsInteger := position;
    ds.Post;
  end;

begin
  ds := TClientDataSet.Create(nil);
  ds.FieldDefs.Add('City', ftString, 20);
  ds.FieldDefs.Add('State', ftString, 2);
  ds.FieldDefs.Add('Position', ftInteger);
  ds.CreateDataSet;

  AddValue('São Paulo', 'SP', 1);
  AddValue('Maravilha', 'SC', 2);
  AddValue('Florianópolis', 'SC', 3);
  AddValue('Rio de Janeiro', 'RJ', 4);

  ds.IndexFieldNames := 'City';

  it := TDataSetIterator.Create(ds, True);
  CheckFalse(it.IsEmpty);

  while it.HasNext do
  begin
    if (it.FieldByName('Position').AsInteger = 1) then
    begin
      CheckEquals('São Paulo', it.FieldByName('City').AsString);
      CheckEquals('SP', it.FieldByName('State').AsString);
      CheckEquals(1, it.FieldByName('Position').AsInteger);
    end;
    if (it.FieldByName('Position').AsInteger = 2) then
    begin
      CheckEquals('Maravilha', it.FieldByName('City').AsString);
      CheckEquals('SC', it.FieldByName('State').AsString);
      CheckEquals(2, it.FieldByName('Position').AsInteger);
    end;
    if (it.FieldByName('Position').AsInteger = 3) then
    begin
      CheckEquals('Florianópolis', it.FieldByName('City').AsString);
      CheckEquals('SC', it.FieldByName('State').AsString);
      CheckEquals(3, it.FieldByName('Position').AsInteger);
    end;
    if (it.FieldByName('Position').AsInteger = 4) then
    begin
      CheckEquals('Rio de Janeiro', it.FieldByName('City').AsString);
      CheckEquals('RJ', it.FieldByName('State').AsString);
      CheckEquals(4, it.FieldByName('Position').AsInteger);
    end;
  end;

  it.First;
  it.ForEach(
    procedure
    begin
      if (it.FieldByName('Position').AsInteger = 1) then
      begin
        CheckEquals('São Paulo', it.FieldByName('City').AsString);
        CheckEquals('SP', it.FieldByName('State').AsString);
        CheckEquals(1, it.FieldByName('Position').AsInteger);
      end;
      if (it.FieldByName('Position').AsInteger = 2) then
      begin
        CheckEquals('Maravilha', it.FieldByName('City').AsString);
        CheckEquals('SC', it.FieldByName('State').AsString);
        CheckEquals(2, it.FieldByName('Position').AsInteger);
      end;
      if (it.FieldByName('Position').AsInteger = 3) then
      begin
        CheckEquals('Florianópolis', it.FieldByName('City').AsString);
        CheckEquals('SC', it.FieldByName('State').AsString);
        CheckEquals(3, it.FieldByName('Position').AsInteger);
      end;
      if (it.FieldByName('Position').AsInteger = 4) then
      begin
        CheckEquals('Rio de Janeiro', it.FieldByName('City').AsString);
        CheckEquals('RJ', it.FieldByName('State').AsString);
        CheckEquals(4, it.FieldByName('Position').AsInteger);
      end;
    end
    );

  it.First;
  it.ForEach(
    procedure(currentIterator: IDataSetIterator)
    begin
      if (currentIterator.FieldByName('Position').AsInteger = 1) then
      begin
        CheckEquals('São Paulo', currentIterator.FieldByName('City').AsString);
        CheckEquals('SP', currentIterator.FieldByName('State').AsString);
        CheckEquals(1, currentIterator.FieldByName('Position').AsInteger);
      end;
      if (currentIterator.FieldByName('Position').AsInteger = 2) then
      begin
        CheckEquals('Maravilha', currentIterator.FieldByName('City').AsString);
        CheckEquals('SC', currentIterator.FieldByName('State').AsString);
        CheckEquals(2, currentIterator.FieldByName('Position').AsInteger);
      end;
      if (currentIterator.FieldByName('Position').AsInteger = 3) then
      begin
        CheckEquals('Florianópolis', currentIterator.FieldByName('City').AsString);
        CheckEquals('SC', currentIterator.FieldByName('State').AsString);
        CheckEquals(3, currentIterator.FieldByName('Position').AsInteger);
      end;
      if (currentIterator.FieldByName('Position').AsInteger = 4) then
      begin
        CheckEquals('Rio de Janeiro', currentIterator.FieldByName('City').AsString);
        CheckEquals('RJ', currentIterator.FieldByName('State').AsString);
        CheckEquals(4, currentIterator.FieldByName('Position').AsInteger);
      end;
    end
    );
end;

initialization

RegisterTest(TTestInfraFwkDataSetIterator.Suite);

end.
