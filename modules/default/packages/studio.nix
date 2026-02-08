{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "studio" config.foxflake.system.bundles) {

    environment.systemPackages = with pkgs; [
      audacity
      (blender.override { rocmSupport = true; })
      gimp
      inkscape-with-extensions
      (pkgs.kdePackages.kdenlive.override { ffmpeg-full = pkgs.ffmpeg_7-full; })
      obs-studio
      obs-studio-plugins.obs-vkcapture
    ];

  };

}
