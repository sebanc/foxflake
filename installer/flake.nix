{
  description = "FoxFlake";

  inputs = {
    foxflake.url = "github:sebanc/foxflake/stable";
    nixpkgs.follows = "foxflake/nixpkgs";
  };

  outputs =
    { self, foxflake, nixpkgs, ... }:
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
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
            {
              nixpkgs.overlays = [
                (_self: super: {
                  calamares-nixos-extensions = super.calamares-nixos-extensions.overrideAttrs (oldAttrs: {
                    postInstall = oldAttrs.postInstall or "" + ''
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
                  autoUpgrade = false;
                  environment.type = "gnome";
                  environment.selection.enable = false;
                  system.applications = [ ];
                };
                networking.hostName = "foxflake-installer";
                services.fwupd.enable = false;
                system.nixos.label = "";
                specialisation = {
                  nvidia_open = {
                    configuration = {
                      isoImage.appendToMenuLabel = lib.mkForce " Installer (with Nvidia open source kernel driver)";
                      foxflake.nvidia.enable = true;
                    };
                  };
                };
                nixpkgs.config.packageOverrides = pkgs: {
                  calamares = pkgs.calamares.overrideAttrs (oldAttrs: {
                    patches = (oldAttrs.patches or []) ++ [
                      (pkgs.writeText "pixmapfix.patch" ''
                        diff --git a/src/modules/users/UsersPage.cpp b/src/modules/users/UsersPage.cpp
                        index e602b87ea..b6867bfa9 100644
                        --- a/src/modules/users/UsersPage.cpp
                        +++ b/src/modules/users/UsersPage.cpp
                        @@ -38,7 +38,7 @@ static inline void
                         labelError( QLabel* pix, QLabel* label, Calamares::ImageType icon, const QString& message )
                         {
                             label->setText( message );
                        -    pix->setPixmap( Calamares::defaultPixmap( icon, Calamares::Original, label->size() ) );
                        +    pix->setPixmap( Calamares::defaultPixmap( icon, Calamares::Original, pix->size() ) );
                         }
                         
                         /** @brief Clear error, set happy pixmap on a label to indicate "ok". */
                        @@ -46,7 +46,7 @@ static inline void
                         labelOk( QLabel* pix, QLabel* label )
                         {
                             label->clear();
                        -    pix->setPixmap( Calamares::defaultPixmap( Calamares::StatusOk, Calamares::Original, label->size() ) );
                        +    pix->setPixmap( Calamares::defaultPixmap( Calamares::StatusOk, Calamares::Original, pix->size() ) );
                         }
                         
                         /** @brief Sets error or ok on a label depending on @p status and @p value
                      '')
                    ];
                    postInstall = (oldAttrs.postInstall or "") + ''
                      if [ -f "$out/share/applications/calamares.desktop" ]; then
                        ${pkgs.gnused}/bin/sed -i 's@pkexec calamares@sudo calamares@g' "$out/share/applications/calamares.desktop"
                      fi
                    '';
                  });
                };
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
