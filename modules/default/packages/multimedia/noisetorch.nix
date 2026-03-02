{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "noisetorch" config.foxflake.system.applications) {

    programs.noisetorch.enable = mkDefault true;

  };

}
