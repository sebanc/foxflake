{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = {

    environment.systemPackages = with pkgs; [
      pciutils
      usbutils
      git
      gzip
      xz
      zip
      zstd
    ];

  };

}
