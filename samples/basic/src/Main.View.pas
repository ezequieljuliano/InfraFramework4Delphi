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

unit Main.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Connection.FireDAC;

type

  TMainView = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainView: TMainView;

implementation

uses
  Country.Model, Country.Controller, Country.View, Province.Model, Province.Controller,
  SQLBuilder4D, Dm.Models;

{$R *.dfm}


procedure TMainView.Button1Click(Sender: TObject);
var
  vCountryView: TCountryView;
  vCountryController: TCountryController;
begin
  vCountryView := TCountryView.Create(nil);
  vCountryController := TCountryController.Create(ConnectionFireDAC.GetDatabase, TCountryModel, 'DataSet');
  try
    vCountryView.DsCountry.DataSet := vCountryController.GetDataSet;
    vCountryController.GetDataSet.Open();
    vCountryView.ShowModal;
  finally
    FreeAndNil(vCountryController);
    FreeAndNil(vCountryView);
  end;
end;

procedure TMainView.Button2Click(Sender: TObject);
var
  vCountryModel: TCountryModel;
  vCountryView: TCountryView;
  vCountryController: TCountryController;
begin
  vCountryModel := TCountryModel.Create(nil);
  vCountryView := TCountryView.Create(nil);
  vCountryController := TCountryController.Create(ConnectionFireDAC.GetDatabase, vCountryModel, vCountryModel.DataSet);
  try
    vCountryView.DsCountry.DataSet := vCountryController.GetDataSet;
    vCountryController.GetDataSet.Open();
    vCountryView.ShowModal;
  finally
    FreeAndNil(vCountryModel);
    FreeAndNil(vCountryView);
    FreeAndNil(vCountryController);
  end;
end;

procedure TMainView.Button3Click(Sender: TObject);
var
  vCountryController: TCountryController;
begin
  vCountryController := TCountryController.Create(ConnectionFireDAC.GetDatabase, TCountryModel, 'DataSet');
  try
    vCountryController.GetDataSet.Open();

    vCountryController.GetDataSet.Insert;
    vCountryController.GetModel<TCountryModel>.DataSetCTY_CODE.AsInteger := Random(10000);
    vCountryController.GetModel<TCountryModel>.DataSetCTY_NAME.AsString := 'Country ' +
      vCountryController.GetModel<TCountryModel>.DataSetCTY_CODE.AsString;
    vCountryController.GetDataSet.Post;

    vCountryController.GetDataSet.Insert;
    vCountryController.GetModel<TCountryModel>.DataSetCTY_CODE.AsInteger := 0;
    vCountryController.GetModel<TCountryModel>.DataSetCTY_NAME.AsString := 'Country 0';
    vCountryController.ValidateFields();
    vCountryController.GetDataSet.Post;
  finally
    FreeAndNil(vCountryController);
  end;
end;

procedure TMainView.Button4Click(Sender: TObject);
var
  vCountryController: TCountryController;
  vProvinceController: TProvinceController;
begin
  vCountryController := TCountryController.Create(ConnectionFireDAC.GetDatabase, TCountryModel, 'DataSet');
  vProvinceController := TProvinceController.Create(ConnectionFireDAC.GetDatabase, TProvinceModel, 'DataSet');
  try
    vProvinceController.GetDataSet.Open();

    vProvinceController.GetDataSet.Insert;
    vProvinceController.GetModel<TProvinceModel>.DataSetPRO_CODE.AsInteger := Random(10000);
    vProvinceController.GetModel<TProvinceModel>.DataSetPRO_NAME.AsString := 'Province ' +
      vProvinceController.GetModel<TProvinceModel>.DataSetPRO_CODE.AsString;

    vCountryController.SQLBuild(TSQLBuilder.Where('CTY_CODE').IsNotNull);
    vProvinceController.GetModel<TProvinceModel>.DataSetCTY_CODE.AsInteger := vCountryController.GetModel<TCountryModel>.DataSetCTY_CODE.AsInteger;

    vProvinceController.GetDataSet.Post;
  finally
    FreeAndNil(vCountryController);
    FreeAndNil(vProvinceController);
  end;
end;

procedure TMainView.Button5Click(Sender: TObject);
var
  vModels: TDmModels;
  vCountryController: TCountryController;
  vProvinceController: TProvinceController;
begin
  // Option 1 - DataSet Object
  vModels := TDmModels.Create(nil);
  vCountryController := TCountryController.Create(ConnectionFireDAC.GetDatabase, vModels, vModels.DtsCountry);
  vProvinceController := TProvinceController.Create(ConnectionFireDAC.GetDatabase, vModels, vModels.DtsProvince);
  try
    vProvinceController.GetDataSet.Open();

    vProvinceController.GetDataSet.Insert;
    vProvinceController.GetDataSet.FieldByName('PRO_CODE').AsInteger := Random(10000);
    vProvinceController.GetDataSet.FieldByName('PRO_NAME').AsString := 'Province ' + vProvinceController.GetDataSet.FieldByName('PRO_CODE').AsString;

    vCountryController.SQLBuild(TSQLBuilder.Where('CTY_CODE').IsNotNull);
    vProvinceController.GetDataSet.FieldByName('CTY_CODE').AsInteger := vCountryController.GetDataSet.FieldByName('CTY_CODE').AsInteger;

    vProvinceController.GetDataSet.Post;
  finally
    FreeAndNil(vModels);
    FreeAndNil(vCountryController);
    FreeAndNil(vProvinceController);
  end;

  // Option 2 - DataSet Name
  vModels := TDmModels.Create(nil);
  vCountryController := TCountryController.Create(ConnectionFireDAC.GetDatabase, vModels, 'DtsCountry');
  vProvinceController := TProvinceController.Create(ConnectionFireDAC.GetDatabase, vModels, 'DtsProvince');
  try
    vProvinceController.GetDataSet.Open();

    vProvinceController.GetDataSet.Insert;
    vProvinceController.GetDataSet.FieldByName('PRO_CODE').AsInteger := Random(10000);
    vProvinceController.GetDataSet.FieldByName('PRO_NAME').AsString := 'Province ' + vProvinceController.GetDataSet.FieldByName('PRO_CODE').AsString;

    vCountryController.SQLBuild(TSQLBuilder.Where('CTY_CODE').IsNotNull);
    vProvinceController.GetDataSet.FieldByName('CTY_CODE').AsInteger := vCountryController.GetDataSet.FieldByName('CTY_CODE').AsInteger;

    vProvinceController.GetDataSet.Post;
  finally
    FreeAndNil(vModels);
    FreeAndNil(vCountryController);
    FreeAndNil(vProvinceController);
  end;
end;

procedure TMainView.Button6Click(Sender: TObject);
var
  vCountryModel: TCountryModel;
  vCountryView: TCountryView;
  vCountryController: TCountryController;
begin
  vCountryModel := TCountryModel.Create(nil);
  vCountryView := TCountryView.Create(nil);
  vCountryController := TCountryController.Create(ConnectionFireDAC.GetDatabase, vCountryModel, 'DataSet');
  try
    vCountryView.DsCountry.DataSet := vCountryController.GetDataSet;
    vCountryController.GetDataSet.Open();
    vCountryView.ShowModal;
  finally
    FreeAndNil(vCountryModel);
    FreeAndNil(vCountryView);
    FreeAndNil(vCountryController);
  end;
end;

end.
