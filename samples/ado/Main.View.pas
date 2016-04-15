unit Main.View;

interface

uses
  User.BC, User.DAO, Database.ADO,

  {$IFDEF VER210}

  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, ADODB, DB, Grids, DBGrids,
  ExtCtrls, DBCtrls, StdCtrls;

  {$ELSE}

  Forms, Data.DB, Vcl.StdCtrls, Vcl.Controls, Vcl.ExtCtrls, Vcl.DBCtrls,
  System.Classes, Vcl.Grids, Vcl.DBGrids,
  Data.Win.ADODB;

  {$ENDIF}

type
  TForm3 = class(TForm)
    dsUser: TDataSource;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    Panel1: TPanel;
    Edit1: TEdit;
    Button1: TButton;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FUserBC: TUserBC;
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.Button1Click(Sender: TObject);
begin
  FUserBC.FindByLogin(Edit1.Text);
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  FUserBC := TUserBC.Create;
  dsUser.DataSet := FUserBC.Persistence.DtsUser;
  FUserBC.Persistence.DtsUser.Open();
end;

end.
