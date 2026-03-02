{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "darktable" config.foxflake.system.applications) {

    environment.systemPackages = with pkgs; [ darktable ];

  };

}
