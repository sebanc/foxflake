{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "element" config.foxflake.system.applications) {

    environment.systemPackages = with pkgs; [ element-desktop ];

  };

}
