{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "openrgb" config.foxflake.system.applications) {

    services.hardware.openrgb = {
      enable = mkDefault true;
      package = mkDefault pkgs.openrgb-with-all-plugins;
    };

  };

}
