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
      binutils-unwrapped
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
      gcc-unwrapped
      git
      gnumake
      gzip
      jq
      llvmPackages.clang-unwrapped
      llvmPackages.llvm
      llvmPackages.lld
      lm_sensors
      lsof
      lz4
      ntfs3g
      openssl
      p7zip
      pahole
      patchelf
      pciutils
      procps
      psmisc
      pv
      rust-bindgen
      rustc
      rustfmt
      squashfsTools
      sysstat
      unzip
      usbutils
      vim
      wget
      xz
      zip
      zstd
    ];

  };

}
