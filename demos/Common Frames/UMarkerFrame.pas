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
    tsMarker: TTabSheet;
    lAnimation: TLabel;
    cbAnimation: TComboBox;
    cbClickable: TCheckBox;
    cbCollisionBehavior: TComboBox;
    lCollisionBehavior: TLabel;
    cbCrossOnDrag: TCheckBox;
    cbDraggable: TCheckBox;
    lIconUrl: TLabel;
    eIconUrl: TEdit;
    eLabelText: TEdit;
    lLabelText: TLabel;
    gbPosition: TGroupBox;
    lRNELat: TLabel;
    lRNELng: TLabel;
    eLat: TEdit;
    eLng: TEdit;
    cbVisible: TCheckBox;
    procedure eAPIKeyChange(Sender: TObject);
    procedure cbActiveClick(Sender: TObject);
    procedure bAddClick(Sender: TObject);
    procedure bDelClick(Sender: TObject);
    procedure lbMarkersListClick(Sender: TObject);
    procedure cbAnimationChange(Sender: TObject);
    procedure cbClickableClick(Sender: TObject);
    procedure cbCollisionBehaviorChange(Sender: TObject);
    procedure cbCrossOnDragClick(Sender: TObject);
    procedure cbDraggableClick(Sender: TObject);
    procedure eIconUrlChange(Sender: TObject);
    procedure eLabelTextChange(Sender: TObject);
    procedure eLatChange(Sender: TObject);
    procedure eLngChange(Sender: TObject);
    procedure cbVisibleClick(Sender: TObject);
  private
    FGMMap: TGMMap;
    procedure SetGMMap(const Value: TGMMap);
  protected
    procedure SetPropToComponents;
    procedure LoadMarkers;

    procedure GetInfoMarker;
    procedure GetAnimation;
    procedure GetCollisionBehavior;
  public
    constructor Create(AOwner: TComponent); override;

    property GMMap: TGMMap read FGMMap write SetGMMap;
  end;

  // because GMMap property (from the frame) is an object from TGMMap class and this class has
  //  all properties protected, I need to define this class to do public all properties
  TGMPublic = class(TGMMap);

implementation

uses
  GMLib.Marker.Vcl, GMLib.Sets, GMLib.Transform.Vcl;

{$R *.dfm}

{ TFrame1 }

procedure TMarkerFrame.bAddClick(Sender: TObject);
var
  Marker: TGMMarker;
begin
  Marker := TGMPublic(GMMap).Markers.Markers.Add;
  Marker.Title := 'New';
  LoadMarkers;
  GetInfoMarker;
end;

procedure TMarkerFrame.bDelClick(Sender: TObject);
begin
  if lbMarkersList.ItemIndex = -1 then
    Exit;

  lbMarkersList.Items.Objects[lbMarkersList.ItemIndex].Free;
  lbMarkersList.Items.Delete(lbMarkersList.ItemIndex);
  GetInfoMarker;
end;

procedure TMarkerFrame.cbActiveClick(Sender: TObject);
begin
  TGMPublic(GMMap).Active := cbActive.Checked;
end;

procedure TMarkerFrame.cbAnimationChange(Sender: TObject);
begin
  TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].Animation := TGMTransform.StrToAnimation(cbAnimation.Text);
end;

procedure TMarkerFrame.cbClickableClick(Sender: TObject);
begin
  TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].Clickable := cbClickable.Checked;
end;

procedure TMarkerFrame.cbCollisionBehaviorChange(Sender: TObject);
begin
  TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].CollisionBehavior := TGMTransform.StrToCollisionBehavior(cbCollisionBehavior.Text);
end;

procedure TMarkerFrame.cbCrossOnDragClick(Sender: TObject);
begin
  TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].CrossOnDrag := cbCrossOnDrag.Checked;
end;

procedure TMarkerFrame.cbDraggableClick(Sender: TObject);
begin
  TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].Draggable := cbDraggable.Checked;
end;

procedure TMarkerFrame.cbVisibleClick(Sender: TObject);
begin
  TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].Visible := cbVisible.Checked;
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

procedure TMarkerFrame.eIconUrlChange(Sender: TObject);
begin
  TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].Icon.Url := eIconUrl.Text;
end;

procedure TMarkerFrame.eLabelTextChange(Sender: TObject);
begin
  TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].LabelText.Text := eLabelText.Text;
end;

procedure TMarkerFrame.eLatChange(Sender: TObject);
begin
  TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].Position.Lat := TGMTransform.GetStrToDouble(eLat.Text);
end;

procedure TMarkerFrame.eLngChange(Sender: TObject);
begin
  TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].Position.Lng := TGMTransform.GetStrToDouble(eLng.Text);
end;

procedure TMarkerFrame.GetAnimation;
var
  Value: TGMAnimation;
begin
  cbAnimation.Items.Clear;
  for Value := Low(TGMAnimation) to High(TGMAnimation) do
    cbAnimation.Items.Add( TGMTransform.AnimationToStr(Value) );
  cbAnimation.ItemIndex := cbAnimation.Items.IndexOf(TGMTransform.AnimationToStr( TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].Animation ));
end;

procedure TMarkerFrame.GetCollisionBehavior;
var
  Value: TGMCollisionBehavior;
begin
  cbCollisionBehavior.Items.Clear;
  for Value := Low(TGMCollisionBehavior) to High(TGMCollisionBehavior) do
    cbCollisionBehavior.Items.Add( TGMTransform.CollisionBehaviorToStr(Value) );
  cbCollisionBehavior.ItemIndex := cbCollisionBehavior.Items.IndexOf(TGMTransform.CollisionBehaviorToStr( TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].CollisionBehavior ));
end;

procedure TMarkerFrame.GetInfoMarker;
begin
  tsMarker.Caption := 'Marker';
  cbAnimation.Items.Clear;

  if lbMarkersList.ItemIndex = -1 then
    Exit;

  tsMarker.Caption := lbMarkersList.Items[lbMarkersList.ItemIndex];

  GetAnimation;
  GetCollisionBehavior;

  cbClickable.Checked := TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].Clickable;
  cbCrossOnDrag.Checked := TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].CrossOnDrag;
  cbDraggable.Checked := TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].Draggable;
  eIconUrl.Text := TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].Icon.Url;
  eLabelText.Text := TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].LabelText.Text;
  eLat.Text := TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].Position.LatToStr;
  eLng.Text := TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].Position.LngToStr;
  cbVisible.Checked := TGMPublic(GMMap).Markers.Markers[lbMarkersList.ItemIndex].Visible;
end;

procedure TMarkerFrame.lbMarkersListClick(Sender: TObject);
begin
  GetInfoMarker;
  pcPages.ActivePage := tsMarker;
end;

procedure TMarkerFrame.LoadMarkers;
var
  i: Integer;
begin
  lbMarkersList.Clear;
  for i := 0 to TGMPublic(GMMap).Markers.Markers.Count - 1 do
    lbMarkersList.AddItem(TGMPublic(GMMap).Markers.Markers[i].ZIndex.ToString + '-' + TGMPublic(GMMap).Markers.Markers[i].Name, TGMPublic(GMMap).Markers.Markers[i]);
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
