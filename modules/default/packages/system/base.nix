{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  options.foxflake.system.defaultPackages = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Install FoxFlake default set of packages.";
    };
  };

  config = mkIf (config.foxflake.system.defaultPackages.enable) {

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
      findutils
      gawk
      git
      gzip
      jq
      ntfs3g
      p7zip
      patchelf
      pciutils
      procps
      psmisc
      squashfsTools
      sysstat
      unzip
      usbutils
      wget
      xz
      zip
      zstd
    ];

  };

}
