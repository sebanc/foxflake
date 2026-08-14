{ lib, config, pkgs, ... }:
with lib;

{

  options.foxflake.audio = {
    enable = mkOption {
      type = with types; bool;
      default = if (config.foxflake.environment.enable) then
        true
      else
        false;
      description = "Enable FoxFlake audio support.";
    };
    lowLatency = mkOption {
      type = with types; bool;
      default = false;
      description = "Enable low latency audio support.";
    };
  };

  config = mkIf (config.foxflake.audio.enable) {

    security.rtkit.enable = mkDefault true;

    services.pipewire = {
      enable = mkDefault true;
      jack.enable = mkDefault true;
      pulse.enable = mkDefault true;
      alsa = {
        enable = mkDefault true;
        support32Bit = mkDefault true;
      };
      extraConfig.pipewire."92-low-latency" = mkIf (config.foxflake.audio.lowLatency) {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.min-quantum" = 64;
          "default.clock.quantum" = 128;
          "default.clock.max-quantum" = 512;
        };
      };
      extraConfig.pipewire-pulse."92-low-latency" = mkIf (config.foxflake.audio.lowLatency) {
        "pulse.properties" = {
          "pulse.min.req" = "64/48000";
          "pulse.default.req" = "128/48000";
          "pulse.max.req" = "512/48000";
          "pulse.min.quantum" = "64/48000";
          "pulse.max.quantum" = "512/48000";
        };
      };
      wireplumber.extraConfig."92-low-latency" = mkIf (config.foxflake.audio.lowLatency) {
        "monitor.alsa.rules" = [{
          matches = [
            { "node.name" = "~alsa_output.*"; }
            { "node.name" = "~alsa_input.*"; }
          ];
          actions.update-props = {
            "api.alsa.period-size"   = 128;
            "api.alsa.headroom"      = 2;
          };
        }];
      };
      wireplumber.extraConfig."92-disable-hdmi-suspend" = {
        "monitor.alsa.rules" = [{
          matches = [
            { "node.name" = "~alsa_output.*hdmi.*"; }
          ];
          actions.update-props = {
            "session.suspend-timeout-seconds" = 0;
          };
        }];
      };
    };

  };

}
