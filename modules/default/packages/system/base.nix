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
      binutils
      btrfs-progs
      bzip2
      dmidecode
      dnsmasq
      e2fsprogs
      efibootmgr
      exfatprogs
      fastfetch
      file
      git
      gzip
      jq
      ntfs3g
      p7zip
      patchelf
      pciutils
      psmisc
      squashfsTools
      unzip
      usbutils
      wget
      xz
      zip
      zstd
    ];

  };

}
