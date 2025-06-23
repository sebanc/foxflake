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
      pkgs.unstable.waydroid-helper
      (pkgs.unstable.waydroid.override { python3Packages = pkgs.python312Packages; })
      (pkgs.callPackage ../../../packages/foxflake-waydroid-setup {})
    ];

  };

}
