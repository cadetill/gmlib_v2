unit UMarkerFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls,

  GMLib.Map.Vcl;

type
  TFrame1 = class(TFrame)
    pcPages: TPageControl;
    tsGeneral: TTabSheet;
    cbActive: TCheckBox;
    pAPIKey: TPanel;
    lNeedAPI: TLabel;
    lAPIKey: TLabel;
    eAPIKey: TEdit;
    cbAutoUpdate: TCheckBox;
    procedure eAPIKeyChange(Sender: TObject);
  private
    FGMMap: TGMMap;
    procedure SetGMMap(const Value: TGMMap);
  protected
    procedure SetPropToComponents;
  public
    constructor Create(AOwner: TComponent); override;

    property GMMap: TGMMap read FGMMap write SetGMMap;
  end;

  // because GMMap property (from the frame) is an object from TGMMap class and this class has
  //  all properties protected, I need to define this class to do public all properties
  TGMPublic = class(TGMMap);

implementation

{$R *.dfm}

{ TFrame1 }

constructor TFrame1.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TFrame1.eAPIKeyChange(Sender: TObject);
begin
  TGMPublic(GMMap).APIKey := eAPIKey.Text;
end;

procedure TFrame1.SetGMMap(const Value: TGMMap);
begin
  if FGMMap = Value then
    Exit;

  FGMMap := Value;

  SetPropToComponents;
end;

procedure TFrame1.SetPropToComponents;
begin
  eAPIKey.Text := TGMPublic(GMMap).APIKey;
  cbActive.Checked := TGMPublic(GMMap).Active;

  cbAutoUpdate.Checked := TGMPublic(GMMap).Markers.AutoUpdate;
end;

end.
