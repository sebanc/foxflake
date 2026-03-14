{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "fanatecff" config.foxflake.system.applications) {

    hardware.hid-fanatecff.enable = mkDefault true;

  };

}
