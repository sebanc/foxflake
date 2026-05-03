{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "1password" config.foxflake.system.applications) {

    programs._1password-gui = {
      enable = mkDefault true;
      package = mkDefault pkgs.stable._1password-gui;
    };

  };

}
