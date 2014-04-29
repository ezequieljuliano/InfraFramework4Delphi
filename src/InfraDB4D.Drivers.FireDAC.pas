(*
  Copyright 2014 Ezequiel Juliano Müller | Microsys Sistemas Ltda

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*)

unit InfraDB4D.Drivers.FireDAC;

interface

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.Generics.Collections,
  InfraDB4D,
  InfraDB4D.Drivers.Base,
  SQLBuilder4D,
  FireDAC.Comp.Client,
  FireDAC.Stan.Option;

type

  TFireDACComponentAdapter = class(TDriverComponent<TFDConnection>);

  TFireDACConnectionAdapter = class;

  TFireDACStatementAdapter = class(TDriverStatement<TFDQuery, TFireDACConnectionAdapter>)
  strict protected
    procedure DoInternalBuild(const pSQL: string; const pAutoCommit: Boolean = False); override;
    function DoInternalBuildAsDataSet(const pSQL: string; const pFetchRows: Integer): TFDQuery; override;
  end;

  TFireDACConnectionAdapter = class(TDriverConnection<TFireDACComponentAdapter, TFireDACStatementAdapter>)
  strict protected
    procedure DoCreateStatement(); override;

    procedure DoConnect(); override;
    procedure DoDisconect(); override;

    function DoInTransaction(): Boolean; override;
    procedure DoStartTransaction(); override;
    procedure DoCommit(); override;
    procedure DoRollback(); override;
  end;

  TFireDACConnectionFactoryAdapter = class(TDriverConnectionFactory<TFireDACConnectionAdapter>)
  strict protected
    function DoGetNewInstance(): TFireDACConnectionAdapter; override;
    function DoGetSingletonInstance(): TFireDACConnectionAdapter; override;
  end;

  TFireDACManagerAdapter = class(TDriverManager<string, TFireDACConnectionAdapter>);

  TFireDACDetailsAdapter = class;

  TFireDACControllerAdapter = class(TDriverController<TFDQuery, TFireDACConnectionAdapter, TFireDACDetailsAdapter>)
  strict protected
    procedure DoCreateDetails(); override;
    procedure DoChangeSQLTextOfDataSet(); override;
    function DoGetSQLTextOfDataSet(): string; override;

    procedure DoOpen(); override;
    procedure DoClose(); override;
  end;

  TFireDACDBControllerClass = class of TFireDACControllerAdapter;

  TFireDACDetailsAdapter = class(TDriverDetails<string, TFireDACControllerAdapter>)
  strict protected
    procedure DoOpenAll(); override;
    procedure DoCloseAll(); override;
    procedure DoDisableAllControls(); override;
    procedure DoEnableAllControls(); override;
  end;

implementation

var
  _vFireDACDBConnection: TFireDACConnectionAdapter = nil;

  { TFireDACStatementAdapter }

procedure TFireDACStatementAdapter.DoInternalBuild(const pSQL: string;
  const pAutoCommit: Boolean);
var
  vDataSet: TFDQuery;
begin
  vDataSet := TFDQuery.Create(nil);
  try
    vDataSet.Connection := GetConnection.GetComponent.GetCompConnection;
    vDataSet.SQL.Add(pSQL);
    if pAutoCommit then
    begin
      try
        GetConnection.StartTransaction;
        vDataSet.Prepare;
        vDataSet.ExecSQL;
        GetConnection.Commit;
      except
        GetConnection.Rollback;
        raise;
      end;
    end
    else
    begin
      vDataSet.Prepare;
      vDataSet.ExecSQL;
    end;
  finally
    vDataSet.Close;
    vDataSet.Connection := nil;
    FreeAndNil(vDataSet);
  end;
end;

