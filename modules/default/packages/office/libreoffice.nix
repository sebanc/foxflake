{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "standard" config.foxflake.system.applications || builtins.elem "libreoffice" config.foxflake.system.applications) {

    environment.systemPackages = with pkgs; [ libreoffice (if (lib.head (lib.splitString "_" config.i18n.defaultLocale) == "fr") then pkgs.hunspellDicts.fr-moderne else (lib.attrByPath [ "hunspellDicts" (lib.head (lib.splitString "." config.i18n.defaultLocale)) ] pkgs.bash pkgs)) ];

  };

}
