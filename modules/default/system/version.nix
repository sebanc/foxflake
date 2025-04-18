{
  lib,
  config,
  pkgs,
  ...
}:

  config = {

    system.nixos.distroName = "FoxFlake";
    system.nixos.distroId = "foxflake";
    system.stateVersion = mkDefault config.foxflake.stateVersion;

  };

}
