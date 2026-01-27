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
      extraConfig.pipewire-pulse."92-crackling-fix" = {
        "pulse.properties" = {
          "pulse.min.req" = "1024/48000";
          "pulse.min.frag" = "1024/48000";
          "pulse.min.quantum" = "1024/48000";
          "pulse.idle-timeout" = 0;
        };
      };
    };

  };

}
