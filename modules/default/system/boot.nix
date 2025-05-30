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
      description = "Enable FoxFlake Boot configurations";
      type = with types; bool;
      default = true;
    };
    efiSupport = mkOption {
      description = "Whether GRUB should be built with EFI support.";
      type = types.bool;
      default = true;
    };
    device = mkOption {
      description = ''
        The device on which the GRUB boot loader will be installed.
        The special value `nodev` means that a GRUB
        boot menu will be generated, but GRUB itself will not
        actually be installed.  To install GRUB on multiple devices,
        use `boot.loader.grub.devices`.
      '';
      type = with types; str;
      default = "";
      example = "/dev/disk/by-id/wwn-0x500001234567890a";
    };
    encryption = mkOption {
      description = "Decrypt encrypted partition from GRUB";
      type = with types; bool;
      default = false;
    };
    encryptionSecrets = mkOption {
      description = ''
        Secrets to append to the initrd. The attribute name is the
        path the secret should have inside the initrd, the value
        is the path it should be copied from (or null for the same
        path inside and out).

        Note that `nixos-rebuild switch` will generate the initrd
        also for past generations, so if secrets are moved or deleted
        you will also have to garbage collect the generations that
        use those secrets.
      '';
      type = types.attrsOf (types.nullOr types.path);
      default = { };
      example = literalExpression ''
        { "/etc/dropbear/dropbear_rsa_host_key" =
            ./secret-dropbear-key;
        }
      '';
    };
  };

  config = mkIf config.foxflake.boot.enable {

    boot = {
      consoleLogLevel = mkDefault 3;
      loader = {
        grub = {
          enable = mkDefault config.foxflake.boot.enable;
          efiSupport = mkDefault config.foxflake.boot.efiSupport;
          device = mkDefault config.foxflake.boot.device;
          useOSProber = mkDefault true;
          enableCryptodisk = mkDefault config.foxflake.boot.encryption;
          extraGrubInstallArgs = if config.boot.loader.grub.efiSupport then
            mkDefault [ "--modules=all_video boot btrfs cat chain configfile echo efifwsetup ext2 fat font gettext gfxmenu gfxterm gfxterm_background gzio halt help hfsplus iso9660 jpeg keystatus linux loadenv loopback ls lsefi lsefimmap lsefisystab lssal memdisk minicmd normal ntfs part_apple part_msdos part_gpt password_pbkdf2 png probe reboot regexp search search_fs_uuid search_fs_file search_label sleep smbios squash4 terminal test true video xfs" ]
          else
            mkDefault [ "--modules=all_video boot btrfs cat chain configfile echo ext2 fat font gettext gfxmenu gfxterm gfxterm_background gzio halt help hfsplus iso9660 jpeg keystatus linux loadenv loopback ls lsmmap memdisk minicmd normal ntfs part_apple part_msdos part_gpt password_pbkdf2 png probe reboot regexp search search_fs_uuid search_fs_file search_label sleep smbios squash4 terminal test true video xfs" ];
        };
        efi.canTouchEfiVariables = mkDefault config.foxflake.boot.efiSupport;
      };
      initrd.secrets = mkDefault config.foxflake.boot.encryptionSecrets;
      tmp.cleanOnBoot = mkDefault true;
      kernelPackages = mkDefault pkgs.linuxPackages;
      plymouth.enable = mkDefault true;
    };

  };

}
