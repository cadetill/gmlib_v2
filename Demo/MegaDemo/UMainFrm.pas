unit UMainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, GMClasses,
  Vcl.OleCtrls, SHDocVw, Vcl.ExtCtrls, GMMap, GMMap.VCL, Vcl.ComCtrls,
  Vcl.Buttons, Vcl.Samples.Spin, Vcl.CheckLst;

type
  TMainFrm = class(TForm)
    WebBrowser1: TWebBrowser;
    pcPages: TPageControl;
    tsMap: TTabSheet;
    bMapActive: TButton;
    ScrollBox1: TScrollBox;
    Panel1: TPanel;
    cbMapFullScreenControl: TCheckBox;
    eMapDraggableCursor: TEdit;
    eMapDraggingCursor: TEdit;
    Label4: TLabel;
    Label3: TLabel;
    cbMapDraggable: TCheckBox;
    cbMapDisableDoubleClickZoom: TCheckBox;
    cbMapDisableDefaultUI: TCheckBox;
    eMapCenterLat: TEdit;
    eMapCenterLng: TEdit;
    bMapSetCenter: TButton;
    Label2: TLabel;
    cbMapBgColor: TColorBox;
    Label1: TLabel;
    bMapFullScreenControl: TSpeedButton;
    Panel2: TPanel;
    pMapFullScreenControl: TPanel;
    Label6: TLabel;
    cbMapFSCPosition: TComboBox;
    Label5: TLabel;
    eMapHeading: TSpinEdit;
    cbMapKeyboardShortcuts: TCheckBox;
    cbMapMapMaker: TCheckBox;
    cbMapMapTypeControl: TCheckBox;
    bMapMapTypeControl: TSpeedButton;
    pMapMapTypeControl: TPanel;
    Label7: TLabel;
    cbMapMTCPosition: TComboBox;
    cbMapMTCStyle: TComboBox;
    Style: TLabel;
    Panel3: TPanel;
    lbMapMTCMapTypeIds: TCheckListBox;
    Label8: TLabel;
    TabSheet1: TTabSheet;
    sbMap: TScrollBox;
    Splitter1: TSplitter;
    GMMap1: TGMMap;
    procedure bMapSetCenterClick(Sender: TObject);
    procedure cbMapBgColorChange(Sender: TObject);
    procedure bMapActiveClick(Sender: TObject);
    procedure cbMapDisableDefaultUIClick(Sender: TObject);
    procedure cbMapDisableDoubleClickZoomClick(Sender: TObject);
    procedure cbMapDraggableClick(Sender: TObject);
    procedure cbMapFullScreenControlClick(Sender: TObject);
    procedure bMapFullScreenControlClick(Sender: TObject);
    procedure cbMapFSCPositionChange(Sender: TObject);
    procedure eMapHeadingChange(Sender: TObject);
    procedure cbMapKeyboardShortcutsClick(Sender: TObject);
    procedure cbMapMapMakerClick(Sender: TObject);
    procedure cbMapMapTypeControlClick(Sender: TObject);
    procedure bMapMapTypeControlClick(Sender: TObject);
  private
    procedure ControlMapProperties;
    procedure FillMapCombos;

    procedure GetProperties(Comp: TClass; NameBase: string; HParent: TWinControl; Level: Integer);
    procedure ButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  MainFrm: TMainFrm;

implementation

uses
  System.TypInfo,
  System.Rtti,
  GMSets, GMLatLngBounds;

{$R *.dfm}

procedure TMainFrm.bMapActiveClick(Sender: TObject);
begin
  GMMap1.Active := not GMMap1.Active;
  ControlMapProperties;
end;

procedure TMainFrm.bMapFullScreenControlClick(Sender: TObject);
begin
  if pMapFullScreenControl.Height = 0 then
  begin
    pMapFullScreenControl.Height := 27;
    bMapFullScreenControl.Caption := '-';
  end
  else
  begin
    pMapFullScreenControl.Height := 0;
    bMapFullScreenControl.Caption := '+';
  end;
end;

procedure TMainFrm.bMapMapTypeControlClick(Sender: TObject);
begin
  if pMapMapTypeControl.Height = 0 then
  begin
    pMapMapTypeControl.Height := 135;
    bMapMapTypeControl.Caption := '-';
  end
  else
  begin
    pMapMapTypeControl.Height := 0;
    bMapMapTypeControl.Caption := '+';
  end;
end;

procedure TMainFrm.bMapSetCenterClick(Sender: TObject);
begin
  GMMap1.MapOptions.Center.Lat := GMMap1.MapOptions.Center.StringToReal(eMapCenterLat.Text);
  GMMap1.MapOptions.Center.Lng := GMMap1.MapOptions.Center.StringToReal(eMapCenterLng.Text);
end;

