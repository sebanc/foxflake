{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "xpadneo" config.foxflake.system.applications) {

    hardware.xpadneo.enable = mkDefault true;

  };

}
