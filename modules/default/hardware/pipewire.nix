{ lib, config, ... }:
with lib;

{

  options.foxflake.pipewire.enable = mkOption {
    description = "Enable FoxFlake pipewire configurations";
    type = types.bool;
    default = true;
  };

  config = mkIf config.foxflake.pipewire.enable {

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
