{**
  @abstract(Initial OSM/MapLibre map component skeleton.)
}
unit uOSMLib.Map;

{$I ..\..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes,
{$ELSE}
  System.Classes,
{$ENDIF}
  uMapLib.Core.Component;

type
  TOSMMap = class(TMapLibComponent)
  private
    FActive: Boolean;
    FStyleUrl: string;
    procedure SetActive(const Value: Boolean);
    procedure SetStyleUrl(const Value: string);
  protected
    function GetDocumentationUrl: string; override;
  public
    constructor Create(AOwner: TComponent); override;
    function ResolveStyleUrl: string;
  published
    property Active: Boolean read FActive write SetActive default False;
    property StyleUrl: string read FStyleUrl write SetStyleUrl;
  end;

function GetOSMMapStyleUrl(AMap: TOSMMap): string;

implementation

const
  DEFAULT_MAPLIBRE_STYLE_URL = 'https://demotiles.maplibre.org/style.json';

constructor TOSMMap.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FStyleUrl := DEFAULT_MAPLIBRE_STYLE_URL;
end;

function TOSMMap.GetDocumentationUrl: string;
begin
  Result := 'https://maplibre.org/maplibre-gl-js/docs/';
end;

function TOSMMap.ResolveStyleUrl: string;
begin
  Result := FStyleUrl;
end;

function GetOSMMapStyleUrl(AMap: TOSMMap): string;
begin
  if Assigned(AMap) then
    Result := AMap.FStyleUrl
  else
    Result := DEFAULT_MAPLIBRE_STYLE_URL;
end;

procedure TOSMMap.SetActive(const Value: Boolean);
begin
  if FActive = Value then
    Exit;

  FActive := Value;
end;

procedure TOSMMap.SetStyleUrl(const Value: string);
begin
  if FStyleUrl = Value then
    Exit;

  FStyleUrl := Value;
end;

end.

