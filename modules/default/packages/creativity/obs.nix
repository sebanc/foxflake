{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "studio" config.foxflake.system.applications || builtins.elem "obs" config.foxflake.system.applications) {

    environment.systemPackages = with pkgs; [ obs-studio obs-studio-plugins.obs-vkcapture ];

  };

}
