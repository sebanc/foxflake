{
  inputs,
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
      psmisc
      unzip
      usbutils
      wget
      xz
      zip
      zstd
    ];

    nixpkgs.overlays = [(final: prev: {
      openldap = inputs.nixpkgs-stable.legacyPackages.${prev.stdenv.hostPlatform.system}.openldap;
    })];

  };

}
