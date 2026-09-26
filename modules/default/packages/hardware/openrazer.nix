{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "openrazer" config.foxflake.system.applications) {

    hardware.openrazer.enable = true;
    environment.systemPackages = with pkgs.stable; [ polychromatic ];

  };

}
