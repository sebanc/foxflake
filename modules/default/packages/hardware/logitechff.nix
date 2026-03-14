{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "logitechff" config.foxflake.system.applications) {

    hardware.new-lg4ff.enable = mkDefault true;

  };

}
