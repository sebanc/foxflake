{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "escpr" config.foxflake.system.applications) {

    services.printing.drivers = with pkgs; [ epson-escpr epson-escpr2 ];

  };

}
