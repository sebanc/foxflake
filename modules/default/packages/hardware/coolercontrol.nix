{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "coolercontrol" config.foxflake.system.applications) {

    programs.coolercontrol.enable = mkDefault true;

  };

}
