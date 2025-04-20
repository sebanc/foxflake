{
  description = "FoxFlake";

  inputs = {
    foxflake.url = "github:sebanc/foxflake/stable";
  };

  outputs =
    { self, foxflake, ... }@inputs:
    let
      system = "x86_64-linux";
      # Use nixpkgs-unstable for the installer until switch to 25.05 to support specialisations
      #nixpkgs = inputs.foxflake.inputs.nixpkgs;
      nixpkgs = inputs.foxflake.inputs.nixpkgs-unstable;
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
                      mkdir -p $out/lib/calamares/modules/foxflake
                      cp ${./calamares-patches/modules/foxflake/main.py}                    $out/lib/calamares/modules/foxflake/main.py
                      cp ${./calamares-patches/modules/foxflake/module.desc}                $out/lib/calamares/modules/foxflake/module.desc
                      cp ${./calamares-patches/branding/nixos/branding.desc}                $out/share/calamares/branding/nixos/branding.desc
                      cp ${../packages/foxflake-logos/foxflake-logo-light.png}              $out/share/calamares/branding/nixos/foxflake-logo-light.png
                      cp ${./calamares-patches/config/settings.conf}                        $out/share/calamares/settings.conf
                      cp ${./calamares-patches/config/modules/bundles.conf}                 $out/share/calamares/modules/bundles.conf
                      cp ${./calamares-patches/config/modules/environment.conf}             $out/share/calamares/modules/environment.conf
                      cp ${./calamares-patches/config/modules/users.conf}                   $out/share/calamares/modules/users.conf
                      cp ${./calamares-patches/config/modules/waydroid.conf}                $out/share/calamares/modules/waydroid.conf
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
                specialisation = {
                  nvidia = {
                    configuration = {
                      system.nixos.tags = lib.mkForce [ "nvidia_driver" ];
                      foxflake.nvidia.enable = true;
                    };
                  };
                };
                image.baseName = lib.mkForce "foxflake-${config.isoImage.edition}-${pkgs.stdenv.hostPlatform.uname.processor}";
                isoImage = {
                  grubTheme = (pkgs.sleek-grub-theme.override { withBanner = "FoxFlake installer"; withStyle = "light"; });
                  edition = "installer";
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
