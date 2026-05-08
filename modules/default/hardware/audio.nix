{ lib, config, pkgs, ... }:
with lib;

{

  options.foxflake.audio = {
    lowLatency = mkOption {
      type = with types; bool;
      default = false;
      description = "Enable low latency audio support";
    };
  };

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
      extraConfig.pipewire."92-low-latency" = mkIf config.foxflake.audio.lowLatency {
        context.modules = [
          {
            name = "libpipewire-module-rt";
            args = {
              "nice.level" = -11;
              "rt.prio" = 95;
              "rt.time.soft" = 200000;
              "rt.time.hard" = 200000;
            };
            flags = [ "ifexists" "nofail" ];
          }
        ];
        context.properties = {
          default.clock.rate = 48000;
          default.clock.quantum = 64;
          default.clock.min-quantum = 32;
          default.clock.max-quantum = 8192;
        };
      };
      extraConfig.pipewire-pulse."92-low-latency" = mkIf config.foxflake.audio.lowLatency {
        context.properties = {
          pulse.min.req = "32/48000";
          pulse.default.req = "64/48000";
          pulse.max.req = "256/48000";
          pulse.min.quantum = "32/48000";
          pulse.max.quantum = "256/48000";
        };
      };
    };

  };

}
