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
      dnsmasq
      efibootmgr
      git
      gzip
      jq
      p7zip
      pciutils
      unzip
      usbutils
      xz
      zip
      zstd
    ];

  };

}
