{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || config.foxflake.environment.type == "steam" || config.foxflake.environment.type == "steamdeck" || builtins.elem "gaming" config.foxflake.system.applications || builtins.elem "steam" config.foxflake.system.applications) {

    environment.systemPackages = with pkgs; [ zenity ];

    programs.steam = {
      enable = mkDefault true;
      extraPackages = with pkgs; [
        harfbuzz
        libthai
        libx11
        libxext
        libxcursor
        libxinerama
        libxrandr
        libxrender
        libxcomposite
        libxi
        pango
      ];
      dedicatedServer.openFirewall = mkDefault true;
      remotePlay.openFirewall = mkDefault true;
      localNetworkGameTransfers.openFirewall = mkDefault true;
    };
    nixpkgs.config.packageOverrides = pkgs: {
      steam = pkgs.steam.override {
        extraEnv = { TZ = ":/etc/localtime"; OBS_VKCAPTURE = true; };
      };
    };

  };

}
