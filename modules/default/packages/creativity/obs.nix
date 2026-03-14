{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "studio" config.foxflake.system.applications || builtins.elem "obs" config.foxflake.system.applications) {

    programs.obs-studio = {
      enable = mkDefault true;
      enableVirtualCamera = mkDefault true;
      plugins = with pkgs.obs-studio-plugins; [ obs-vkcapture ];
    };

  };

}
