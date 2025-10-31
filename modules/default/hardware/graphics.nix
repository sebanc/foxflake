{ lib, config, pkgs, ... }:
with lib;

{

  config = {

    hardware.graphics = {
      enable = mkDefault true;
      enable32Bit = mkDefault true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        vaapiVdpau
      ];
      extraPackages32 = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        vaapiVdpau
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
