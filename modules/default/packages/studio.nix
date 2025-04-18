{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "studio" config.foxflake.system.bundles) {

    environment.variables = if (builtins.elem "amdgpu" config.services.xserver.videoDrivers) then
      {
        RUSTICL_ENABLE="radeonsi";
        ROC_ENABLE_PRE_VEGA = "1";
      }
    else
      {
      };

    environment.systemPackages = with pkgs; [
      blender
      obs-studio
      obs-studio-plugins.obs-vkcapture
      kdePackages.kdenlive 
      davinci-resolve
      gimp
      audacity
      freetube
      ];

  };

}
