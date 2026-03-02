{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = {

    environment.systemPackages = with pkgs; [ foxflake-update ];

    security.sudo = {
      extraRules = [{
        groups = [ "wheel" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/foxflake-update";
            options = [ "NOPASSWD" ];
          }
        ];
      }];
    };

  };

}
