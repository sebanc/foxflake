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
