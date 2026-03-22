{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "lact" config.foxflake.system.applications) {

    services.lact.enable = mkDefault true;

  };

}
