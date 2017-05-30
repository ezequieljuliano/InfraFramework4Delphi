unit InfraFwk4D.UnitTest.DataSet.Events;

interface

uses
  TestFramework,
  System.SysUtils,
  Data.DB,
  Datasnap.DBClient,
  InfraFwk4D.DataSet.Events;

type

  TTestInfraFwkDataSetEvents = class(TTestCase)
  private
    fDataSet: TClientDataSet;
    fDataSetEvents: IDataSetEvents;
    fEventName: string;
    procedure InternalBeforeOpen(dataSet: TDataSet);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestBeforeOpenEvent;
    procedure TestAfterOpenEvent;
    procedure TestBeforeCloseEvent;
    procedure TestAfterCloseEvent;
    procedure TestBeforeInsertEvent;
    procedure TestAfterInsertEvent;
    procedure TestBeforeEditEvent;
    procedure TestAfterEditEvent;
    procedure TestBeforePostEvent;
    procedure TestAfterPostEvent;
    procedure TestBeforeCancelEvent;
    procedure TestAfterCancelEvent;
    procedure TestBeforeDeleteEvent;
    procedure TestAfterDeleteEvent;
    procedure TestBeforeRefreshEvent;
    procedure TestAfterRefreshEvent;
    procedure TestBeforeScrollEvent;
    procedure TestAfterScrollEvent;
    procedure TestOnNewRecordEvent;
    procedure TestOnCalcFieldsEvent;
    procedure TestOnEditErrorEvent;
    procedure TestOnPostErrorEvent;
    procedure TestOnDeleteErrorEvent;
  end;

implementation

{ TTestInfraFwkDataSetEvents }

procedure TTestInfraFwkDataSetEvents.InternalBeforeOpen(dataSet: TDataSet);
begin
  fEventName := 'InternalBeforeOpen';
end;

procedure TTestInfraFwkDataSetEvents.SetUp;
begin
  inherited;
  fDataSet := TClientDataSet.Create(nil);
  fDataSet.FieldDefs.Add('Name', ftInteger);
  fDataSet.CreateDataSet;
  fDataSetEvents := TDataSetEvents.Create(fDataSet);
  fEventName := '';
end;

procedure TTestInfraFwkDataSetEvents.TearDown;
begin
  inherited;
  fDataSet.Free;
end;

