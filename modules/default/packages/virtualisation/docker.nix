{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "distrobox" config.foxflake.system.applications) {

    virtualisation.docker.enable = mkDefault true;

  };

}