function TFireDACStatementAdapter.DoInternalBuildAsDataSet(const pSQL: string;
  const pFetchRows: Integer): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := GetConnection.GetComponent.GetCompConnection;
  if (pFetchRows > 0) then
  begin
    Result.FetchOptions.Mode := fmOnDemand;
    Result.FetchOptions.RowsetSize := pFetchRows;
  end
  else
  begin
    Result.FetchOptions.Mode := fmAll;
    Result.FetchOptions.RowsetSize := -1;
  end;
  Result.SQL.Add(pSQL);
  Result.Prepare;
  Result.Open;
end;

{ TFireDACConnectionAdapter }

procedure TFireDACConnectionAdapter.DoCommit;
begin
  GetComponent.GetCompConnection.Commit();
end;

procedure TFireDACConnectionAdapter.DoConnect;
begin
  GetComponent.GetCompConnection.Open();
end;

procedure TFireDACConnectionAdapter.DoCreateStatement;
begin
  SetStatement(TFireDACStatementAdapter.Create(Self));
end;

procedure TFireDACConnectionAdapter.DoDisconect;
begin
  GetComponent.GetCompConnection.Close();
end;

function TFireDACConnectionAdapter.DoInTransaction: Boolean;
begin
  Result := GetComponent.GetCompConnection.InTransaction;
end;

procedure TFireDACConnectionAdapter.DoRollback;
begin
  GetComponent.GetCompConnection.Rollback();
end;

procedure TFireDACConnectionAdapter.DoStartTransaction;
begin
  GetComponent.GetCompConnection.StartTransaction();
end;

{ TFireDACConnectionFactoryAdapter }

function TFireDACConnectionFactoryAdapter.DoGetNewInstance: TFireDACConnectionAdapter;
begin
  Result := TFireDACConnectionAdapter.Create();
end;

function TFireDACConnectionFactoryAdapter.DoGetSingletonInstance: TFireDACConnectionAdapter;
begin
  if (_vFireDACDBConnection = nil) then
    _vFireDACDBConnection := GetNewInstance();
  Result := _vFireDACDBConnection;
end;

{ TFireDACControllerAdapter }

procedure TFireDACControllerAdapter.DoChangeSQLTextOfDataSet;
begin
  GetDataSet.SQL.Clear;
  GetDataSet.SQL.Add(GetSQLParserSelect.GetSQLText);
end;

procedure TFireDACControllerAdapter.DoClose;
begin
  GetDataSet.Close();
end;

procedure TFireDACControllerAdapter.DoCreateDetails;
begin
  SetDetails(TFireDACDetailsAdapter.Create(Self));
end;

function TFireDACControllerAdapter.DoGetSQLTextOfDataSet: string;
begin
  Result := GetDataSet.SQL.Text;
end;

procedure TFireDACControllerAdapter.DoOpen;
begin
  GetDataSet.Open();
end;

{ TFireDACDetailsAdapter }

procedure TFireDACDetailsAdapter.DoCloseAll;
var
  vPair: TPair<string, TFireDACControllerAdapter>;
begin
  for vPair in GetDetailDictionary do
    vPair.Value.GetDataSet.Close;
end;

procedure TFireDACDetailsAdapter.DoDisableAllControls;
var
  vPair: TPair<string, TFireDACControllerAdapter>;
begin
  for vPair in GetDetailDictionary do
    vPair.Value.GetDataSet.DisableControls();
end;

procedure TFireDACDetailsAdapter.DoEnableAllControls;
var
  vPair: TPair<string, TFireDACControllerAdapter>;
begin
  for vPair in GetDetailDictionary do
    vPair.Value.GetDataSet.EnableControls();
end;

procedure TFireDACDetailsAdapter.DoOpenAll;
var
  vPair: TPair<string, TFireDACControllerAdapter>;
begin
  for vPair in GetDetailDictionary do
    vPair.Value.GetDataSet.Open();
end;

initialization

_vFireDACDBConnection := nil;

finalization

if (_vFireDACDBConnection <> nil) then
  FreeAndNil(_vFireDACDBConnection);

end.
