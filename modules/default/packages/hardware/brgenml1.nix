{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "brgenml1" config.foxflake.system.applications) {

    services.printing.drivers = with pkgs; [ brgenml1lpr brgenml1cupswrapper ];

  };

}
