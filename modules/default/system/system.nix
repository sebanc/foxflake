{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = {

    documentation.nixos.enable = mkDefault false;

    nix = {
      gc = {
        automatic = mkDefault true;
        dates = mkDefault "weekly";
        options = mkDefault "--delete-older-than 30d";
        randomizedDelaySec = "1m";
      };
      settings = {
        auto-optimise-store = mkDefault true;
        cores = mkDefault 4;
      };
    };

    services.fstrim = {
      enable = mkDefault true;
      interval = mkDefault "weekly";
    };

    zramSwap.enable = mkDefault true;

  };

}
