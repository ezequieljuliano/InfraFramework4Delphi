unit InfraFwk4D.DataSet.Iterator;

interface

uses
  System.SysUtils,
  Data.DB;

type

  EDataSetIteratorException = class(Exception)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  end;

  IDataSetIterator = interface
    ['{115C591E-A73C-4DE8-AB3D-7586DD3D0A75}']
    procedure First;
    procedure ForEach(const action: TProc); overload;
    procedure ForEach(const action: TProc<IDataSetIterator>); overload;
    function HasNext: Boolean;
    function IsEmpty: Boolean;
    function Fields: TFields;
    function FieldByName(const name: string): TField;
    function GetDataSet: TDataSet;
  end;

  TDataSetIterator = class(TInterfacedObject, IDataSetIterator)
  private
    fDataSet: TDataSet;
    fIndex: Integer;
    fOwns: Boolean;
  protected
    procedure First;
    procedure ForEach(const action: TProc); overload;
    procedure ForEach(const action: TProc<IDataSetIterator>); overload;
    function HasNext: Boolean;
    function IsEmpty: Boolean;
    function Fields: TFields;
    function FieldByName(const name: string): TField;
    function GetDataSet: TDataSet;
  public
    constructor Create(const dataSet: TDataSet); overload;
    constructor Create(const dataSet: TDataSet; const ownsDataSet: Boolean); overload;
    destructor Destroy; override;
  end;

implementation

{ TDataSetIterator }

constructor TDataSetIterator.Create(const dataSet: TDataSet);
begin
  Create(dataSet, True);
end;

constructor TDataSetIterator.Create(const dataSet: TDataSet; const ownsDataSet: Boolean);
begin
  inherited Create;
  fDataSet := dataSet;
  fOwns := ownsDataSet;
  fIndex := 0;

  if not Assigned(fDataSet) then
    raise EDataSetIteratorException.CreateFmt('Source DataSet %s is nil in the Iterator!', [dataSet.Name]);

  if not fDataSet.Active then
    raise EDataSetIteratorException.CreateFmt('Source DataSet %s does not have is open in the Iterator!', [dataSet.Name]);

  First;
end;

destructor TDataSetIterator.Destroy;
begin
  if (fOwns) and Assigned(fDataSet) then
    fDataSet.Free;
  inherited Destroy;
end;

function TDataSetIterator.FieldByName(const name: string): TField;
begin
  Result := fDataSet.FieldByName(name);
end;

function TDataSetIterator.Fields: TFields;
begin
  Result := fDataSet.Fields;
end;

procedure TDataSetIterator.First;
begin
  fDataSet.First;
end;

procedure TDataSetIterator.ForEach(const action: TProc<IDataSetIterator>);
begin
  while HasNext do
    action(Self);
end;

procedure TDataSetIterator.ForEach(const action: TProc);
begin
  while HasNext do
    action();
end;

function TDataSetIterator.GetDataSet: TDataSet;
begin
  Result := fDataSet;
end;

function TDataSetIterator.HasNext: Boolean;
begin
  Inc(fIndex);

  if (fIndex > 1) then
    FDataSet.Next;

  Result := not fDataSet.Eof;
end;

function TDataSetIterator.IsEmpty: Boolean;
begin
  Result := fDataSet.IsEmpty;
end;

end.
