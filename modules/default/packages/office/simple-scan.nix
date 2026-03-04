{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "standard" config.foxflake.system.applications || builtins.elem "simple-scan" config.foxflake.system.applications) {

    environment.systemPackages = with pkgs; [ simple-scan ];

  };

}