procedure TTestInfraFwkDataSetEvents.TestAfterCancelEvent;
begin
  fDataSetEvents.AfterCancel.Add('AfterCancel',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'AfterCancel'
    end);
  CheckTrue(fDataSetEvents.AfterCancel.Count = 1);
  fDataSetEvents.AfterCancel.Execute(fDataSet);
  CheckEquals('AfterCancel', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestAfterCloseEvent;
begin
  fDataSetEvents.AfterClose.Add('AfterClose',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'AfterClose'
    end);
  CheckTrue(fDataSetEvents.AfterClose.Count = 1);
  fDataSetEvents.AfterClose.Execute(fDataSet);
  CheckEquals('AfterClose', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestAfterDeleteEvent;
begin
  fDataSetEvents.AfterDelete.Add('AfterDelete',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'AfterDelete'
    end);
  CheckTrue(fDataSetEvents.AfterDelete.Count = 1);
  fDataSetEvents.AfterDelete.Execute(fDataSet);
  CheckEquals('AfterDelete', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestAfterEditEvent;
begin
  fDataSetEvents.AfterEdit.Add('AfterEdit',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'AfterEdit'
    end);
  CheckTrue(fDataSetEvents.AfterEdit.Count = 1);
  fDataSetEvents.AfterEdit.Execute(fDataSet);
  CheckEquals('AfterEdit', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestAfterInsertEvent;
begin
  fDataSetEvents.AfterInsert.Add('AfterInsert',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'AfterInsert'
    end);
  CheckTrue(fDataSetEvents.AfterInsert.Count = 1);
  fDataSetEvents.AfterInsert.Execute(fDataSet);
  CheckEquals('AfterInsert', fEventName);

  fEventName := '';
  fDataSet.Insert;
  CheckEquals('AfterInsert', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestAfterOpenEvent;
begin
  fDataSetEvents.AfterOpen.Add('AfterOpen',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'AfterOpen'
    end);
  CheckTrue(fDataSetEvents.AfterOpen.Count = 1);
  fDataSetEvents.AfterOpen.Execute(fDataSet);
  CheckEquals('AfterOpen', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestAfterPostEvent;
begin
  fDataSetEvents.AfterPost.Add('AfterPost',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'AfterPost'
    end);
  CheckTrue(fDataSetEvents.AfterPost.Count = 1);
  fDataSetEvents.AfterPost.Execute(fDataSet);
  CheckEquals('AfterPost', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestAfterRefreshEvent;
begin
  fDataSetEvents.AfterRefresh.Add('AfterRefresh',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'AfterRefresh'
    end);
  CheckTrue(fDataSetEvents.AfterRefresh.Count = 1);
  fDataSetEvents.AfterRefresh.Execute(fDataSet);
  CheckEquals('AfterRefresh', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestAfterScrollEvent;
begin
  fDataSetEvents.AfterScroll.Add('AfterScroll',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'AfterScroll'
    end);
  CheckTrue(fDataSetEvents.AfterScroll.Count = 1);
  fDataSetEvents.AfterScroll.Execute(fDataSet);
  CheckEquals('AfterScroll', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestBeforeCancelEvent;
begin
  fDataSetEvents.BeforeCancel.Add('BeforeCancel',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'BeforeCancel'
    end);
  CheckTrue(fDataSetEvents.BeforeCancel.Count = 1);
  fDataSetEvents.BeforeCancel.Execute(fDataSet);
  CheckEquals('BeforeCancel', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestBeforeCloseEvent;
begin
  fDataSetEvents.BeforeClose.Add('BeforeClose',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'BeforeClose'
    end);
  CheckTrue(fDataSetEvents.BeforeClose.Count = 1);
  fDataSetEvents.BeforeClose.Execute(fDataSet);
  CheckEquals('BeforeClose', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestBeforeDeleteEvent;
begin
  fDataSetEvents.BeforeDelete.Add('BeforeDelete',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'BeforeDelete'
    end);
  CheckTrue(fDataSetEvents.BeforeDelete.Count = 1);
  fDataSetEvents.BeforeDelete.Execute(fDataSet);
  CheckEquals('BeforeDelete', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestBeforeEditEvent;
begin
  fDataSetEvents.BeforeEdit.Add('BeforeEdit',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'BeforeEdit'
    end);
  CheckTrue(fDataSetEvents.BeforeEdit.Count = 1);
  fDataSetEvents.BeforeEdit.Execute(fDataSet);
  CheckEquals('BeforeEdit', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestBeforeInsertEvent;
begin
  fDataSetEvents.BeforeInsert.Add('BeforeInsert',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'BeforeInsert'
    end);
  CheckTrue(fDataSetEvents.BeforeInsert.Count = 1);
  fDataSetEvents.BeforeInsert.Execute(fDataSet);
  CheckEquals('BeforeInsert', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestBeforeOpenEvent;
begin
  fDataSetEvents.BeforeOpen.Add('BeforeOpen',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'BeforeOpen'
    end);
  CheckTrue(fDataSetEvents.BeforeOpen.Count = 1);
  fDataSetEvents.BeforeOpen.Execute(fDataSet);
  CheckEquals('BeforeOpen', fEventName);

  fDataSetEvents.BeforeOpen.Clear;
  fDataSetEvents.BeforeOpen.Add('InternalBeforeOpen', InternalBeforeOpen);
  CheckTrue(fDataSetEvents.BeforeOpen.Count = 1);
  fDataSetEvents.BeforeOpen.Execute(fDataSet);
  CheckEquals('InternalBeforeOpen', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestBeforePostEvent;
begin
  fDataSetEvents.BeforePost.Add('BeforePost',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'BeforePost'
    end);
  CheckTrue(fDataSetEvents.BeforePost.Count = 1);
  fDataSetEvents.BeforePost.Execute(fDataSet);
  CheckEquals('BeforePost', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestBeforeRefreshEvent;
begin
  fDataSetEvents.BeforeRefresh.Add('BeforeRefresh',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'BeforeRefresh'
    end);
  CheckTrue(fDataSetEvents.BeforeRefresh.Count = 1);
  fDataSetEvents.BeforeRefresh.Execute(fDataSet);
  CheckEquals('BeforeRefresh', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestBeforeScrollEvent;
begin
  fDataSetEvents.BeforeScroll.Add('BeforeScroll',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'BeforeScroll'
    end);
  CheckTrue(fDataSetEvents.BeforeScroll.Count = 1);
  fDataSetEvents.BeforeScroll.Execute(fDataSet);
  CheckEquals('BeforeScroll', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestOnCalcFieldsEvent;
begin
  fDataSetEvents.OnCalcFields.Add('OnCalcFields',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'OnCalcFields'
    end);
  CheckTrue(fDataSetEvents.OnCalcFields.Count = 1);
  fDataSetEvents.OnCalcFields.Execute(fDataSet);
  CheckEquals('OnCalcFields', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestOnDeleteErrorEvent;
var
  act: TDataAction;
begin
  fDataSetEvents.OnDeleteError.Add('OnDeleteError',
    procedure(dataSet: TDataSet; e: EDatabaseError; var action: TDataAction)
    begin
      fEventName := 'OnDeleteError'
    end);
  CheckTrue(fDataSetEvents.OnDeleteError.Count = 1);
  fDataSetEvents.OnDeleteError.Execute(fDataSet, nil, act);
  CheckEquals('OnDeleteError', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestOnEditErrorEvent;
var
  act: TDataAction;
begin
  fDataSetEvents.OnEditError.Add('OnEditError',
    procedure(dataSet: TDataSet; e: EDatabaseError; var action: TDataAction)
    begin
      fEventName := 'OnEditError'
    end);
  CheckTrue(fDataSetEvents.OnEditError.Count = 1);
  fDataSetEvents.OnEditError.Execute(fDataSet, nil, act);
  CheckEquals('OnEditError', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestOnNewRecordEvent;
begin
  fDataSetEvents.OnNewRecord.Add('OnNewRecord',
    procedure(dataSet: TDataSet)
    begin
      fEventName := 'OnNewRecord'
    end);
  CheckTrue(fDataSetEvents.OnNewRecord.Count = 1);
  fDataSetEvents.OnNewRecord.Execute(fDataSet);
  CheckEquals('OnNewRecord', fEventName);
end;

procedure TTestInfraFwkDataSetEvents.TestOnPostErrorEvent;
var
  act: TDataAction;
begin
  fDataSetEvents.OnPostError.Add('OnPostError',
    procedure(dataSet: TDataSet; e: EDatabaseError; var action: TDataAction)
    begin
      fEventName := 'OnPostError'
    end);
  CheckTrue(fDataSetEvents.OnPostError.Count = 1);
  fDataSetEvents.OnPostError.Execute(fDataSet, nil, act);
  CheckEquals('OnPostError', fEventName);
end;

initialization

RegisterTest(TTestInfraFwkDataSetEvents.Suite);

end.
