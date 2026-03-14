{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "cnijfilter2" config.foxflake.system.applications) {

    services.printing.drivers = with pkgs; [ cnijfilter2 ];

  };

}
