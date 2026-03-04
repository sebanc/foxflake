{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "gaming" config.foxflake.system.applications || builtins.elem "steam" config.foxflake.system.applications) {

    programs.steam = {
      enable = mkDefault true;
      dedicatedServer.openFirewall = mkDefault true;
      remotePlay.openFirewall = mkDefault true;
      localNetworkGameTransfers.openFirewall = mkDefault true;
    };
    nixpkgs.config.packageOverrides = pkgs: {
      steam = pkgs.steam.override { extraEnv = { TZ = "/etc/localtime"; }; };
    };

  };

}
