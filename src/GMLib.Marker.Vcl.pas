{
  @abstract(@code(google.maps.Marker) class from Google Maps API.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(October 25, 2022)
  @lastmod(October 25, 2022)

  The GMLib.Marker.Vcl contains the implementation of TGMMarker class that encapsulate the @code(google.maps.Marker) class from Google Maps API for Vcl framework.
}
unit GMLib.Marker.Vcl;

{$I ..\gmlib.inc}

interface

uses
  {$IFDEF DELPHIXE2}
  Vcl.Graphics, System.Classes,
  {$ELSE}
  Graphics, Classes,
  {$ENDIF}

  GMLib.Marker;

type
  // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.txt)
  TGMSymbolOptions = class(TGMCustomSymbolOptions)
  private
    FFillColor: TColor;
    FStrokeColor: TColor;
    procedure SetFillColor(const Value: TColor);
    procedure SetStrokeColor(const Value: TColor);
  protected
    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  public
    // @include(..\Help\docs\GMLib.Marker.Vcl.TGMSymbolOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;
  published
    // @include(..\Help\docs\GMLib.Marker.Vcl.TGMSymbolOptions.FillColor.txt)
    property FillColor: TColor read FFillColor write SetFillColor;
    // @include(..\Help\docs\GMLib.Marker.Vcl.TGMSymbolOptions.StrokeColor.txt)
    property StrokeColor: TColor read FStrokeColor write SetStrokeColor;

    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.Path.txt)
    property Path;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.Anchor.txt)
    property Anchor;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.FillOpacity.txt)
    property FillOpacity;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.LabelOrigin.txt)
    property LabelOrigin;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.Rotation.txt)
    property Rotation;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.Scale.txt)
    property Scale;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.StrokeOpacity.txt)
    property StrokeOpacity;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.StrokeWeight.txt)
    property StrokeWeight;
  end;

  // @include(..\Help\docs\GMLib.Marker.TGMCustomIconOptions.txt)
  TGMIconOptions = class(TGMCustomIconOptions)
  private
    FSymbol: TGMSymbolOptions;
  public
    // @include(..\Help\docs\GMLib.Marker.TGMCustomIconOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;
    // @include(..\Help\docs\GMLib.Marker.Vcl.TGMIconOptions.Destroy.txt)
    destructor Destroy; override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;
  published
    // @include(..\Help\docs\GMLib.Marker.Vcl.TGMIconOptions.Symbol.txt)
    property Symbol: TGMSymbolOptions read FSymbol write FSymbol;

    // @include(..\Help\docs\GMLib.Marker.TGMCustomIconOptions.Url.txt)
    property Url;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomIconOptions.Icon.txt)
    property Icon;
  end;

  // @include(..\Help\docs\GMLib.Marker.TGMCustomLabelOptions.txt)
  TGMLabelOptions = class(TGMCustomLabelOptions)

  end;

implementation

uses
  {$IFDEF DELPHIXE2}
  System.SysUtils,
  {$ELSE}
  SysUtils,
  {$ENDIF}

  GMLib.Transform.Vcl;

{ TGMSymbolOptions }

procedure TGMSymbolOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMSymbolOptions then
  begin
    FillColor := TGMSymbolOptions(Source).FillColor;
    StrokeColor := TGMSymbolOptions(Source).StrokeColor;
  end;
end;

constructor TGMSymbolOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FFillColor := clBlack;
  FStrokeColor := clBlack;
end;

function TGMSymbolOptions.PropToString: string;
const
  Str = '%s,%s';
begin
  Result := inherited PropToString;

  Result := Result + Format(Str, [
                                  QuotedStr(TGMTransform.TColorToStr(FFillColor)),
                                  QuotedStr(TGMTransform.TColorToStr(FStrokeColor))
                                 ]);
end;

procedure TGMSymbolOptions.SetFillColor(const Value: TColor);
begin
  if FFillColor = Value then Exit;

  FFillColor := Value;
  ControlChanges('FillColor');
end;

procedure TGMSymbolOptions.SetStrokeColor(const Value: TColor);
begin
  if FStrokeColor = Value then Exit;

  FStrokeColor := Value;
  ControlChanges('StrokeColor');
end;

{ TGMIconOptions }

procedure TGMIconOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMIconOptions then
  begin
    Symbol.Assign(TGMIconOptions(Source).Symbol);
  end;
end;

constructor TGMIconOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FSymbol := TGMSymbolOptions.Create(Self);
end;

destructor TGMIconOptions.Destroy;
begin
  if Assigned(FSymbol) then FSymbol.Free;

  inherited;
end;

end.
