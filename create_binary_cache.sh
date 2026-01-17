#!/usr/bin/env bash

set -e

cat >./flake.nix <<MAIN_FLAKE
{

  description = "FoxFlake";

  inputs = {
    foxflake-${1}.url = "git+file://${PWD}/foxflake-${1}";
  };

  outputs =
    { foxflake-${1}, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    rec
    {
      nixosConfigurations = {
        "foxflake-${1}-cosmic" = inputs.foxflake-${1}.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake-${1}.nixosModules.default
            {
              foxflake.environment.type = "cosmic";
              foxflake.system.bundles = [ "standard" "gaming" "studio" ];
              foxflake.system.packages = with (import inputs.foxflake-${1}.inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; }); [ ollama-rocm ];
              foxflake.system.waydroid = true;
              foxflake.nvidia.enable = false;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-${1}-cosmic-nvidia" = inputs.foxflake-${1}.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake-${1}.nixosModules.default
            {
              foxflake.environment.type = "cosmic";
              foxflake.system.bundles = [ "standard" "gaming" "studio" ];
              foxflake.system.packages = with (import inputs.foxflake-${1}.inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; }); [ ollama-cuda ];
              foxflake.system.waydroid = true;
              foxflake.nvidia.enable = true;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-${1}-gnome" = inputs.foxflake-${1}.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake-${1}.nixosModules.default
            {
              foxflake.environment.type = "gnome";
              foxflake.system.bundles = [ "standard" "gaming" "studio" ];
              foxflake.system.packages = with (import inputs.foxflake-${1}.inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; }); [ ollama-rocm ];
              foxflake.system.waydroid = true;
              foxflake.nvidia.enable = false;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-${1}-gnome-nvidia" = inputs.foxflake-${1}.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake-${1}.nixosModules.default
            {
              foxflake.environment.type = "gnome";
              foxflake.system.bundles = [ "standard" "gaming" "studio" ];
              foxflake.system.packages = with (import inputs.foxflake-${1}.inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; }); [ ollama-cuda ];
              foxflake.system.waydroid = true;
              foxflake.nvidia.enable = true;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-${1}-plasma" = inputs.foxflake-${1}.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake-${1}.nixosModules.default
            {
              foxflake.environment.type = "plasma";
              foxflake.system.bundles = [ "standard" "gaming" "studio" ];
              foxflake.system.packages = with (import inputs.foxflake-${1}.inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; }); [ ollama-rocm ];
              foxflake.system.waydroid = true;
              foxflake.nvidia.enable = false;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-${1}-plasma-nvidia" = inputs.foxflake-${1}.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake-${1}.nixosModules.default
            {
              foxflake.environment.type = "plasma";
              foxflake.system.bundles = [ "standard" "gaming" "studio" ];
              foxflake.system.packages = with (import inputs.foxflake-${1}.inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; }); [ ollama-cuda ];
              foxflake.system.waydroid = true;
              foxflake.nvidia.enable = true;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
      };
    };

}
MAIN_FLAKE
git add flake.nix

git clone -b ${1} https://github.com/sebanc/foxflake.git foxflake-${1}
for environment in "cosmic" "gnome" "plasma"; do
	for nvidia in "" "-nvidia"; do
		nix build --no-link .#nixosConfigurations.foxflake-${1}-${environment}${nvidia}.config.system.build.toplevel
	done
done
for cuda_store_path in $(find /nix/store -depth -maxdepth 1 -type d | grep -E '(-cuda.*-)'); do sudo rm -r ${cuda_store_path}; done
cp ./foxflake-${1}/flake.lock /home/runner/work/foxflake/foxflake/foxflake-${1}-flake.lock

