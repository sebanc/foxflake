{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "oversteer" config.foxflake.system.applications) {

    environment.systemPackages = with pkgs; [ oversteer ];
    services.udev.packages = with pkgs; [ oversteer ];

  };

}