procedure TMainFrm.ButtonClick(Sender: TObject);
  procedure ControlHeight(Container: TWinControl; PanelHeight, Level: Integer);
  var
    i: Integer;
  begin
    for i := 0 to Container.ControlCount - 1 do
      if (Container.Controls[i].Tag >= (Level * 10)) and (Container.Controls[i].Tag <= (Level * 100)) then
        Container.Controls[i].Height := PanelHeight;
  end;
begin
  if not (Sender is TSpeedButton) and not Assigned(TSpeedButton(Sender).Parent) then Exit;

  if TSpeedButton(Sender).Caption = '+' then
  begin
    TSpeedButton(Sender).Caption := '-';
    ControlHeight(TSpeedButton(Sender).Parent.Parent, 20, TSpeedButton(Sender).Parent.Tag);
  end
  else
  begin
    TSpeedButton(Sender).Caption := '+';
    ControlHeight(TSpeedButton(Sender).Parent.Parent, 0, TSpeedButton(Sender).Parent.Tag);
  end;
end;

procedure TMainFrm.cbMapBgColorChange(Sender: TObject);
begin
  GMMap1.MapOptions.BackgroundColor := cbMapBgColor.Selected;
end;

procedure TMainFrm.cbMapDisableDefaultUIClick(Sender: TObject);
begin
  GMMap1.MapOptions.DisableDefaultUI := cbMapDisableDefaultUI.Checked;
end;

procedure TMainFrm.cbMapDisableDoubleClickZoomClick(Sender: TObject);
begin
  GMMap1.MapOptions.DisableDoubleClickZoom := cbMapDisableDoubleClickZoom.Checked;
end;

procedure TMainFrm.cbMapDraggableClick(Sender: TObject);
begin
  GMMap1.MapOptions.Draggable := cbMapDraggable.Checked;
end;

procedure TMainFrm.cbMapFSCPositionChange(Sender: TObject);
begin
  GMMap1.MapOptions.FullScreenControlOptions.Position := TGMTransform.StrToPosition(cbMapFSCPosition.Text);
end;

procedure TMainFrm.cbMapFullScreenControlClick(Sender: TObject);
begin
  GMMap1.MapOptions.FullScreenControl := cbMapFullScreenControl.Checked;
end;

procedure TMainFrm.cbMapKeyboardShortcutsClick(Sender: TObject);
begin
  GMMap1.MapOptions.KeyboardShortcuts := cbMapKeyboardShortcuts.Checked;
end;

procedure TMainFrm.cbMapMapMakerClick(Sender: TObject);
begin
  GMMap1.MapOptions.MapMaker := cbMapMapMaker.Checked;
end;

procedure TMainFrm.cbMapMapTypeControlClick(Sender: TObject);
begin
  GMMap1.MapOptions.MapTypeControl := cbMapMapTypeControl.Checked;
end;

procedure TMainFrm.ControlMapProperties;
var
  EnabledComp: Boolean;
begin
  if GMMap1.Active then
  begin
    EnabledComp := False;
    bMapActive.Caption := 'Close';
  end
  else
  begin
    EnabledComp := True;
    bMapActive.Caption := 'Active';
  end;

  cbMapBgColor.Enabled := EnabledComp;
  cbMapDisableDefaultUI.Enabled := EnabledComp;
  cbMapDisableDoubleClickZoom.Enabled := EnabledComp;
  cbMapDraggable.Enabled := EnabledComp;
  eMapDraggableCursor.Enabled := EnabledComp;
  eMapDraggingCursor.Enabled := EnabledComp;
  cbMapFullScreenControl.Enabled := EnabledComp;
  cbMapFSCPosition.Enabled := EnabledComp;
  eMapHeading.Enabled := EnabledComp;
  eMapHeading.Enabled := EnabledComp;
  cbMapKeyboardShortcuts.Enabled := EnabledComp;
  cbMapMapMaker.Enabled := EnabledComp;
  cbMapMapTypeControl.Enabled := EnabledComp;
end;

constructor TMainFrm.Create(AOwner: TComponent);
begin
  inherited;

  pcPages.ActivePageIndex := 0;

  // Map properties
  GetProperties(GMMap1.ClassType, GMMap1.ClassName, sbMap, 1);
  FillMapCombos;
  ControlMapProperties;
  cbMapBgColor.Selected := GMMap1.MapOptions.BackgroundColor;
  eMapCenterLat.Text := GMMap1.MapOptions.Center.LatToStr(GMMap1.Precision);
  eMapCenterLng.Text := GMMap1.MapOptions.Center.LngToStr(GMMap1.Precision);
  cbMapDisableDefaultUI.Checked := GMMap1.MapOptions.DisableDefaultUI;
  cbMapDisableDoubleClickZoom.Checked := GMMap1.MapOptions.DisableDoubleClickZoom;
  cbMapDraggable.Checked := GMMap1.MapOptions.Draggable;
  eMapDraggableCursor.Text := GMMap1.MapOptions.DraggableCursor;
  eMapDraggingCursor.Text := GMMap1.MapOptions.DraggingCursor;
  cbMapFullScreenControl.Checked := GMMap1.MapOptions.FullScreenControl;
  cbMapFSCPosition.ItemIndex := cbMapFSCPosition.Items.IndexOf(TGMTransform.PositionToStr(GMMap1.MapOptions.FullScreenControlOptions.Position));
  pMapFullScreenControl.Height := 0;
  eMapHeading.Value := GMMap1.MapOptions.Heading;
  cbMapKeyboardShortcuts.Checked := GMMap1.MapOptions.KeyboardShortcuts;
  cbMapMapMaker.Checked := GMMap1.MapOptions.MapMaker;
  cbMapMapTypeControl.Checked := GMMap1.MapOptions.MapTypeControl;
  pMapMapTypeControl.Height := 0;
