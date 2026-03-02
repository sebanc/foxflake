{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "digikam" config.foxflake.system.applications) {

    environment.systemPackages = with pkgs; [ digikam ];

  };

}
