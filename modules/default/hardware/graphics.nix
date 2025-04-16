{ lib, config, pkgs, ... }:
with lib;

{

  options.foxflake.graphics.enable = mkOption {
    description = "Enable FoxFlake graphics configurations";
    type = types.bool;
    default = true;
  };

  config = mkIf config.foxflake.graphics.enable {

    hardware.graphics = {
      enable = mkDefault true;
      enable32Bit = mkDefault true;
      extraPackages = with pkgs; [
        intel-gpu-tools
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        libva
      ];
      extraPackages32 = with pkgs; [
        intel-gpu-tools
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        libva
      ];
    };
  };

}
