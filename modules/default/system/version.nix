{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  options.foxflake.stateVersion = mkOption {
    type = types.str;
    default = config.system.nixos.release;
    description = "Initially installed FoxFlake version.";
  };

  config = {

    system.nixos.distroName = "FoxFlake";
    system.nixos.distroId = "foxflake";
    system.stateVersion = mkDefault config.foxflake.stateVersion;

  };

}
