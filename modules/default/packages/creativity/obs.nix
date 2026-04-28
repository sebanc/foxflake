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
      package = mkDefault pkgs.stable.obs-studio;
      plugins = with pkgs.stable.obs-studio-plugins; [ advanced-scene-switcher input-overlay obs-backgroundremoval obs-composite-blur obs-gstreamer obs-move-transition obs-multi-rtmp obs-pipewire-audio-capture obs-shaderfilter obs-vaapi obs-vkcapture wlrobs ];
    };

  };

}
