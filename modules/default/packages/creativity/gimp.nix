{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "studio" config.foxflake.system.applications || builtins.elem "gimp" config.foxflake.system.applications) {

    environment.systemPackages = with pkgs; [ gimp ];

  };

}
