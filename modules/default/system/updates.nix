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
      flags = [ "--recreate-lock-file" ];
      randomizedDelaySec = "45m";
    };

    systemd = {
      services.update-system-flatpaks = {
        description = "Update system flatpaks";
        conflicts = [ "shutdown.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.writeShellScriptBin "update-system-flatpaks" ''
            #!${pkgs.bash}
            if ${pkgs.curl}/bin/curl -L https://github.com/sebanc/foxflake > /dev/null 2>&1; then
              ${pkgs.flatpak}/bin/flatpak --system uninstall --unused --assumeyes --noninteractive
              ${pkgs.flatpak}/bin/flatpak --system update --assumeyes --noninteractive
              ${pkgs.flatpak}/bin/flatpak --system repair
            fi
          ''}/bin/update-system-flatpaks";
        };
        restartIfChanged = false;
      };
      timers."update-system-flatpaks" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "1m";
          OnCalendar = "daily";
          Unit = "update-system-flatpaks.service";
        };
      };
      user.services.update-user-flatpaks = {
        description = "Update user flatpaks";
        conflicts = [ "shutdown.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.writeShellScriptBin "update-user-flatpaks" ''
            #!${pkgs.bash}
            if ${pkgs.curl}/bin/curl -L https://github.com/sebanc/foxflake > /dev/null 2>&1; then
              ${pkgs.flatpak}/bin/flatpak --user uninstall --unused --assumeyes --noninteractive
              ${pkgs.flatpak}/bin/flatpak --user update --assumeyes --noninteractive
              ${pkgs.flatpak}/bin/flatpak --user repair
            fi
          ''}/bin/update-user-flatpaks";
        };
        restartIfChanged = false;
      };
      user.timers."update-user-flatpaks" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "1m";
          OnCalendar = "daily";
          Unit = "update-user-flatpaks.service";
        };
      };
    };

  };

}
