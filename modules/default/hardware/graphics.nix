{ lib, config, pkgs, ... }:
with lib;

{

  options.foxflake.graphics.compute = {
    enable = mkOption {
      description = "Add GPU acceleration drivers needed for math and deep learning.";
      type = with types; bool;
      default = false;
    };
  };

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
      "L+ /opt/rocm - - - - ${pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs; [ rocmPackages.clr rocmPackages.hiprt ] ++ optionals (config.foxflake.graphics.compute.enable) (with pkgs; [ rocmPackages.hipblas rocmPackages.rocblas ]);
      }}"
    ];

    environment.variables = {
      MESA_SHADER_CACHE_MAX_SIZE = "12G";
      ROC_ENABLE_PRE_VEGA = "1";
    };

  };

}
