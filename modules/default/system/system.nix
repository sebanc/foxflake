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
        randomizedDelaySec = "45m";
      };
      settings = {
        auto-optimise-store = mkDefault true;
        cores = mkDefault 4;
      };
    };

    programs.gnupg = {
      package = mkDefault pkgs.gnupg1;
      agent.enable = mkDefault true;
      dirmngr.enable = mkDefault true;
    };

    services.fstrim = {
      enable = mkDefault true;
      interval = mkDefault "weekly";
    };

    zramSwap.enable = mkDefault true;

  };

}
