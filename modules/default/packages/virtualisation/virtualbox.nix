{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "virtualbox" config.foxflake.system.applications) {

    nixpkgs.overlays = [
      (final: prev: {
        virtualbox = pkgs.unstable.virtualbox;
        virtualboxExtpack = pkgs.unstable.virtualboxExtpack;
      })
    ];

    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };

  };

}
