{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "lexmarkps" config.foxflake.system.applications) {

    services.printing.drivers = with pkgs; [ postscript-lexmark ];

  };

}
