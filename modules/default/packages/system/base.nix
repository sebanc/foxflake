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
      btrfs-progs
      bzip2
      dmidecode
      dnsmasq
      e2fsprogs
      efibootmgr
      exfatprogs
      git
      gzip
      jq
      ntfs3g
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
