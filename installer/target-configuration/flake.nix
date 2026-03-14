{

  description = "FoxFlake";

  inputs = {
    foxflake.url = "github:sebanc/foxflake/unstable-test";
    nixpkgs.follows = "foxflake/nixpkgs";
  };

  outputs = { foxflake, nixpkgs, ... }: {
    nixosConfigurations."foxflake" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        foxflake.nixosModules.default
      ];
    };
  };

}
