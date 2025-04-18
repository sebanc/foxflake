{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  options.foxflake.stateVersion = mkOption {
    description = "Initially installed FoxFlake version.";
    type = types.str;
    default = config.system.nixos.release;
  };

  config = {

    system.nixos.distroName = "FoxFlake";
    system.nixos.distroId = "foxflake";
    system.stateVersion = mkDefault config.foxflake.stateVersion;

  };

}
