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
      };
    };

    programs.gnupg = {
      package = mkDefault pkgs.gnupg1;
      agent.enable = mkDefault true;
      dirmngr.enable = mkDefault true;
    };

    services = {
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
