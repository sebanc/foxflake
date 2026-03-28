#!/usr/bin/env bash

set -e

cat >./flake.nix <<MAIN_FLAKE
{

  description = "FoxFlake";

  inputs = {
    foxflake.url = "git+file://${PWD}/foxflake-${1}";
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
        "foxflake-${1}-cosmic" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            foxflake.nixosModules.default
            {
              foxflake.environment.type = "cosmic";
              foxflake.system.bundles = [ "full" ];
              foxflake.system.packages = with pkgs; [ ];
              foxflake.nvidia.enable = false;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-${1}-cosmic-nvidia" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            foxflake.nixosModules.default
            {
              foxflake.environment.type = "cosmic";
              foxflake.system.bundles = [ "full" ];
              foxflake.system.packages = with pkgs; [ ];
              foxflake.nvidia.enable = true;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-${1}-gnome" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            foxflake.nixosModules.default
            {
              foxflake.environment.type = "gnome";
              foxflake.system.bundles = [ "full" ];
              foxflake.system.packages = with pkgs; [ ];
              foxflake.nvidia.enable = false;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-${1}-gnome-nvidia" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            foxflake.nixosModules.default
            {
              foxflake.environment.type = "gnome";
              foxflake.system.bundles = [ "full" ];
              foxflake.system.packages = with pkgs; [ ];
              foxflake.nvidia.enable = true;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-${1}-hyprland" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            foxflake.nixosModules.default
            {
              foxflake.environment.type = "hyprland";
              foxflake.system.bundles = [ "full" ];
              foxflake.system.packages = with pkgs; [ ];
              foxflake.nvidia.enable = false;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-${1}-hyprland-nvidia" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            foxflake.nixosModules.default
            {
              foxflake.environment.type = "hyprland";
              foxflake.system.bundles = [ "full" ];
              foxflake.system.packages = with pkgs; [ ];
              foxflake.nvidia.enable = true;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-${1}-plasma" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            foxflake.nixosModules.default
            {
              foxflake.environment.type = "plasma";
              foxflake.system.bundles = [ "full" ];
              foxflake.system.packages = with pkgs; [ ];
              foxflake.nvidia.enable = false;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-${1}-plasma-nvidia" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            foxflake.nixosModules.default
            {
              foxflake.environment.type = "plasma";
              foxflake.system.bundles = [ "full" ];
              foxflake.system.packages = with pkgs; [ ];
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

git clone -b ${1} https://github.com/sebanc/foxflake.git ./foxflake-${1}
nix flake update --flake ./foxflake-${1}
if [ "${1}" == "stable" ] || [ "${1}" == "unstable" ]; then
	for environment in "cosmic" "gnome" "plasma"; do
		for nvidia in "" "-nvidia"; do
			nix build --no-link --max-jobs 2 .#nixosConfigurations.foxflake-${1}-${environment}${nvidia}.config.system.build.toplevel
		done
	done
else
	for environment in "cosmic" "gnome" "hyprland" "plasma"; do
		for nvidia in "" "-nvidia"; do
			nix build --no-link --max-jobs 2 .#nixosConfigurations.foxflake-${1}-${environment}${nvidia}.config.system.build.toplevel
		done
	done
fi

cp ./foxflake-${1}/flake.lock /home/runner/work/foxflake/foxflake/foxflake-${1}-flake.lock

