{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "studio" config.foxflake.system.applications || builtins.elem "kdenlive" config.foxflake.system.applications) {

    environment.systemPackages = with pkgs; [ (pkgs.kdePackages.kdenlive.override { ffmpeg-full = pkgs.ffmpeg_7-full; }) ];

  };

}
