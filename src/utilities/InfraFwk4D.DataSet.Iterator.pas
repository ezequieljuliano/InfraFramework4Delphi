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

  IDataSetIterator<T: TDataSet> = interface
    ['{115C591E-A73C-4DE8-AB3D-7586DD3D0A75}']
    procedure First;
    procedure ForEach(const action: TProc); overload;
    procedure ForEach(const action: TProc<IDataSetIterator<T>>); overload;
    procedure ForEach(const action: TProc<T>); overload;
    function HasNext: Boolean;
    function IsEmpty: Boolean;
    function Fields: TFields;
    function FieldByName(const name: string): TField;
    function GetDataSet: T;
  end;

  TDataSetIterator<T: TDataSet> = class(TInterfacedObject, IDataSetIterator<T>)
  private
    fDataSet: T;
    FOwns: Boolean;
  protected
    procedure First;
    procedure ForEach(const action: TProc); overload;
    procedure ForEach(const action: TProc<IDataSetIterator<T>>); overload;
    procedure ForEach(const action: TProc<T>); overload;
    function HasNext: Boolean;
    function IsEmpty: Boolean;
    function Fields: TFields;
    function FieldByName(const name: string): TField;
    function GetDataSet: T;
  public
    constructor Create(const dataSet: T); overload;
    constructor Create(const dataSet: T; const ownsDataSet: Boolean); overload;
    destructor Destroy; override;
  end;

implementation

{ TDataSetIterator<T> }

constructor TDataSetIterator<T>.Create(const dataSet: T);
begin
  Create(dataSet, True);
end;

constructor TDataSetIterator<T>.Create(const dataSet: T; const ownsDataSet: Boolean);
begin
  inherited Create;
  fDataSet := dataSet;
  FOwns := ownsDataSet;

  if not Assigned(fDataSet) then
    raise EDataSetIteratorException.CreateFmt('Source DataSet %s is nil in the Iterator!', [dataSet.Name]);

  if not fDataSet.Active then
    raise EDataSetIteratorException.CreateFmt('Source DataSet %s does not have is open in the Iterator!', [dataSet.Name]);

  First;
end;

destructor TDataSetIterator<T>.Destroy;
begin
  if (FOwns) and Assigned(fDataSet) then
    fDataSet.Free;
  inherited Destroy;
end;

function TDataSetIterator<T>.FieldByName(const name: string): TField;
begin
  Result := fDataSet.FieldByName(name);
end;

function TDataSetIterator<T>.Fields: TFields;
begin
  Result := fDataSet.Fields;
end;

procedure TDataSetIterator<T>.First;
begin
  fDataSet.First;
end;

procedure TDataSetIterator<T>.ForEach(const action: TProc<T>);
begin
  while HasNext do
    action(GetDataSet);
end;

procedure TDataSetIterator<T>.ForEach(const action: TProc<IDataSetIterator<T>>);
begin
  while HasNext do
    action(Self);
end;

procedure TDataSetIterator<T>.ForEach(const action: TProc);
begin
  while HasNext do
    action();
end;

function TDataSetIterator<T>.GetDataSet: T;
begin
  Result := fDataSet;
end;

function TDataSetIterator<T>.HasNext: Boolean;
begin
  Result := not fDataSet.Eof;
  if Result then
    fDataSet.Next;
end;

function TDataSetIterator<T>.IsEmpty: Boolean;
begin
  Result := fDataSet.IsEmpty;
end;

end.
