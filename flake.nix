{

  description = "FoxFlake stable branch";

  inputs = {
    nixpkgs.url = "git+https://github.com/nixos/nixpkgs?shallow=1&ref=nixos-25.11";
    nixpkgs-unstable.url = "git+https://github.com/nixos/nixpkgs?shallow=1&ref=nixos-unstable";
    home-manager = {
      url = "git+https://github.com/nix-community/home-manager?shallow=1&ref=release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "git+https://github.com/nix-community/plasma-manager?shallow=1&ref=trunk";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-flatpak.url = "git+https://github.com/gmodena/nix-flatpak?shallow=1&ref=refs/tags/latest";
  };

  outputs =
    { nixpkgs, nixpkgs-unstable, home-manager, plasma-manager, nix-flatpak, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosModules = rec {
        foxflake = {
          imports = [
            { nix.settings.experimental-features = [ "nix-command" "flakes" ]; }
            { nixpkgs.config.allowUnfree = true; }
            {
              nixpkgs.overlays = [
                (final: prev: {
                  unstable = import nixpkgs-unstable {
                    inherit prev;
                    inherit system;
                    config.allowUnfree = true;
                  };
                })
              ];
            }
            ./modules/default
            inputs.home-manager.nixosModules.home-manager
            inputs.nix-flatpak.nixosModules.nix-flatpak
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager inputs.nix-flatpak.homeManagerModules.nix-flatpak ./modules/home ];
            }
          ];
        };
        default = foxflake;
      };
    };

}
