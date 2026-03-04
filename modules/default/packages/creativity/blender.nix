{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "studio" config.foxflake.system.applications || builtins.elem "blender" config.foxflake.system.applications) {

    environment.systemPackages = with pkgs; [ (blender.override { rocmSupport = true; }) ];

  };

}
