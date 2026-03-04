{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "chromium" config.foxflake.system.applications) {

    environment.systemPackages = with pkgs; [ chromium ];

  };

}
