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
      (blender.override { hipSupport = true; })
      gimp
      inkscape-with-extensions
      kdePackages.kdenlive
      obs-studio
      obs-studio-plugins.obs-vkcapture
    ];

  };

}
