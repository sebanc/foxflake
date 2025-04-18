{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = {

    system.nixos.distroName = "FoxFlake";
    system.nixos.distroId = "foxflake";
    system.stateVersion = mkDefault config.foxflake.stateVersion;

  };

}
