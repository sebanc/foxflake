{
  description = "FoxFlake installer";

  inputs = {
    foxflake.url = "git+https://github.com/sebanc/foxflake?shallow=1&ref=stable-test";
    nixpkgs.follows = "foxflake/nixpkgs";
  };

  outputs =
    { foxflake, nixpkgs, ... }:
    let
      pkgs = import nixpkgs { config.allowUnfree = true; system = "x86_64-linux"; };
    in
    rec {
      installer = nixosConfigurations."foxflake-installer".config.system.build.isoImage;
      nixosConfigurations = {
        "foxflake-installer" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            foxflake.nixosModules.default
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
            {
              nixpkgs.overlays = [
                (final: prev: {
                  calamares = prev.calamares.overrideAttrs (oldAttrs: {
                    postUnpack = (oldAttrs.postUnpack or "") + ''
                      patch -p1 -d "$sourceRoot" < ${./calamares-patches/patches/checkbootcrypto.patch}
                    '';
                    postInstall = (oldAttrs.postInstall or "") + ''
                      if [ -f "$out/share/applications/calamares.desktop" ]; then
                        sed -i 's@pkexec calamares@sudo calamares@g' "$out/share/applications/calamares.desktop"
                      fi
                    '';
                  });
                })
                (final: prev: {
                  calamares-nixos-extensions = prev.calamares-nixos-extensions.overrideAttrs (oldAttrs: {
                    postInstall = (oldAttrs.postInstall or "") + ''
                      mkdir -p $out/etc/calamares/branding $out/etc/calamares/modules $out/lib/calamares/modules $out/share/calamares/branding
                      cp -rT ${./calamares-patches/config}                                  $out/etc/calamares/
                      cp -rT ${./calamares-patches/config}                                  $out/share/calamares/
                      cp -rT ${./calamares-patches/modules}                                 $out/etc/calamares/modules/
                      cp -rT ${./calamares-patches/modules}                                 $out/lib/calamares/modules/
                      cp -rT ${./calamares-patches/branding}                                $out/etc/calamares/branding/
                      cp -rT ${./calamares-patches/branding}                                $out/share/calamares/branding/
                      cp ${../packages/foxflake-logos/foxflake-neon-logo.png}               $out/share/calamares/branding/nixos/images/foxflake-neon-logo.png
                    '';
                  });
                })
              ];
            }
            (
              { config, lib, ... }:
              {
                foxflake = {
                  autoUpdate = false;
                  environment.type = "plasma";
                  environment.selection.enable = false;
                  networking.hostname = "foxflake-installer";
                };
                environment.etc = {
                  "xdg/kscreenlockerrc".text = ''
                    [Daemon]
                    Autolock=false
                    LockOnResume=false
                  '';
                  "xdg/powerdevilrc".text = ''
                    [AC][Display]
                    DimDisplayWhenIdle=false
                    TurnOffDisplayWhenIdle=false

                    [AC][SuspendAndShutdown]
                    AutoSuspendAction=0

                    [Battery][Display]
                    DimDisplayWhenIdle=false
                    TurnOffDisplayWhenIdle=false

                    [Battery][SuspendAndShutdown]
                    AutoSuspendAction=0

                    [LowBattery][Display]
                    DimDisplayWhenIdle=false
                    TurnOffDisplayWhenIdle=false

                    [LowBattery][SuspendAndShutdown]
                    AutoSuspendAction=0
                  '';
                };
                programs.bash.loginShellInit = ''
                  if [ "$XDG_VTNR" = 1 ] && [ -z "$WAYLAND_DISPLAY" ]; then
                    exec startplasma-wayland
                  fi
                '';
                services = {
                  fwupd.enable = false;
                  getty.autologinUser = "nixos";
                  displayManager = {
                    sddm.enable = lib.mkForce false;
                    plasma-login-manager.enable = lib.mkForce false;
                  };
                };
                system = {
                  activationScripts.installerDesktop = lib.mkForce "";
                  nixos.label = lib.mkForce "";
                };
                systemd.tmpfiles.settings."10-installer-desktop" = lib.mkForce { };
                virtualisation.hypervGuest.enable = lib.mkForce false;
                virtualisation.xen.enable = lib.mkForce false;
                image.baseName = lib.mkForce "foxflake-${config.isoImage.edition}-${pkgs.stdenv.hostPlatform.uname.processor}";
                isoImage = {
                  appendToMenuLabel = " Installer";
                  edition = "installer";
                  grubTheme = pkgs.minimal-grub-theme;
                  volumeID = config.image.baseName;
                  includeSystemBuildDependencies = false;
                  storeContents = [ config.system.build.toplevel ];
                  contents = [
                    {
                      source = ./target-configuration;
                      target = "/target-configuration";
                    }
                  ];
                };
              }
            )
          ];
        };
      };
    };

}
