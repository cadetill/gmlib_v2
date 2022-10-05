unit UMapFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.CheckLst, Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls,

  GMLib.Map.Vcl;

type
  TFrame1 = class(TFrame)
    cbActive: TCheckBox;
    pcPages: TPageControl;
    tsGeneral: TTabSheet;
    lIntervalEvents: TLabel;
    lAPIVersion: TLabel;
    lAPILang: TLabel;
    lAPIKey: TLabel;
    lAPIRegion: TLabel;
    lLanguage: TLabel;
    eIntervalEvents: TSpinEdit;
    cbAPIVersion: TComboBox;
    cbAPILang: TComboBox;
    eAPIKey: TEdit;
    cbAPIRegion: TComboBox;
    cbLanguage: TComboBox;
    tsMapOptions: TTabSheet;
    lBackgroundColor: TLabel;
    cbBackgroundColor: TColorBox;
    gbCenter: TGroupBox;
    lLat: TLabel;
    lLng: TLabel;
    eLat: TEdit;
    eLng: TEdit;
    cbClickableIcons: TCheckBox;
    cbDisableDoubleClickZoom: TCheckBox;
    pcObjects: TPageControl;
    tsFullScreenControl: TTabSheet;
    lFSPosition: TLabel;
    cbFullScreenControl: TCheckBox;
    cbFSPosition: TComboBox;
    tsMapTypeControl: TTabSheet;
    lMTPosition: TLabel;
    lMTStyle: TLabel;
    lMTIds: TLabel;
    lMapTypeId: TLabel;
    cbMTPosition: TComboBox;
    clbMTIds: TCheckListBox;
    cbMapTypeControl: TCheckBox;
    cbMTStyle: TComboBox;
    cbMapTypeId: TComboBox;
    tsRestriction: TTabSheet;
    cbREnabled: TCheckBox;
    cbRStrictBounds: TCheckBox;
    gbRNE: TGroupBox;
    lRNELat: TLabel;
    lRNELng: TLabel;
    eRNELat: TEdit;
    eRNELng: TEdit;
    gbRSW: TGroupBox;
    lRSWLat: TLabel;
    lRSWLng: TLabel;
    eRSWLat: TEdit;
    eRSWLng: TEdit;
    tsRotateControl: TTabSheet;
    lRotPosition: TLabel;
    cbRotateControl: TCheckBox;
    cbRotPosition: TComboBox;
    tsScaleControl: TTabSheet;
    lSStyle: TLabel;
    cbScaleControl: TCheckBox;
    cbSStyle: TComboBox;
    tsStreetViewControl: TTabSheet;
    lSVPosition: TLabel;
    cbStreetViewControl: TCheckBox;
    cbSVPosition: TComboBox;
    tsZoomControl: TTabSheet;
    lZPosition: TLabel;
    lZoom: TLabel;
    lMaxZoom: TLabel;
    lMinZoom: TLabel;
    cbZoomControl: TCheckBox;
    cbZPosition: TComboBox;
    eZoom: TEdit;
    eMaxZoom: TEdit;
    eMinZoom: TEdit;
    tsLayers: TTabSheet;
    cbTrafficLayerShow: TCheckBox;
    cbTransitLayerShow: TCheckBox;
    cbByciclingLayerShow: TCheckBox;
    cbNoClear: TCheckBox;
    cbKeyboardShortcuts: TCheckBox;
    cbIsFractionalZoomEnabled: TCheckBox;
    procedure cbActiveClick(Sender: TObject);
  private
    FGMMap: TGMMap;
  public
    property GMMap: TGMMap read FGMMap write FGMMap;
  end;

  TGMapHack = class(TGMMap);

implementation

{$R *.dfm}

procedure TFrame1.cbActiveClick(Sender: TObject);
begin
  TGMapHack(GMMap).Active := cbActive.Checked;
end;

end.
