unit Main.View;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, ADODB, DB, User.DAO, Database.ADO, Grids, DBGrids,
  ExtCtrls, DBCtrls, StdCtrls;

type
  TForm3 = class(TForm)
    DataSource1: TDataSource;
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
    FUSERDAO: TDmUserDAO;
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.Button1Click(Sender: TObject);
begin
  FUSERDAO.FindByLogin(Edit1.Text);
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  FDatabaseADO := TDatabaseADO.Create(nil);
  FUSERDAO := TDmUserDAO.Create(nil);
end;

end.
