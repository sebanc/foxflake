{

  description = "FoxFlake";

  inputs = {
    foxflake.url = "git+https://github.com/sebanc/foxflake?shallow=1&ref=dev";
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
