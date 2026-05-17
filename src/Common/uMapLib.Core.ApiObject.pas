{**
  @abstract(Provider-neutral base for Delphi API value objects.)
}
unit uMapLib.Core.ApiObject;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes;
{$ELSE}
  System.Classes;
{$ENDIF}

type
  TMapLibApiObject = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FOwner: TPersistent;
  protected
    function GetAPIUrl: string; virtual;
    function GetDocumentationUrl: string; virtual;
    function GetOwner: TPersistent; override;
    procedure Changed; virtual;
  public
    constructor Create; virtual;
    procedure Assign(Source: TPersistent); override;

    property DocumentationUrl: string read GetDocumentationUrl;
    property APIUrl: string read GetAPIUrl;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Owner: TPersistent read FOwner write FOwner;
  end;

implementation

constructor TMapLibApiObject.Create;
begin
  inherited Create;
end;

procedure TMapLibApiObject.Assign(Source: TPersistent);
begin
  if Source = Self then
    Exit;

  if Source is TMapLibApiObject then
    Exit;

  inherited;
end;

procedure TMapLibApiObject.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TMapLibApiObject.GetAPIUrl: string;
begin
  Result := GetDocumentationUrl;
end;

function TMapLibApiObject.GetDocumentationUrl: string;
begin
  Result := '';
end;

function TMapLibApiObject.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

end.

