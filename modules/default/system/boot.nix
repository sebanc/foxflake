{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{
  
  options.foxflake.boot = {
    enable = mkOption {
      type = with types; bool;
      default = true;
      description = "Enable FoxFlake Boot configurations.";
    };
    efiSupport = mkOption {
      type = types.bool;
      default = true;
      description = "Whether GRUB should be built with EFI support.";
    };
    efiSysMountPoint = mkOption {
      type = types.str;
      default = "/boot";
      description = "Where the EFI System Partition is mounted.";
    };
    device = mkOption {
      type = with types; str;
      default = if (config.foxflake.boot.efiSupport) then
        "nodev"
      else
        "";
      example = "/dev/disk/by-id/wwn-0x500001234567890a";
      description = ''
        The device on which the GRUB boot loader will be installed.
        The special value `nodev` means that a GRUB
        boot menu will be generated, but GRUB itself will not
        actually be installed.  To install GRUB on multiple devices,
        use `boot.loader.grub.devices`.
      '';
    };
  };

  config = mkIf (config.foxflake.boot.enable) {

    nixpkgs.overlays = [
      (final: prev: {
        os-prober = prev.os-prober.overrideAttrs (oldAttrs: {
          postFixup = (oldAttrs.postFixup or "") + ''
            substituteInPlace $out/share/common.sh \
              --replace-fail \
              'fstype=$(lsblk --nodeps --noheading --output FSTYPE -- "$1" || true)' \
              'fstype=$(lsblk --nodeps --noheading --output FSTYPE -- "$1" 2>/dev/null || true)'
          '';
        });
      })
    ];

    boot = {
      consoleLogLevel = mkDefault 3;
      initrd.systemd.enable = mkDefault true;
      kernelPackages = mkDefault pkgs.unstable.linuxPackages_latest;
      kernelParams = [ "fbcon=nodefer" "quiet" ];
      loader = {
        grub = {
          enable = mkDefault config.foxflake.boot.enable;
          efiSupport = mkDefault config.foxflake.boot.efiSupport;
          device = mkDefault config.foxflake.boot.device;
          useOSProber = mkDefault true;
          extraGrubInstallArgs = if (config.boot.loader.grub.efiSupport) then
            mkDefault [ "--modules=all_video boot btrfs cat chain configfile echo efifwsetup ext2 fat font gettext gfxmenu gfxterm gfxterm_background gzio halt help hfsplus iso9660 jpeg keystatus linux loadenv loopback ls lsefi lsefimmap lsefisystab lssal memdisk minicmd normal ntfs part_apple part_msdos part_gpt password_pbkdf2 png probe reboot regexp search search_fs_uuid search_fs_file search_label sleep smbios squash4 terminal test true video xfs" ]
          else
            mkDefault [ "--modules=all_video boot btrfs cat chain configfile echo ext2 fat font gettext gfxmenu gfxterm gfxterm_background gzio halt help hfsplus iso9660 jpeg keystatus linux loadenv loopback ls lsmmap memdisk minicmd normal ntfs part_apple part_msdos part_gpt password_pbkdf2 png probe reboot regexp search search_fs_uuid search_fs_file search_label sleep smbios squash4 terminal test true video xfs" ];
        };
        efi = {
          canTouchEfiVariables = mkDefault config.foxflake.boot.efiSupport;
          efiSysMountPoint = mkDefault config.foxflake.boot.efiSysMountPoint;
        };
      };
      plymouth.enable = mkDefault true;
      tmp.cleanOnBoot = mkDefault true;
      zfs = {
        package = mkDefault pkgs.unstable.zfs;
        forceImportRoot = mkDefault false;
      };
    };

    hardware = {
      cpu = {
        intel.updateMicrocode = mkDefault true;
        amd.updateMicrocode = mkDefault true;
      };
      enableAllFirmware = mkDefault true;
      enableAllHardware = mkDefault true;
    };

  };

}
