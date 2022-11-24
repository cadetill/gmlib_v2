unit UMarkerFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls,

  GMLib.Map.Vcl;

type
  TMarkerFrame = class(TFrame)
    pcPages: TPageControl;
    tsGeneral: TTabSheet;
    cbActive: TCheckBox;
    pAPIKey: TPanel;
    lNeedAPI: TLabel;
    lAPIKey: TLabel;
    eAPIKey: TEdit;
    cbAutoUpdate: TCheckBox;
    tsMarkers: TTabSheet;
    lMarkersList: TLabel;
    lbMarkersList: TListBox;
    bAdd: TButton;
    bDel: TButton;
    procedure eAPIKeyChange(Sender: TObject);
    procedure cbActiveClick(Sender: TObject);
    procedure bAddClick(Sender: TObject);
  private
    FGMMap: TGMMap;
    procedure SetGMMap(const Value: TGMMap);
  protected
    procedure SetPropToComponents;
    procedure LoadMarkers;
  public
    constructor Create(AOwner: TComponent); override;

    property GMMap: TGMMap read FGMMap write SetGMMap;
  end;

  // because GMMap property (from the frame) is an object from TGMMap class and this class has
  //  all properties protected, I need to define this class to do public all properties
  TGMPublic = class(TGMMap);

implementation

uses
  GMLib.Marker.Vcl;

{$R *.dfm}

{ TFrame1 }

procedure TMarkerFrame.bAddClick(Sender: TObject);
var
  Marker: TGMMarker;
begin
  Marker := TGMPublic(GMMap).Markers.Markers.Add;
  Marker.Title := 'New';
  Marker.Name := Marker.GetNamePath;
  LoadMarkers;
end;

procedure TMarkerFrame.cbActiveClick(Sender: TObject);
begin
  TGMPublic(GMMap).Active := cbActive.Checked;
end;

constructor TMarkerFrame.Create(AOwner: TComponent);
begin
  inherited;

  pcPages.ActivePage := tsGeneral;
end;

procedure TMarkerFrame.eAPIKeyChange(Sender: TObject);
begin
  TGMPublic(GMMap).APIKey := eAPIKey.Text;
end;

procedure TMarkerFrame.LoadMarkers;
var
  i: Integer;
begin
  lbMarkersList.Clear;
  for i := 0 to TGMPublic(GMMap).Markers.Markers.Count - 1 do
    lbMarkersList.AddItem(TGMPublic(GMMap).Markers.Markers[i].Name, TGMPublic(GMMap).Markers.Markers[i]);
end;

procedure TMarkerFrame.SetGMMap(const Value: TGMMap);
begin
  if FGMMap = Value then
    Exit;

  FGMMap := Value;

  SetPropToComponents;
end;

procedure TMarkerFrame.SetPropToComponents;
begin
  eAPIKey.Text := TGMPublic(GMMap).APIKey;
  cbActive.Checked := TGMPublic(GMMap).Active;

  cbAutoUpdate.Checked := TGMPublic(GMMap).Markers.AutoUpdate;

  LoadMarkers;
end;

end.
