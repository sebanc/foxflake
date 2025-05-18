{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "gaming" config.foxflake.system.bundles) {

    environment.systemPackages = with pkgs.unstable; [
      gamescope
      gamescope-wsi
      heroic
      joystickwake
      lutris
      mangohud
    ];

    hardware.steam-hardware.enable = mkDefault true;

    programs = {
      gamemode.enable = mkDefault true;
      steam = {
        enable = mkDefault true;
        dedicatedServer.openFirewall = mkDefault true;
        remotePlay.openFirewall = mkDefault true;
        localNetworkGameTransfers.openFirewall = mkDefault true;
      };
    };

  };

}
