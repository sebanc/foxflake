{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "gaming" config.foxflake.system.applications || builtins.elem "heroic" config.foxflake.system.applications) {

    environment.systemPackages = with pkgs; [ heroic ];

  };

}
