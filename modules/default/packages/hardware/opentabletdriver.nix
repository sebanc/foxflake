{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "opentabletdriver" config.foxflake.system.applications) {

    hardware.opentabletdriver.enable = mkDefault true;
    hardware.uinput.enable = mkDefault true;
    boot.kernelModules = [ "uinput" ];

  };

}
