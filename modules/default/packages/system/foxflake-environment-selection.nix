{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  imports = [ ../../../../packages/foxflake-environment-selection ];

  options.foxflake.environment.selection = {
    enable = mkOption {
      description = "Enable environment and applications switching program";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (config.foxflake.environment.enable && config.foxflake.environment.selection.enable) {

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
