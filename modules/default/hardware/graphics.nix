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
        libva-vdpau-driver
      ];
      extraPackages32 = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libva-vdpau-driver
      ];
    };

    systemd.tmpfiles.rules = [
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    ];

    environment.variables = {
      MESA_SHADER_CACHE_MAX_SIZE = "12G";
      ROC_ENABLE_PRE_VEGA = "1";
    };

  };

}
