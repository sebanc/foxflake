{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "xone" config.foxflake.system.applications) {

    hardware.xone.enable = mkDefault true;

  };

}
