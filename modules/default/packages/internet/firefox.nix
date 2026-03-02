{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

let
  firefox_locale = if builtins.elem (builtins.replaceStrings ["_"] ["-"] (builtins.head (builtins.split "." config.i18n.defaultLocale))) [ "en-CA" "en-GB" "es-AR" "es-CL" "es-ES" "es-MX" "fy-NL" "ga-IE" "gu-IN" "hi-IN" "hy-AM" "nb-NO" "ne-NP" "nn-NO" "pa-IN" "pt-BR" "pt-PT" "sv-SE" "zh-CN" "zh-TW" ] then [ (builtins.replaceStrings ["_"] ["-"] (builtins.head (builtins.split "." config.i18n.defaultLocale))) "en-US" ] else if builtins.elem (builtins.head (builtins.split "_" config.i18n.defaultLocale)) [ "af" "an" "ar" "az" "be" "bg" "bn" "br" "bs" "ca" "cs" "cy" "da" "de" "el" "eo" "et" "eu" "fa" "ff" "fi" "fr" "gd" "gl" "gn" "he" "hr" "hu" "ia" "id" "is" "it" "ja" "ka" "kk" "km" "kn" "ko" "lt" "lv" "mk" "mr" "ms" "my" "nl" "oc" "pl" "rm" "ro" "ru" "sc" "si" "sk" "sl" "sq" "sr" "ta" "te" "tg" "th" "tl" "tr" "uk" "ur" "uz" "vi" "xh" ] then [ (builtins.head (builtins.split "_" config.i18n.defaultLocale)) "en-US" ] else [ ];
in
{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "standard" config.foxflake.system.applications || builtins.elem "firefox" config.foxflake.system.applications) {

    environment.sessionVariables = { MOZ_USE_XINPUT2 = "1"; };
    programs = {
      firefox = {
        enable = mkDefault true;
        languagePacks = mkDefault firefox_locale;
        policies.RequestedLocales = mkDefault firefox_locale;
        preferences = {
          "widget.use-xdg-desktop-portal.file-picker" = 1;
        };
      };
    };

  };

}
