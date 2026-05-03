{ lib, config, pkgs, ... }:
with lib;

{

  config = {

    security = {
      pam.loginLimits = mkOverride 999 [
        { domain = "@audio"; type = "-"; item = "memlock"; value = "unlimited"; }
        { domain = "@audio"; type = "-"; item = "nice";   value = "-5"; }
        { domain = "@audio"; type = "-"; item = "rtprio"; value = "80"; }
      ];
      rtkit.enable = mkDefault true;
    };

    services.pipewire = {
      enable = mkDefault true;
      jack.enable = mkDefault true;
      pulse.enable = mkDefault true;
      alsa = {
        enable = mkDefault true;
        support32Bit = mkDefault true;
      };
    };

  };

}
