{
  @abstract(Exceptions and messages translations from GMLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(August 2, 2022)
  @lastmod(August 2, 2022)

  The GMLib.Translations contains all translations for the exceptions raised by GMLib.
  @br@br
  If you want to add a new translation you must to do:
  @unorderedList(
  @item(Into GMLib.Sets unit: add new language into TGMLang set)
  @item(In this unit: add a new Array into const section with translation)
  @item(In this unit: modify GetTranslateText function (the second function, the one with Idx as parameter) to add the new language in case statement)
  )
}
unit GMLib.Translations;

{$I ..\gmlib.inc}

interface

uses
  GMLib.Sets;

const
  // @exclude
  MaxArray = 11;
  // Array with exception messages in Spanish language.
  // @exclude
  Lang_ES: array[0..MaxArray] of string = (
      'Índice fuera de rango.',
      '%d no es un número válido.',
      'Propietatio no asignado.',
      'El objeto (o su propietario) no suportan llamadas JavaScript.',
      'Error ejecutando la función JavaScript %s.'#13#13'Mensaje de error: %s',
      'Objeto %s no asignado.',
      'El mapa está activo. Debe desactivarlo antes de cambiar esta propiedad.',
      'El navegador no es de la clase esperada.',
      'No se ha podido cargar el recurso del mapa.',
      'Tiempo de espera excedido.',
      'El mapa no está activo.',
      'El objeto Map en JavaScript es null.'
  );

  // Array with exception messages in English language.
  // @exclude
  Lang_EN: array[0..MaxArray] of string = (
      'Index out of range.',
      '%d is not a valid real value.',
      'Owner not assigned.',
      'The object (or its owner) does not support JavaScript calls.',
      'An error occurs executing %s JavaScript function.'#13#13'Error message: %s',
      'Unassigned %s object.',
      'The map is active. To change this property you must to deactivate it first.',
      'The browser is not of the correct class.',
      'Can''t load map resource.',
      'A timeout occurred.',
      'Map is not active.',
      'The Map object in JavaScript is null.'
  );

  // Array with exception messages in French language.
  // @exclude
  Lang_FR: array[0..MaxArray] of string = (
      'Indice hors limites.',
      '%d n''est pas un numero valide.',
      'Sans propriétaire.',
      'L''objet (ou son propriétaire) ne supporte pas appels JavaScript.',
      'Une erreur est survenue a l''exécution de la fonction javascript %s.'#13#13'Message d''erreur: %s',
      'Objet %s non initialisé.',
      'La carte est active. Tu dois le désactiver avant de changer cette propriété.',
      'Le navigateur n''est pas du type désiré.',
      'Impossible de charger la ressource de la carte.',
      'Un délai d''attente est produite.',
      'La carte n''est pas active.',
      'L''objet Map en JavaScript est null.'
  );

  { -------------------------------------------------------------------------- }
  // @include(..\Help\docs\GMLib.Translations.GetTranslateText_1.txt)
  function GetTranslateText(Text: string; const Args: array of const; Lang: TGMLang): string; overload;

  { -------------------------------------------------------------------------- }
  // @include(..\Help\docs\GMLib.Translations.GetTranslateText_2.txt)
  function GetTranslateText(Idx: Integer; const Args: array of const; Lang: TGMLang): string; overload;

implementation

uses
  {$IFDEF DELPHIXE2}
  System.SysUtils;
  {$ELSE}
  SysUtils;
  {$ENDIF}

function GetTranslateText(Text: string; const Args: array of const;
  Lang: TGMLang): string;
var
  Idx: Integer;
begin
  Result := '';

  for Idx := 0 to MaxArray do
    if SameText(Text, Lang_EN[Idx]) then
    begin
      Result := GetTranslateText(Idx, Args, Lang);
      Break;
    end;

  if Result = '' then
    Result := GetTranslateText(0, Args, Lang);
end;

function GetTranslateText(Idx: Integer; const Args: array of const;
  Lang: TGMLang): string;
begin
  if Idx > MaxArray then Idx := 0;

  case Lang of
    lnEspanol: Result := Lang_ES[Idx];
    lnFrench: Result := Lang_FR[Idx];
  else
    Result := Lang_EN[Idx];
  end;

  Result := Format(Result, Args);
end;

end.
