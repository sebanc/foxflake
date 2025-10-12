{
  description = "FoxFlake";

  inputs = {
    foxflake.url = "github:sebanc/foxflake/stable";
  };

  outputs =
    { self, foxflake, ... }@inputs:
    let
      system = "x86_64-linux";
      nixpkgs = inputs.foxflake.inputs.nixpkgs;
      pkgs = import nixpkgs { config.allowUnfree = true; system = "x86_64-linux"; };
    in
    {
      installer = self.nixosConfigurations."foxflake-installer".config.system.build.isoImage;

      nixosConfigurations = {
        "foxflake-installer" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake.nixosModules.default
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
            {
              nixpkgs.overlays = [
                (_self: super: {
                  calamares-nixos-extensions = super.calamares-nixos-extensions.overrideAttrs (_oldAttrs: {
                    postInstall = ''
                      cp -rT ${./calamares-patches/config}                                  $out/etc/calamares/
                      cp -rT ${./calamares-patches/modules}                                 $out/lib/calamares/modules/
                      cp -rT ${./calamares-patches/branding}                                $out/share/calamares/branding/
                      cp ${../packages/foxflake-logos/foxflake-logo-light.png}              $out/share/calamares/branding/nixos/images/foxflake-logo-light.png
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
                  environment.switching.enable = false;
                  system.bundles = [ ];
                };
                system.nixos.label = "";
                specialisation = {
                  nvidia_open = {
                    configuration = {
                      isoImage.appendToMenuLabel = lib.mkForce " Installer (with Nvidia open source kernel driver)";
                      foxflake.nvidia.enable = true;
                    };
                  };
                  nvidia_proprietary = {
                    configuration = {
                      isoImage.appendToMenuLabel = lib.mkForce " Installer (with Nvidia proprietary kernel driver)";
                      foxflake.nvidia.enable = true;
                      foxflake.nvidia.open = false;
                    };
                  };
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
