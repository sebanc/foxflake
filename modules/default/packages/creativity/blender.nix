{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "studio" config.foxflake.system.applications || builtins.elem "blender" config.foxflake.system.applications) {

    environment.systemPackages =
      if (config.foxflake.nvidia.enable) then
        [ (pkgs.stable.blender.override { cudaSupport = true; rocmSupport = true; }) ]
      else
        [ (pkgs.stable.blender.override { rocmSupport = true; }) ];

  };

}
