{ lib, config, pkgs, ... }:
with lib;

{

  config = {

    hardware.graphics = {
      enable = mkDefault true;
      enable32Bit = mkDefault true;
      extraPackages = with pkgs; [
        intel-compute-runtime
        intel-media-driver
        intel-vaapi-driver
        libva
        rocmPackages.clr.icd
        vpl-gpu-rt
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
