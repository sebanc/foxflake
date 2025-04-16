{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
    git
    gzip
    xz
    zip
    zstd
  ];

}
