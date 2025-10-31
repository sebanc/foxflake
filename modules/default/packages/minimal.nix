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
      bzip2
      dmidecode
      efibootmgr
      git
      gzip
      p7zip
      pciutils
      usbutils
      xz
      zip
      zstd
    ];

  };

}
