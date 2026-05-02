{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "librewolf" config.foxflake.system.applications) {

    environment.systemPackages = [ pkgs.stable.librewolf ];

  };

}
