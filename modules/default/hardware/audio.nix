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
      extraConfig.pipewire."92-defaults" = {
        "context.properties" = {
          "default.clock.allowed-rates" = [ 48000 ];
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 2048;
          "default.clock.quantum-floor" = 4;
          "default.clock.quantum-limit" = 8192;
        };
      };
      extraConfig.pipewire-pulse."92-defaults" = {
        "stream.properties" = {
          "node.latency" = "1024/48000";
          "resample.quality" = 4;
        };
        "pulse.properties" = {
          "pulse.default.format" = "F32";
          "pulse.min.req" = "256/48000";
          "pulse.default.req" = "960/48000";
          "pulse.min.frag" = "256/48000";
          "pulse.default.frag" = "96000/48000";
          "pulse.default.tlength" = "96000/48000";
          "pulse.min.quantum" = "256/48000";
          "pulse.idle-timeout" = 0;
        };
      };
    };

  };

}
