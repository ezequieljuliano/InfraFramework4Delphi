unit Main.View;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, ADODB, DB, User.DAO, Database.ADO, Grids, DBGrids,
  ExtCtrls, DBCtrls, StdCtrls, User.BC;

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
    { Private declarations }
  public
    { Public declarations }
    FDatabaseADO: TDatabaseADO;
    FUserBC: TUserBC;
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
  FDatabaseADO := TDatabaseADO.Create(nil);

  FUserBC := TUserBC.Create(TUserDAO);
  dsUser.DataSet := FUserBC.Persistence.DtsUser;
  FUserBC.Persistence.DtsUser.Open();
end;

end.


uses User.BC;
