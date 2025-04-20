{

  description = "FoxFlake";

  inputs = {
    foxflake.url = "github:sebanc/foxflake/stable-test";
  };

  outputs =
    { foxflake, ... }@inputs:
    let
      system = "x86_64-linux";
      nixpkgs = inputs.foxflake.inputs.nixpkgs;
    in
    {
      nixosConfigurations."foxflake" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          inputs.foxflake.nixosModules.default
        ];
      };
    };

}
