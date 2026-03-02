{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "corectrl" config.foxflake.system.applications) {

    programs.corectrl.enable = mkDefault true;

  };

}
