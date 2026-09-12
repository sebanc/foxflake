{ lib, pkgs, osConfig, ... }:
with lib;

{

  config = {

    nix = {
      gc = {
        automatic = mkDefault true;
        dates = mkDefault "daily";
        options = mkDefault "--delete-older-than 14d";
        randomizedDelaySec = "45m";
      };
    };
    systemd.user.services.nix-gc.serviceConfig = { CPUQuota = "25%"; };

  };

}
