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

    nixpkgs.config.rocmSupport = mkDefault true;
    systemd.tmpfiles.rules = [
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    ];
    environment.variables = { 
      ROC_ENABLE_PRE_VEGA = "1";
    };

  };

}
