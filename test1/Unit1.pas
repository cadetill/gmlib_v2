unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, REST.Json.Types,
  Child, Father;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
  protected
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TTest = class(TCollectionItem)
  private
    FChild: TChild;
    FPorp1: string;
    FPorp3: Integer;
    FPorp2: Integer;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    property Child: TChild read FChild write FChild;
    property Porp1: string read FPorp1 write FPorp1;
    property Porp2: Integer read FPorp2 write FPorp2;
    property Porp3: Integer read FPorp3 write FPorp3;
  end;

  TLlbResults = class
  private
    FLlbResultsBoolVal: string;
    FLlbResultsLat: string;
    FLlbResultsLng: string;
    FLlbResultsMapisnull: string;
    FLlbResultsNeLat: string;
    FLlbResultsNeLng: string;
    FLlbResultsSwLat: string;
    FLlbResultsSwLng: string;
  public
    property LlbResultsBoolVal: string read FLlbResultsBoolVal write FLlbResultsBoolVal;
    property LlbResultsLat: string read FLlbResultsLat write FLlbResultsLat;
    property LlbResultsLng: string read FLlbResultsLng write FLlbResultsLng;
    property LlbResultsMapisnull: string read FLlbResultsMapisnull write FLlbResultsMapisnull;
    property LlbResultsNeLat: string read FLlbResultsNeLat write FLlbResultsNeLat;
    property LlbResultsNeLng: string read FLlbResultsNeLng write FLlbResultsNeLng;
    property LlbResultsSwLat: string read FLlbResultsSwLat write FLlbResultsSwLat;
    property LlbResultsSwLng: string read FLlbResultsSwLng write FLlbResultsSwLng;
  end;

  TEventsMap = class
  private
    FEventsMapBoundsChange: string;
    FEventsMapCenterChange: string;
    FEventsMapClick: string;
    FEventsMapContextmenu: string;
    FEventsMapDblclick: string;
    FEventsMapDrag: string;
    FEventsMapDragEnd: string;
    FEventsMapDragStart: string;
    FEventsMapEventFired: string;
    FEventsMapLat: string;
    FEventsMapLng: string;
    FEventsMapMapTypeId: string;
    FEventsMapMapTypeId_changed: string;
    FEventsMapMouseMove: string;
    FEventsMapMouseOut: string;
    FEventsMapMouseOver: string;
    FEventsMapNeLat: string;
    FEventsMapNeLng: string;
    FEventsMapSwLat: string;
    FEventsMapSwLng: string;
    FEventsMapTilesLoaded: string;
    FEventsMapX: string;
    FEventsMapY: string;
    FEventsMapZoom: string;
    FEventsMapZoomChanged: string;
  public
    property EventsMapBoundsChange: string read FEventsMapBoundsChange write FEventsMapBoundsChange;
    property EventsMapCenterChange: string read FEventsMapCenterChange write FEventsMapCenterChange;
    property EventsMapClick: string read FEventsMapClick write FEventsMapClick;
    property EventsMapContextmenu: string read FEventsMapContextmenu write FEventsMapContextmenu;
    property EventsMapDblclick: string read FEventsMapDblclick write FEventsMapDblclick;
    property EventsMapDrag: string read FEventsMapDrag write FEventsMapDrag;
    property EventsMapDragEnd: string read FEventsMapDragEnd write FEventsMapDragEnd;
    property EventsMapDragStart: string read FEventsMapDragStart write FEventsMapDragStart;
    property EventsMapEventFired: string read FEventsMapEventFired write FEventsMapEventFired;
    property EventsMapLat: string read FEventsMapLat write FEventsMapLat;
    property EventsMapLng: string read FEventsMapLng write FEventsMapLng;
    property EventsMapMapTypeId: string read FEventsMapMapTypeId write FEventsMapMapTypeId;
    property EventsMapMapTypeId_changed: string read FEventsMapMapTypeId_changed write FEventsMapMapTypeId_changed;
    property EventsMapMouseMove: string read FEventsMapMouseMove write FEventsMapMouseMove;
    property EventsMapMouseOut: string read FEventsMapMouseOut write FEventsMapMouseOut;
    property EventsMapMouseOver: string read FEventsMapMouseOver write FEventsMapMouseOver;
    property EventsMapNeLat: string read FEventsMapNeLat write FEventsMapNeLat;
    property EventsMapNeLng: string read FEventsMapNeLng write FEventsMapNeLng;
    property EventsMapSwLat: string read FEventsMapSwLat write FEventsMapSwLat;
    property EventsMapSwLng: string read FEventsMapSwLng write FEventsMapSwLng;
    property EventsMapTilesLoaded: string read FEventsMapTilesLoaded write FEventsMapTilesLoaded;
    property EventsMapX: string read FEventsMapX write FEventsMapX;
    property EventsMapY: string read FEventsMapY write FEventsMapY;
    property EventsMapZoom: string read FEventsMapZoom write FEventsMapZoom;
    property EventsMapZoomChanged: string read FEventsMapZoomChanged write FEventsMapZoomChanged;
  end;

  THTMLForms = class
  private
    FEventsMap: TEventsMap;
    FLlbResults: TLlbResults;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    property EventsMap: TEventsMap read FEventsMap;
    property LlbResults: TLlbResults read FLlbResults;
  end;

var
  Form1: TForm1;

implementation

uses
  Rest.Json, REST.JsonReflect, System.JSON, System.JSONConsts,
  GMJson;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Child: TGMCustomMarker;
  FJson: IJson;
begin
  FJson := TGMJson.Create;

  Child := TGMCustomMarker.Create(nil);

  Memo1.Lines.Text := FJson.Serialize(Child);

  Memo1.Lines.Add('');
  Memo1.Lines.Add('');

  Child.Free;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Child: TTest;
  FJson: IJson;
begin
  FJson := TGMJson.Create;

  Child := FJson.Deserialize(TTest, Memo1.Lines.Text) as TTest;

  ShowMessage(Child.Porp1);
  ShowMessage(Child.Child.Prop.ToString);

  Child.Free;
end;

constructor TForm1.Create(AOwner: TComponent);
begin
  inherited;

end;

{ THTMLForms }

constructor THTMLForms.Create;
begin
  inherited;

  FEventsMap := TEventsMap.Create;
  FLlbResults := TLlbResults.Create;
end;

destructor THTMLForms.Destroy;
begin
  FEventsMap.Free;
  FLlbResults.Free;

  inherited;
end;

{ TTest }

constructor TTest.Create(Collection: TCollection);
begin
  inherited;

  FChild := TChild.Create(nil);
end;

destructor TTest.Destroy;
begin
  FChild.Free;

  inherited;
end;

end.

