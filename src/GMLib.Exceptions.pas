{
  @abstract(Exception classes for GMLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(August 2, 2022)
  @lastmod(August 2, 2022)

  The GMLib.Exceptions unit provides access to the exceptions raised by GMLib.
}
unit GMLib.Exceptions;

{$I ..\gmlib.inc}

interface

uses
  {$IFDEF DELPHIXE2}
  System.SysUtils,
  {$ELSE}
  SysUtils,
  {$ENDIF}
  GMLib.Sets;

type
  // @include(..\Help\docs\GMLib.Exceptions.EGMException.txt)
  EGMException = class(Exception)
  public
    // @include(..\Help\docs\GMLib.Exceptions.EGMException.Create_1.txt)
    constructor Create(const Msg: string; const Args: array of const; Lang: TGMLang); reintroduce; overload; virtual;
    // @include(..\Help\docs\GMLib.Exceptions.EGMException.Create_2.txt)
    constructor Create(const Idx: Integer; const Args: array of const; Lang: TGMLang); reintroduce; overload; virtual;
  end;

  // @include(..\Help\docs\GMLib.Exceptions.EGMNotValidRealNumber.txt)
  EGMNotValidRealNumber = class(EGMException)
  public
    // @include(..\Help\docs\GMLib.Exceptions.EGMNotValidRealNumber.Create.txt)
    constructor Create(const Args: array of const; Lang: TGMLang); reintroduce; overload; virtual;
  end;

  // @include(..\Help\docs\GMLib.Exceptions.EGMWithoutOwner.txt)
  EGMWithoutOwner = class(EGMException)
  public
    // @include(..\Help\docs\GMLib.Exceptions.EGMWithoutOwner.Create.txt)
    constructor Create(Lang: TGMLang); reintroduce; overload; virtual;
  end;

  // @include(..\Help\docs\GMLib.Exceptions.EGMOwnerWithoutJS.txt)
  EGMOwnerWithoutJS = class(EGMException)
  public
    // @include(..\Help\docs\GMLib.Exceptions.EGMOwnerWithoutJS.Create.txt)
    constructor Create(Lang: TGMLang); reintroduce; overload; virtual;
  end;

  // @include(..\Help\docs\GMLib.Exceptions.EGMJSError.txt)
  EGMJSError = class(EGMException)
  public
    // @include(..\Help\docs\GMLib.Exceptions.EGMJSError.Create.txt)
    constructor Create(const Args: array of const; Lang: TGMLang); reintroduce; overload; virtual;
  end;

  // @include(..\Help\docs\GMLib.Exceptions.EGMUnassignedObject.txt)
  EGMUnassignedObject = class(EGMException)
  public
    // @include(..\Help\docs\GMLib.Exceptions.EGMUnassignedObject.Create.txt)
    constructor Create(const Args: array of const; Lang: TGMLang); reintroduce; overload; virtual;
  end;

  // @include(..\Help\docs\GMLib.Exceptions.EGMMapIsActive.txt)
  EGMMapIsActive = class(EGMException)
  public
    // @include(..\Help\docs\GMLib.Exceptions.EGMMapIsActive.Create.txt)
    constructor Create(Lang: TGMLang); reintroduce; overload; virtual;
  end;

  // @include(..\Help\docs\GMLib.Exceptions.EGMIncorrectBrowser.txt)
  EGMIncorrectBrowser = class(EGMException)
  public
    // @include(..\Help\docs\GMLib.Exceptions.EGMIncorrectBrowser.Create.txt)
    constructor Create(Lang: TGMLang); reintroduce; overload; virtual;
  end;

  // @include(..\Help\docs\GMLib.Exceptions.EGMCanLoadResource.txt)
  EGMCanLoadResource = class(EGMException)
  public
    // @include(..\Help\docs\GMLib.Exceptions.EGMCanLoadResource.Create.txt)
    constructor Create(Lang: TGMLang); reintroduce; overload; virtual;
  end;

  // @include(..\Help\docs\GMLib.Exceptions.EGMTimeOut.txt)
  EGMTimeOut = class(EGMException)
  public
    // @include(..\Help\docs\GMLib.Exceptions.EGMTimeOut.Create.txt)
    constructor Create(Lang: TGMLang); reintroduce; overload; virtual;
  end;

  // @include(..\Help\docs\GMLib.Exceptions.EGMNotActive.txt)
  EGMNotActive = class(EGMException)
  public
    // @include(..\Help\docs\GMLib.Exceptions.EGMNotActive.Create.txt)
    constructor Create(Lang: TGMLang); reintroduce; overload; virtual;
  end;

  // @include(..\Help\docs\GMLib.Exceptions.EGMMapIsNull.txt)
  EGMMapIsNull = class(EGMException)
  public
    // @include(..\Help\docs\GMLib.Exceptions.EGMMapIsNull.Create.txt)
    constructor Create(Lang: TGMLang); reintroduce; overload; virtual;
  end;

implementation

uses
  GMLib.Translations;

{ EGMException }

constructor EGMException.Create(const Idx: Integer; const Args: array of const;
  Lang: TGMLang);
begin
  inherited Create(GetTranslateText(Idx, Args, Lang));
end;

constructor EGMException.Create(const Msg: string; const Args: array of const;
  Lang: TGMLang);
begin
  inherited Create(GetTranslateText(Msg, Args, Lang));
end;

{ EGMNotValidRealNumber }

constructor EGMNotValidRealNumber.Create(const Args: array of const;
  Lang: TGMLang);
begin
  inherited Create(1, Args, Lang);
end;

{ EGMWithoutOwner }

constructor EGMWithoutOwner.Create(Lang: TGMLang);
begin
  inherited Create(2, [], Lang);
end;

{ EGMOwnerWithoutJS }

constructor EGMOwnerWithoutJS.Create(Lang: TGMLang);
begin
  inherited Create(3, [], Lang);
end;

{ EGMJSError }

constructor EGMJSError.Create(const Args: array of const; Lang: TGMLang);
begin
  inherited Create(4, Args, Lang);
end;

{ EGMUnassignedObject }

constructor EGMUnassignedObject.Create(const Args: array of const;
  Lang: TGMLang);
begin
  inherited Create(5, Args, Lang);
end;

{ EGMMapIsActive }

constructor EGMMapIsActive.Create(Lang: TGMLang);
begin
  inherited Create(6, [], Lang);
end;

{ EGMIncorrectBrowser }

constructor EGMIncorrectBrowser.Create(Lang: TGMLang);
begin
  inherited Create(7, [], Lang);
end;

{ EGMCanLoadResource }

constructor EGMCanLoadResource.Create(Lang: TGMLang);
begin
  inherited Create(8, [], Lang);
end;

{ EGMTimeOut }

constructor EGMTimeOut.Create(Lang: TGMLang);
begin
  inherited Create(9, [], Lang);
end;

{ EGMNotActive }

constructor EGMNotActive.Create(Lang: TGMLang);
begin
  inherited Create(10, [], Lang);
end;

{ EGMMapIsNull }

constructor EGMMapIsNull.Create(Lang: TGMLang);
begin
  inherited Create(11, [], Lang);
end;

end.
