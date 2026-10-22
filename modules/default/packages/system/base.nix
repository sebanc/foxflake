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
      bc
      binutils
      bison
      btrfs-progs
      bzip2
      cargo
      dmidecode
      dnsmasq
      e2fsprogs
      efibootmgr
      elfutils
      exfatprogs
      fastfetch
      file
      findutils
      flex
      gawk
      git
      gnumake
      gzip
      jq
      llvmPackages.clang
      llvmPackages.llvm
      llvmPackages.lld
      lm_sensors
      lsof
      lz4
      ntfs3g
      openssl
      p7zip
      patchelf
      pciutils
      procps
      psmisc
      pv
      rust-bindgen
      rustc
      rustfmt
      squashfsTools
      stdenv.cc
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
