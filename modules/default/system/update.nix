{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  options.foxflake.autoUpgrade = mkOption {
    description = "Enable FoxFlake automatic updates.";
    type = types.bool;
    default = true;
  };

  config = mkIf config.foxflake.autoUpgrade {

    system.autoUpgrade = {
      enable = mkDefault true;
      dates = mkDefault "daily";
      operation = mkDefault "boot";
      allowReboot = mkDefault false;
      flake = "/etc/nixos#foxflake";
      flags = [ "--update-input" "foxflake" "--commit-lock-file" ];
    };

    systemd = {
      services.update-system-flatpaks = {
        description = "Update system flatpaks";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeScriptBin "update-system-flatpaks" ''
            #!${pkgs.bash}
            if ${pkgs.curl}/bin/curl -L https://github.com/sebanc/foxflake > /dev/null 2>&1; then
              ${pkgs.flatpak}/bin/flatpak update --assumeyes --noninteractive --system
            fi
          '';
        };
        wantedBy = [ "multi-user.target" ];
        startAt = "daily";
      };
      user.services.update-user-flatpaks = {
        description = "Update user flatpaks";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeScriptBin "update-user-flatpaks" ''
            #!${pkgs.bash}
            if ${pkgs.curl}/bin/curl -L https://github.com/sebanc/foxflake > /dev/null 2>&1; then
              ${pkgs.flatpak}/bin/flatpak update --assumeyes --noninteractive
            fi
          '';
        };
        wantedBy = [ "default.target" ];
        startAt = "daily";
      };
    };

  };

}