end;

procedure TMainFrm.eMapHeadingChange(Sender: TObject);
begin
  GMMap1.MapOptions.Heading := eMapHeading.Value;
end;

procedure TMainFrm.FillMapCombos;
var
  CP: TGMControlPosition;
  ST: TGMMapTypeControlStyle;
  MT: TGMMapTypeId;
begin
  // add positions
  cbMapFSCPosition.Clear;
  cbMapMTCPosition.Clear;
  for CP := Low(CP) to High(CP) do
  begin
    cbMapFSCPosition.Items.Add(TGMTransform.PositionToStr(CP));
    cbMapMTCPosition.Items.Add(TGMTransform.PositionToStr(CP));
  end;

  // add Style
  cbMapMTCStyle.Clear;
  for ST := Low(ST) to High(ST) do
  begin
    cbMapMTCStyle.Items.Add(TGMTransform.MapTypeControlStyleToStr(ST));
  end;

  // MapTypeIds
  lbMapMTCMapTypeIds.Clear;
  for MT := Low(MT) to High(MT) do
  begin
    lbMapMTCMapTypeIds.Items.Add(TGMTransform.MapTypeIdToStr(MT));
  end;
end;

procedure TMainFrm.GetProperties(Comp: TClass; NameBase: string;
  HParent: TWinControl; Level: Integer);
var
  ctx: TRttiContext;
  rt: TRttiType;
  prop: TRttiProperty;
  Panel: TPanel;
  SubLevel: Integer;
  Value: TValue;
begin
  ctx := TRttiContext.Create();
  try
    rt := ctx.GetType(Comp);

    SubLevel := 0;
    for prop in rt.GetProperties() do
    begin
      if not prop.IsWritable or (TRttiInstanceType(prop.PropertyType).TypeKind in [tkMethod, tkPointer]) then
        Continue;

      // panel creation
      Panel := TPanel.Create(Self);
      Panel.Name := 'p' + NameBase + prop.Name;
      Panel.Parent := HParent;
      Panel.Caption := ''; //Panel.Name;
      Panel.Align := alTop;
      Panel.Height := 20;
      Panel.BevelOuter := bvNone;
      Panel.Tag := (Level * 10) + SubLevel;
      //if Level <> 1 then
      //  Panel.Height := 0;
      Inc(SubLevel);

      // label creation
      with TLabel.Create(Self) do
      begin
        Name := 'l' + NameBase + prop.Name;
        Parent := Panel;
        Caption := prop.Name; // + IntToStr(Panel.Tag); // + ' - ' + GetEnumName(TypeInfo(TTypeKind), Ord(TRttiInstanceType(prop.PropertyType).TypeKind));
        if Panel.Tag > 100000 then
          Left := 100
        else if Panel.Tag > 10000 then
          Left := 80
        else if Panel.Tag > 1000 then
          Left := 60
        else if Panel.Tag > 100 then
          Left := 40
        else if Panel.Tag > 10 then
          Left := 20
        else Left := 0;
        Top := 3;
      end;

      if TRttiInstanceType(prop.PropertyType).TypeKind = tkClass then
      begin
        if prop.Name = 'WebBrowser' then
          Continue;

        {with TSpeedButton.Create(Self) do
        begin
          Name := 'b' + NameBase + prop.Name;
          Parent := Panel;
          Caption := '+';
          Left := Panel.Width;
          Top := 0;
          Height := 20;
          Width := 20;
          OnClick := ButtonClick;
        end;}
        //ShowMessage(prop.Name + ' - ' + TRttiInstanceType(prop.PropertyType).MetaclassType.ClassName);
        GetProperties(TRttiInstanceType(prop.PropertyType).MetaclassType, NameBase + prop.Name, HParent, Panel.Tag);
      end
      else
      begin
        case TRttiInstanceType(prop.PropertyType).TypeKind of
          tkUString, tkString, tkChar, tkWChar, tkLString, tkWString:
          begin
            prop.
            with TEdit.Create(Self) do
            begin
              Name := 'e' + NameBase + prop.Name;
              Parent := Panel;
              Text := Value.ToString;
            end;
          end;
        end;
      end;

    end;
  finally
    ctx.Free();
  end;
end;

end.
