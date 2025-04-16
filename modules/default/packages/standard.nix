{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  options.foxflake.system = {
    standardPackages = mkOption {
      description = "Enable FoxFlake standard packages configuration";
      type = with types; bool;
      default = false;
    };
  };

  config = mkIf (builtins.elem "standard" config.foxflake.system.bundles) {

    environment.systemPackages = with pkgs; [
      thunderbird
      libreoffice
    ];

    programs.firefox = {
      enable = mkDefault true;
      preferences = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };
      
    environment.sessionVariables = {
      MOZ_USE_XINPUT2 = "1";
    };
  };

}
