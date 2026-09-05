{ lib, pkgs, osConfig, ... }:
with lib;

{

  config = mkIf (builtins.elem "input-remapper" osConfig.foxflake.system.applications) {

    xdg.configFile."autostart/input-mapper-autoload.desktop" = mkDefault {
      source = "${osConfig.services.input-remapper.package}/share/applications/input-remapper-autoload.desktop";
    };

  };

}
