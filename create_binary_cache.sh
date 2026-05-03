#!/usr/bin/env bash

set -e

git clone -b ${1} https://github.com/sebanc/foxflake.git ./foxflake-${1}
nix flake update --flake ./foxflake-${1}
if [ "${1}" == "stable" ] || [ "${1}" == "unstable" ]; then
	for environment in "cosmic" "gnome" "hyprland" "plasma" "steam" "steamdeck"; do
		for nvidia in "" "-nvidia"; do
			cat >./flake.nix <<MAIN_FLAKE
{

  description = "FoxFlake";
  inputs = {
    foxflake.url = "file://${PWD}/foxflake-${1}";
    nixpkgs.follows = "foxflake/nixpkgs";
  };
  outputs = { foxflake, nixpkgs, ... }:
    let
      pkgs = import nixpkgs { config.allowUnfree = true; system = "x86_64-linux"; };
      system = "x86_64-linux";
    in
    rec
    {
      nixosConfigurations = {
        "foxflake-${1}-${environment}${nvidia}" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            foxflake.nixosModules.default
            {
              foxflake.environment.type = "${environment}";
              foxflake.system.bundles = [ "full" ];
              foxflake.system.packages = with pkgs; [ ];
              $(if [ "${nvidia}" == "-nvidia" ]; then echo "foxflake.nvidia.enable = true;"; else echo "foxflake.nvidia.enable = false;"; fi)
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
			nix build --no-link --max-jobs auto .#nixosConfigurations.foxflake-${1}-${environment}${nvidia}.config.system.build.toplevel
		done
	done
else
	#for environment in "cosmic" "gnome" "hyprland" "plasma" "steam" "steamdeck"; do
	for environment in "plasma"; do
		for nvidia in "" "-nvidia"; do
			cat >./flake.nix <<MAIN_FLAKE
{

  description = "FoxFlake";
  inputs = {
    foxflake.url = "file://${PWD}/foxflake-${1}";
    nixpkgs.follows = "foxflake/nixpkgs";
  };
  outputs = { foxflake, nixpkgs, ... }:
    let
      pkgs = import nixpkgs { config.allowUnfree = true; system = "x86_64-linux"; };
      system = "x86_64-linux";
    in
    rec
    {
      nixosConfigurations = {
        "foxflake-${1}-${environment}${nvidia}" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            foxflake.nixosModules.default
            {
              foxflake.environment.type = "${environment}";
              foxflake.system.bundles = [ "full" ];
              foxflake.system.packages = with pkgs; [ ];
              $(if [ "${nvidia}" == "-nvidia" ]; then echo "foxflake.nvidia.enable = true;"; else echo "foxflake.nvidia.enable = false;"; fi)
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
			nix build --no-link --max-jobs auto .#nixosConfigurations.foxflake-${1}-${environment}${nvidia}.config.system.build.toplevel
		done
	done
fi
#cp ./foxflake-${1}/flake.lock /home/runner/work/foxflake/foxflake/foxflake-${1}-flake.lock

