{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "virtualbox" config.foxflake.system.applications) {

    virtualisation.virtualbox.host = {
      enable = mkDefault true;
      enableExtensionPack = mkDefault true;
    };

  };

}
