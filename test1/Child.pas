unit Child;

interface

uses
  REST.Json.Types,
  Father;

type
  TChild = class(TSecond)
  private
    [JSONName('Promo')]
    FProp: Integer;
  public
    property APIUrl;
    property Prop: Integer read FProp write FProp;
  end;

implementation

end.
