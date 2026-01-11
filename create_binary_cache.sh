#!/usr/bin/env bash

set -e

cat >/tmp/upload-to-cache.sh <<BUILD_OUTPUT
#!/usr/bin/env bash

set -eu
set -f # disable globbing
export IFS=' '

echo "Uploading paths" \$OUT_PATHS
exec nix copy --to "file:///tmp/foxflake-binary-cache" \$OUT_PATHS
BUILD_OUTPUT
chmod 0755 /tmp/upload-to-cache.sh

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
	git clone -b stable https://github.com/sebanc/foxflake.git foxflake-${branch}
	nix flake update --flake ./foxflake-${branch}
done

mkdir /tmp/foxflake-binary-cache
for version in "stable" "unstable"; do
	for environment in "cosmic" "gnome" "plasma"; do
		for nvidia in "" "-nvidia"; do
			nix build .#nixosConfigurations.foxflake-${version}-${environment}${nvidia}.config.system.build.toplevel
			nix-collect-garbage -d
		done
	done
done
rm /tmp/foxflake-binary-cache.priv

cp ./foxflake-stable/flake.lock /tmp/foxflake-stable-flake.lock
cp ./foxflake-stable-test/flake.lock /tmp/foxflake-stable-test-flake.lock
cp ./foxflake-unstable/flake.lock /tmp/foxflake-unstable-flake.lock
cp ./foxflake-unstable-test/flake.lock /tmp/foxflake-unstable-test-flake.lock
cp ./foxflake-dev/flake.lock /tmp/foxflake-dev-flake.lock

cd /tmp/foxflake-binary-cache
echo -e '<html><body><h1>FoxFlake binary cache</h1></body></html>' > index.html
echo -e 'StoreDir: /nix/store\nWantMassQuery: 1\nPriority: 60' > nix-cache-info
echo 'http(s)://sebanc.github.io/foxflake' > binary-cache-url
cd ..

