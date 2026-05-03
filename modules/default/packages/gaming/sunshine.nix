{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "sunshine" config.foxflake.system.applications) {

    services.sunshine = {
      enable = mkDefault true;
      package = mkDefault pkgs.stable.sunshine;
      autoStart = mkDefault false;
      openFirewall = mkDefault true;
      capSysAdmin = mkDefault true;
    };

  };

}
