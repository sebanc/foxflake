{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "samsunguld" config.foxflake.system.applications) {

    services.printing.drivers = with pkgs; [ samsung-unified-linux-driver ];

  };

}
