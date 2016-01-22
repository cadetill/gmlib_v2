unit UMainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, GMClasses, GMMap,
  GMMap.VCL;

type
  TMainFrm = class(TForm)
    Button1: TButton;
    GMMap1: TGMMap;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainFrm: TMainFrm;

implementation

uses
  GMSets;

{$R *.dfm}

procedure TMainFrm.Button1Click(Sender: TObject);
var
  Obj: TGMMapTypeStyle;
begin
  Obj := GMMap1.MapOptions.Styles.Add;
  Obj.Name := 'lolo';
  Obj.ElementType := setALL;
end;

end.
