{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "standard" config.foxflake.system.bundles) {

    environment = {
      sessionVariables = {
        MOZ_USE_XINPUT2 = "1";
      };
      systemPackages = with pkgs; [
        libreoffice
        (if (lib.head (lib.splitString "_" config.i18n.defaultLocale) == "fr") then pkgs.hunspellDicts.fr-moderne else (lib.attrByPath [ "hunspellDicts" (lib.head (lib.splitString "." config.i18n.defaultLocale)) ] pkgs.bash pkgs))
      ];
    };

    programs = {
      firefox = {
        enable = mkDefault true;
        preferences = {
          "widget.use-xdg-desktop-portal.file-picker" = 1;
        };
      };
      thunderbird.enable = mkDefault true;
    };

  };

}
