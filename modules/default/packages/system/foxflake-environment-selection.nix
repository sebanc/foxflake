{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf config.foxflake.environment.selection.enable {

    environment.systemPackages = with pkgs; [ foxflake-environment-selection zenity ];

    security.sudo = {
      extraRules = [{
        groups = [ "wheel" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/foxflake-environment-selection";
            options = [ "NOPASSWD" ];
          }
        ];
      }];
    };

  };

}
