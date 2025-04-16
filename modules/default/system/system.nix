{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  options.foxflake.system.enable = mkOption {
    description = "Enable FoxFlake systems configurations";
    type = types.bool;
    default = true;
  };

  config = mkIf config.foxflake.system.enable {

    documentation.nixos.enable = mkDefault false;

    zramSwap.enable = mkDefault true;

    nix = {
      gc = {
        automatic = mkDefault true;
        dates = mkDefault "weekly";
        options = mkDefault "--delete-older-than 30d";
      };
      settings = {
        auto-optimise-store = mkDefault true;
        cores = mkDefault 4;
      };
    };

  };

}
