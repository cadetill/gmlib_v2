unit UMarkerFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls,

  GMLib.Map.Vcl;

type
  TMakerFrame = class(TFrame)
    pcPages: TPageControl;
    tsGeneral: TTabSheet;
    cbActive: TCheckBox;
    pAPIKey: TPanel;
    lNeedAPI: TLabel;
    lAPIKey: TLabel;
    eAPIKey: TEdit;
    cbAutoUpdate: TCheckBox;
    tsMakers: TTabSheet;
    lList: TLabel;
    lbMarkers: TListBox;
    procedure eAPIKeyChange(Sender: TObject);
    procedure cbActiveClick(Sender: TObject);
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

procedure TMakerFrame.cbActiveClick(Sender: TObject);
begin
  TGMPublic(GMMap).Active := cbActive.Checked;
end;

constructor TMakerFrame.Create(AOwner: TComponent);
begin
  inherited;

  pcPages.ActivePage := tsGeneral;
end;

procedure TMakerFrame.eAPIKeyChange(Sender: TObject);
begin
  TGMPublic(GMMap).APIKey := eAPIKey.Text;
end;

procedure TMakerFrame.SetGMMap(const Value: TGMMap);
begin
  if FGMMap = Value then
    Exit;

  FGMMap := Value;

  SetPropToComponents;
end;

procedure TMakerFrame.SetPropToComponents;
var
  i: Integer;
begin
  eAPIKey.Text := TGMPublic(GMMap).APIKey;
  cbActive.Checked := TGMPublic(GMMap).Active;

  cbAutoUpdate.Checked := TGMPublic(GMMap).Markers.AutoUpdate;

  lbMarkers.Clear;
  for i := 0 to TGMPublic(GMMap).Markers.Markers.Count - 1 do
    lbMarkers.Items.AddObject(TGMPublic(GMMap).Markers.Markers[i].ZIndex.ToString + '-' + TGMPublic(GMMap).Markers.Markers[i].Name, TGMPublic(GMMap).Markers.Markers[i]);
end;

end.
