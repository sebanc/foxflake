{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (config.foxflake.system.waydroid || builtins.elem "full" config.foxflake.system.applications || builtins.elem "waydroid" config.foxflake.system.applications) {

    virtualisation.waydroid = {
      enable = mkDefault true;
      package = mkDefault pkgs.stable.waydroid-nftables;
    };
    environment.systemPackages = with pkgs.stable; [ fakeroot waydroid-helper ];

  };

}
