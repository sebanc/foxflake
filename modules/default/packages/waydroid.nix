{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf config.foxflake.system.waydroid {

    virtualisation.waydroid.enable = mkDefault true;

    environment.systemPackages = [
      pkgs.unzip
      pkgs.fakeroot
      pkgs.unstable.waydroid
      pkgs.unstable.waydroid-helper
      (pkgs.callPackage ../../../packages/foxflake-waydroid-setup {})
    ];

  };

}
