#!/usr/bin/env bash

set -e

#cat >/home/runner/work/foxflake/foxflake/upload-to-cache.sh <<BUILD_OUTPUT
#!/bin/sh
#
#set -eu
#set -f
#
#export IFS=' '
#
#(
#  exec >> /tmp/nix-upload.log 2>&1
#  
#  echo "Uploading paths: \$OUT_PATHS"
#  
#  nix copy --to "file:///home/runner/work/foxflake/foxflake/foxflake-binary-cache" \$OUT_PATHS
#) &
#
#exit 0
#BUILD_OUTPUT
#chmod 0755 /home/runner/work/foxflake/foxflake/upload-to-cache.sh

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
git add flake.nix

for branch in "stable" "stable-test" "unstable" "unstable-test" "dev"; do
	git clone -b ${branch} https://github.com/sebanc/foxflake.git foxflake-${branch}
	nix flake update --flake ./foxflake-${branch}
done

mkdir /home/runner/work/foxflake/foxflake/foxflake-binary-cache
for version in "stable" "unstable"; do
	for environment in "cosmic" "gnome" "plasma"; do
		for nvidia in "" "-nvidia"; do
			nix build --no-link --no-update-lock-file .#nixosConfigurations.foxflake-${version}-${environment}${nvidia}.config.system.build.toplevel
			#nix copy --to file:///home/runner/work/foxflake/foxflake/foxflake-binary-cache $(nix path-info --recursive --json --json-format 1 .#nixosConfigurations.foxflake-${version}-${environment}${nvidia}.config.system.build.toplevel | jq -r 'to_entries[] | select(.value.ultimate == true) | .key')
		done
	done
	nix-collect-garbage -d
done
#rm /home/runner/work/foxflake/foxflake/foxflake-binary-cache.priv
#for narinfo in $(ls /home/runner/work/foxflake/foxflake/foxflake-binary-cache/*.narinfo | sed 's@.narinfo@@g' | sed 's@/home/runner/work/foxflake/foxflake/foxflake-binary-cache/@@g'); do
#	narbin=$(cat /home/runner/work/foxflake/foxflake/foxflake-binary-cache/${narinfo}.narinfo | grep 'URL: ' | cut -d' ' -f2 | cut -d'?' -f1)
#	if [ ! -f /home/runner/work/foxflake/foxflake/foxflake-binary-cache/${narbin} ] || curl --fail --silent "https://cache.nixos.org/${narinfo}.narinfo" 2>&1 > /dev/null || curl --fail --silent "https://cache.nixos-cuda.org/${narinfo}.narinfo" 2>&1 > /dev/null; then
#		echo "Removing cache ${narinfo} from ${narbin}"
#		rm -f /home/runner/work/foxflake/foxflake/foxflake-binary-cache/${narinfo}.narinfo /home/runner/work/foxflake/foxflake/foxflake-binary-cache/${narbin}
#	else
#		echo "Keeping cache ${narinfo} from ${narbin}"
#	fi
#done

cp ./foxflake-stable/flake.lock /home/runner/work/foxflake/foxflake/foxflake-stable-flake.lock
cp ./foxflake-stable-test/flake.lock /home/runner/work/foxflake/foxflake/foxflake-stable-test-flake.lock
cp ./foxflake-unstable/flake.lock /home/runner/work/foxflake/foxflake/foxflake-unstable-flake.lock
cp ./foxflake-unstable-test/flake.lock /home/runner/work/foxflake/foxflake/foxflake-unstable-test-flake.lock
cp ./foxflake-dev/flake.lock /home/runner/work/foxflake/foxflake/foxflake-dev-flake.lock

#cd /home/runner/work/foxflake/foxflake/foxflake-binary-cache
#echo -e '<html><body><h1>FoxFlake binary cache</h1></body></html>' > index.html
#echo -e 'StoreDir: /nix/store\nWantMassQuery: 1\nPriority: 60' > nix-cache-info
#echo 'https://sebanc.github.io/foxflake' > binary-cache-url
#cd ..

