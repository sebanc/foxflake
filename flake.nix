{

  description = "FoxFlake Unstable";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=main";
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
                    system = prev.system;
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
