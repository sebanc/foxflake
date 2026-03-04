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
        download-buffer-size = 524288000;
        substituters = [
          "https://foxflake.cachix.org/"
          "https://cache.nixos.org/"
        ];
        trusted-public-keys = [
          "foxflake.cachix.org-1:6CgKI4ifg2+w55WTG/RNEcthi2sZULhggnG4Bru7tqY="
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
      };
    };

    networking.nftables.enable = mkDefault true;

    programs.gnupg = {
      package = mkDefault pkgs.gnupg1;
      agent.enable = mkDefault true;
      dirmngr.enable = mkDefault true;
    };

    services = {
      envfs.enable = mkDefault true;
      fstrim = {
        enable = mkDefault true;
        interval = mkDefault "weekly";
      };
      fwupd.enable = mkDefault true;
      thermald.enable = mkDefault true;
    };

    zramSwap.enable = mkDefault true;

  };

}
