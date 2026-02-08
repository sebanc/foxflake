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
      services."nixos-upgrade".unitConfig.OnFailure = [ "nixos-upgrade-failure-notification.service" ];
      services."nixos-upgrade-failure-notification" = {
        description = "Send a desktop notification to wheel group users on upgrade failure";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.writeShellScriptBin "nixos-upgrade-failure-notification" ''
            #!${pkgs.bash}
            WHEEL_USERS=$(${pkgs.gnugrep}/bin/grep '^wheel:' /etc/group | ${pkgs.coreutils}/bin/cut -d: -f4 | ${pkgs.coreutils}/bin/tr ',' ' ')
            for user in $WHEEL_USERS; do
              USER_ID=$(${pkgs.coreutils}/bin/id -u "$user")
              BUS_ADDRESS="/run/user/$USER_ID/bus"
              if [ -S "$BUS_ADDRESS" ]; then
                ${pkgs.sudo}/bin/sudo -u "$user" DBUS_SESSION_BUS_ADDRESS="unix:path=$BUS_ADDRESS" ${pkgs.libnotify}/bin/notify-send --urgency=critical --icon="foxflake-red-icon" "System Update Failed" "The NixOS upgrade service failed. Check 'journalctl -u nixos-upgrade' for issues related to your custom NixOS configuration."
              fi
            done
          ''}/bin/nixos-upgrade-failure-notification";
        };
        restartIfChanged = false;
      };
      services."update-system-flatpaks" = {
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
      user.services."update-user-flatpaks" = {
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
