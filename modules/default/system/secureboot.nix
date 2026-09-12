{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  options.foxflake.experimental.secureBoot.enable = mkOption {
    type = types.bool;
    default = false;
    description = "Whether to enable Secure Boot with shim-signed.";
  };

  config = mkIf (config.foxflake.experimental.secureBoot.enable || config.foxflake.build.binaryCache) {

    assertions = [
      {
        assertion = (config.boot.loader.grub.enable && config.boot.loader.grub.efiSupport) || config.foxflake.build.binaryCache;
        message = "To enable Secure Boot, you need to have GRUB set as bootloader in EFI mode.";
      }
    ];

    nixpkgs.overlays = [
      (final: prev: {
        shim-signed-ubuntu = prev.stdenv.mkDerivation {
          pname = "shim-signed-ubuntu";
          version = "15.8";
          src = prev.fetchurl {
            url = "https://archive.ubuntu.com/ubuntu/pool/main/s/shim-signed/shim-signed_1.59+15.8-0ubuntu2_amd64.deb";
            sha256 = "f8ed71ce2d91a304b6d5eb84997f846f331b554578bc02dbfe78e13ad8ac81a9";
          };
          nativeBuildInputs = with prev; [ dpkg ];
          unpackPhase = ''
            dpkg-deb -x $src shim-signed
          '';
          installPhase = ''
            mkdir -p "$out/share"
            cp -r shim-signed/usr/lib/shim "$out/share/"
          '';
        };
        grub2 = prev.grub2.overrideAttrs (oldAttrs: {
          postInstall = (oldAttrs.postInstall or "") + ''
            mv $out/sbin/grub-install $out/sbin/grub-install-real
            cat > $out/sbin/grub-install <<GRUBINSTALL
            #!/bin/sh
            set -eu
            cat >/tmp/sbat.csv <<GRUBSBAT
            sbat,1,SBAT Version,sbat,1,https://github.com/rhboot/shim/blob/main/SBAT.md
            grub,3,Free Software Foundation,grub,2:${prev.grub2.version},https//www.gnu.org/software/grub/
            grub.foxflake,1,FoxFlake Linux,grub,2:${prev.grub2.version},https//www.gnu.org/software/grub/
            GRUBSBAT
            $out/bin/grub-install-real "\$@" --sbat=/tmp/sbat.csv
            if [ ! -f /etc/secureboot_key/MOK.key ] || [ ! -f /etc/secureboot_key/MOK.crt ] || [ ! -f /etc/secureboot_key/MOK.der ]; then
              rm -rf /etc/secureboot_key
              mkdir /etc/secureboot_key
              ${prev.openssl.bin}/bin/openssl req -newkey rsa:4096 -nodes -keyout /etc/secureboot_key/MOK.key -new -x509 -sha256 -days 36500 -subj "/CN=FoxFlake Machine Owner Key/" -out /etc/secureboot_key/MOK.crt
              ${prev.openssl.bin}/bin/openssl x509 -outform DER -in /etc/secureboot_key/MOK.crt -out /etc/secureboot_key/MOK.der
              chmod 0640 /etc/secureboot_key/*
              cp /etc/secureboot_key/MOK.der ${config.boot.loader.efi.efiSysMountPoint}/${config.system.nixos.distroName}.der
            fi
            ${prev.sbsigntool}/bin/sbsign --key /etc/secureboot_key/MOK.key --cert /etc/secureboot_key/MOK.crt --output ${config.boot.loader.efi.efiSysMountPoint}/EFI/${config.system.nixos.distroName}-boot-efi/grubx64.efi ${config.boot.loader.efi.efiSysMountPoint}/EFI/${config.system.nixos.distroName}-boot-efi/grubx64.efi
            cp ${final.shim-signed-ubuntu}/share/shim/shimx64.efi.signed.latest ${config.boot.loader.efi.efiSysMountPoint}/EFI/${config.system.nixos.distroName}-boot-efi/shimx64.efi
            cp ${final.shim-signed-ubuntu}/share/shim/mmx64.efi ${config.boot.loader.efi.efiSysMountPoint}/EFI/${config.system.nixos.distroName}-boot-efi/mmx64.efi
            for entry in \$(for duplicate in \$(efibootmgr | cut -f1 | grep '${config.system.nixos.distroName}-boot-efi' | cut -d'*' -f1 | sed 's@Boot@@g'); do echo -n "\$duplicate "; done); do efibootmgr -b \$entry -B; done
            ${prev.efibootmgr}/bin/efibootmgr -c -d "/dev/\$(lsblk -no PKNAME \$(findmnt ${config.boot.loader.efi.efiSysMountPoint} -no SOURCE))" -p "\$(lsblk -no PARTN \$(findmnt ${config.boot.loader.efi.efiSysMountPoint} -no SOURCE))" -L ${config.system.nixos.distroName}-boot-efi -l "\\EFI\\${config.system.nixos.distroName}-boot-efi\\shimx64.efi"
            GRUBINSTALL
            chmod +x $out/sbin/grub-install
          '';
        });
      })
    ];

    boot.loader.grub.extraInstallCommands = ''
      if ${pkgs.coreutils}/bin/ls /boot/kernels | ${pkgs.gnugrep}/bin/grep -q '.*-linux-.*Image' && [ -f /etc/secureboot_key/MOK.key ] && [ -f /etc/secureboot_key/MOK.crt ] && [ -x ${pkgs.sbsigntool}/bin/sbsign ] && [ -x ${pkgs.sbsigntool}/bin/sbverify ]; then
        for kernel in /boot/kernels/*-linux-*Image; do
          if ! ${pkgs.sbsigntool}/bin/sbverify --list ''${kernel} | ${pkgs.gnugrep}/bin/grep -q 'CN=FoxFlake Machine Owner Key'; then
            ${pkgs.sbsigntool}/bin/sbsign --key /etc/secureboot_key/MOK.key --cert /etc/secureboot_key/MOK.crt --output ''${kernel} ''${kernel}
          fi
        done
      fi
    '';
  };
}
