{ lib, config, pkgs, ... }:
with lib;

{

  config = {

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

    # AMD OpenCL support
    systemd.tmpfiles.rules = [
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    ];
    environment.variables = { 
      ROC_ENABLE_PRE_VEGA = "1";
    };

  };

}
