{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (config.foxflake.system.waydroid || builtins.elem "full" config.foxflake.system.applications || builtins.elem "waydroid" config.foxflake.system.applications) {

    virtualisation.waydroid.enable = mkDefault true;
    environment.systemPackages = with pkgs; [ fakeroot waydroid-helper ];

  };

}
