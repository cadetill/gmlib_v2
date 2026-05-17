{**
  @abstract(Provider-neutral base for installable map components.)
}
unit uMapLib.Core.Component;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes;
{$ELSE}
  System.Classes;
{$ENDIF}

type
  TMapLibComponent = class(TComponent)
  protected
    function GetAPIUrl: string; virtual;
    function GetDocumentationUrl: string; virtual;
  public
    property APIUrl: string read GetAPIUrl;
    property DocumentationUrl: string read GetDocumentationUrl;
  end;

implementation

function TMapLibComponent.GetAPIUrl: string;
begin
  Result := GetDocumentationUrl;
end;

function TMapLibComponent.GetDocumentationUrl: string;
begin
  Result := '';
end;

end.

