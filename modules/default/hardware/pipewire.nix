{ lib, config, ... }:
with lib;

{

  config = {

    security.rtkit.enable = mkDefault true;

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
