#!/usr/bin/env bash

set -e

mkdir -p ${HOME}/.local/share/nix
cat >${HOME}/.local/share/nix/upload-to-cache.sh <<BUILD_OUTPUT
#!/bin/sh

set -eu
set -f # disable globbing
export IFS=' '

echo "Uploading paths" \$OUT_PATHS
exec nix copy --to "${PWD}/foxflake-binary-cache" \$OUT_PATHS
BUILD_OUTPUT
chmod 0755 ${HOME}/.local/share/nix/upload-to-cache.sh
cat >${HOME}/.local/share/nix/nix.conf <<NIX_CONFIGURATION
post-build-hook = ${HOME}/.local/share/nix/upload-to-cache.sh
secret-key-files = /tmp/foxflake-binary-cache.priv
substituters = https://cache.nixos-cuda.org/ https://cache.nixos.org/
trusted-substituters = https://cache.nixos-cuda.org/ https://cache.nixos.org/
trusted-public-keys = cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
NIX_CONFIGURATION

cat >./flake.nix <<MAIN_FLAKE
{

  description = "FoxFlake";

  inputs = {
    foxflake-stable.url = "git+file://${PWD}/foxflake-stable";
    foxflake-unstable.url = "git+file://${PWD}/foxflake-unstable";
  };

  outputs =
    { foxflake-stable, foxflake-unstable, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    rec
    {
      nixosConfigurations = {
        "foxflake-stable-cosmic" = inputs.foxflake-stable.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake-stable.nixosModules.default
            {
              foxflake.environment.type = "cosmic";
              foxflake.system.bundles = [ "standard" "gaming" "studio" ];
              foxflake.system.packages = with (import inputs.foxflake-stable.inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; }); [ ];
              foxflake.system.waydroid = true;
              foxflake.nvidia.enable = false;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-stable-cosmic-nvidia" = inputs.foxflake-stable.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake-stable.nixosModules.default
            {
              foxflake.environment.type = "cosmic";
              foxflake.system.bundles = [ "standard" "gaming" "studio" ];
              foxflake.system.packages = with (import inputs.foxflake-stable.inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; }); [ ];
              foxflake.system.waydroid = true;
              foxflake.nvidia.enable = true;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-stable-gnome" = inputs.foxflake-stable.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake-stable.nixosModules.default
            {
              foxflake.environment.type = "gnome";
              foxflake.system.bundles = [ "standard" "gaming" "studio" ];
              foxflake.system.packages = with (import inputs.foxflake-stable.inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; }); [ ];
              foxflake.system.waydroid = true;
              foxflake.nvidia.enable = false;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-stable-gnome-nvidia" = inputs.foxflake-stable.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake-stable.nixosModules.default
            {
              foxflake.environment.type = "gnome";
              foxflake.system.bundles = [ "standard" "gaming" "studio" ];
              foxflake.system.packages = with (import inputs.foxflake-stable.inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; }); [ ];
              foxflake.system.waydroid = true;
              foxflake.nvidia.enable = true;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-stable-plasma" = inputs.foxflake-stable.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake-stable.nixosModules.default
            {
              foxflake.environment.type = "plasma";
              foxflake.system.bundles = [ "standard" "gaming" "studio" ];
              foxflake.system.packages = with (import inputs.foxflake-stable.inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; }); [ ];
              foxflake.system.waydroid = true;
              foxflake.nvidia.enable = false;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-stable-plasma-nvidia" = inputs.foxflake-stable.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake-stable.nixosModules.default
            {
              foxflake.environment.type = "plasma";
              foxflake.system.bundles = [ "standard" "gaming" "studio" ];
              foxflake.system.packages = with (import inputs.foxflake-stable.inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; }); [ ];
              foxflake.system.waydroid = true;
              foxflake.nvidia.enable = true;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-unstable-cosmic" = inputs.foxflake-unstable.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake-unstable.nixosModules.default
            {
              foxflake.environment.type = "cosmic";
              foxflake.system.bundles = [ "standard" "gaming" "studio" ];
              foxflake.system.packages = with (import inputs.foxflake-unstable.inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; }); [ ];
              foxflake.system.waydroid = true;
              foxflake.nvidia.enable = false;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-unstable-cosmic-nvidia" = inputs.foxflake-unstable.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake-unstable.nixosModules.default
            {
              foxflake.environment.type = "cosmic";
              foxflake.system.bundles = [ "standard" "gaming" "studio" ];
              foxflake.system.packages = with (import inputs.foxflake-unstable.inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; }); [ ];
              foxflake.system.waydroid = true;
              foxflake.nvidia.enable = true;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-unstable-gnome" = inputs.foxflake-unstable.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake-unstable.nixosModules.default
            {
              foxflake.environment.type = "gnome";
              foxflake.system.bundles = [ "standard" "gaming" "studio" ];
              foxflake.system.packages = with (import inputs.foxflake-unstable.inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; }); [ ];
              foxflake.system.waydroid = true;
              foxflake.nvidia.enable = false;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-unstable-gnome-nvidia" = inputs.foxflake-unstable.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake-unstable.nixosModules.default
            {
              foxflake.environment.type = "gnome";
              foxflake.system.bundles = [ "standard" "gaming" "studio" ];
              foxflake.system.packages = with (import inputs.foxflake-unstable.inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; }); [ ];
              foxflake.system.waydroid = true;
              foxflake.nvidia.enable = true;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-unstable-plasma" = inputs.foxflake-unstable.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake-unstable.nixosModules.default
            {
              foxflake.environment.type = "plasma";
              foxflake.system.bundles = [ "standard" "gaming" "studio" ];
              foxflake.system.packages = with (import inputs.foxflake-unstable.inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; }); [ ];
              foxflake.system.waydroid = true;
              foxflake.nvidia.enable = false;
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        };
        "foxflake-unstable-plasma-nvidia" = inputs.foxflake-unstable.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.foxflake-unstable.nixosModules.default
            {
              foxflake.environment.type = "plasma";
              foxflake.system.bundles = [ "standard" "gaming" "studio" ];
              foxflake.system.packages = with (import inputs.foxflake-unstable.inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; }); [ ];
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

git clone -b stable https://github.com/sebanc/foxflake.git foxflake-stable
nix flake update --flake ./foxflake-stable
cp ./foxflake-stable/flake.lock /tmp/foxflake-stable-flake.lock

git clone -b stable-test https://github.com/sebanc/foxflake.git foxflake-stable-test
nix flake update --flake ./foxflake-stable-test
cp ./foxflake-stable-test/flake.lock /tmp/foxflake-stable-test-flake.lock

git clone -b unstable https://github.com/sebanc/foxflake.git foxflake-unstable
nix flake update --flake ./foxflake-unstable
cp ./foxflake-unstable/flake.lock /tmp/foxflake-unstable-flake.lock

git clone -b unstable-test https://github.com/sebanc/foxflake.git foxflake-unstable-test
nix flake update --flake ./foxflake-unstable-test
cp ./foxflake-unstable-test/flake.lock /tmp/foxflake-unstable-test-flake.lock

git clone -b dev https://github.com/sebanc/foxflake.git foxflake-dev
nix flake update --flake ./foxflake-dev
cp ./foxflake-dev/flake.lock /tmp/foxflake-dev-flake.lock

mkdir ./foxflake-binary-cache
nix build .#nixosConfigurations.foxflake-stable-cosmic.config.system.build.toplevel
nix build .#nixosConfigurations.foxflake-stable-cosmic-nvidia.config.system.build.toplevel
nix build .#nixosConfigurations.foxflake-stable-gnome.config.system.build.toplevel
nix build .#nixosConfigurations.foxflake-stable-gnome-nvidia.config.system.build.toplevel
nix build .#nixosConfigurations.foxflake-stable-plasma.config.system.build.toplevel
nix build .#nixosConfigurations.foxflake-stable-plasma-nvidia.config.system.build.toplevel
nix build .#nixosConfigurations.foxflake-unstable-cosmic.config.system.build.toplevel
nix build .#nixosConfigurations.foxflake-unstable-cosmic-nvidia.config.system.build.toplevel
nix build .#nixosConfigurations.foxflake-unstable-gnome.config.system.build.toplevel
nix build .#nixosConfigurations.foxflake-unstable-gnome-nvidia.config.system.build.toplevel
nix build .#nixosConfigurations.foxflake-unstable-plasma.config.system.build.toplevel
nix build .#nixosConfigurations.foxflake-unstable-plasma-nvidia.config.system.build.toplevel
rm /tmp/foxflake-binary-cache.priv

cd ./foxflake-binary-cache
echo -e '<html><body><h1>FoxFlake binary cache</h1></body></html>' > index.html
echo -e 'StoreDir: /nix/store\nWantMassQuery: 1\nPriority: 60' > nix-cache-info
echo 'http(s)://sebanc.github.io/foxflake' > binary-cache-url
cd ..

