{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "piper" config.foxflake.system.applications) {

    environment.systemPackages = with pkgs.stable; [ piper ];
    services.ratbagd = {
      enable = mkDefault true;
      package = mkDefault pkgs.stable.libratbag;
    };

  };

}
