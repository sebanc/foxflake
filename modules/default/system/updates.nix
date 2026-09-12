{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  options.foxflake.autoUpgrade = mkOption {
    type = types.bool;
    default = true;
    description = "Enable FoxFlake automatic updates.";
  };

  config = mkIf (config.foxflake.autoUpgrade) {

    nixpkgs.overlays = [
      (final: prev: {
        foxflake-autoupdate-tests = prev.stdenv.mkDerivation rec {
          name = "foxflake-autoupdate-tests";
          buildCommand = let script = prev.writeShellApplication {
            name = name;
            runtimeInputs = with final; [ curl gawk gnused networkmanager procps ];
            bashOptions = [ "errexit" "pipefail" ];
            text = ''
              #!${pkgs.bash}

              cpu_usage="$(top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\([0-9.]*\)%* id/\1/' | awk '{print (100 - $1) * 10 }')"
              if [ ! -z "''${cpu_usage}" ] && [ "''${cpu_usage}" -gt 100 ]; then
                echo "Average CPU workload is KO (usage is \"''${cpu_usage}\": above 100 limit), skipping update..."
                exit 1
              else
                echo "Average CPU workload is OK (usage is \"''${cpu_usage}\": below 100 limit), continuing..."
              fi

              network_available="$(nmcli networking connectivity)"
              if [ ! -z "''${network_available}" ] && [ "''${network_available}" != "full" ]; then
                echo "Internet connection available test is KO (\"''${network_available}\") according to NetworkManager, skipping update..."
                exit 1
              else
                echo "Internet connection available test is OK (\"''${network_available}\") according to NetworkManager, continuing..."
              fi

              network_metered="$(nmcli -t -f GENERAL.METERED dev show "$(nmcli -t -f DEVICE dev | head -n 1)" | cut -d':' -f2)"
              if [ ! -z "''${network_metered}" ] && { [ "''${network_metered}" == "yes" ] || [ "''${network_metered}" == "yes (guessed)" ]; }; then
                echo "Internet connection metered test is KO (\"''${network_metered}\") according to NetworkManager, skipping update..."
                exit 1
              else
                echo "Internet connection metered test is OK (\"''${network_metered}\") according to NetworkManager, continuing..."
              fi

              network_speed="$(curl -fsS -m 5 -r 0-10048576 -w '%{speed_download}' -o /dev/null --url "https://cache.nixos.org" 2> /dev/null)"
              if [ ! -z "''${network_speed}" ] && [ "''${network_speed}" -lt 5000 ]; then
                echo "Internet connection to https://cache.nixos.org is KO (\"''${network_speed}\": below 5000), skipping update..."
                exit 1
              else
                echo "Internet connection to https://cache.nixos.org is OK (\"''${network_speed}\": above 5000), continuing..."
              fi

              exit 0
            '';
          };
          in ''
            mkdir -p $out/bin
            cp ${script}/bin/${name} $out/bin
          '';
        };
      })
    ];

    system.autoUpgrade = {
      enable = mkDefault true;
      persistent = mkDefault true;
      upgrade = mkDefault false;
      operation = mkDefault "boot";
      allowReboot = mkDefault false;
      flake = "/etc/nixos#foxflake";
      flags = [ "--show-trace" ];
      dates = mkDefault "daily";
      randomizedDelaySec = "1h";
    };

    systemd = {
      services."nixos-upgrade" = {
        path = with pkgs; [ foxflake-autoupdate-tests gawk nix ];
        preStart = ''
          #!${pkgs.bash}
          if [ "$(readlink -f /run/current-system)" != "$(readlink "$(stat -c "%Y %n" /nix/var/nix/profiles/system-*-link | awk -v bt="$(stat -c %Y /run/booted-system)" '$1 < bt' | sort -n | tail -n1 | awk '{print $2}')")" ]; then
            echo "Auto-updates are disabled as booted generation is not the latest..."
            exit 1
          fi
          while ! foxflake-autoupdate-tests; do
            sleep 3600
          done
          nix flake update --flake /etc/nixos
        '';
        serviceConfig = {
          TimeoutStartSec = "infinity";
          CPUQuota = "25%";
        };
        unitConfig.OnFailure = [ "nixos-upgrade-failure-notification.service" ];
      };
      services."nixos-upgrade-failure-notification" = {
        description = "Send a desktop notification to wheel group users on upgrade failure";
        path = with pkgs; [ gnugrep libnotify ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.writeShellScriptBin "nixos-upgrade-failure-notification" ''
            #!${pkgs.bash}
            WHEEL_USERS=$(grep '^wheel:' /etc/group | cut -d: -f4 | tr ',' ' ')
            for user in $WHEEL_USERS; do
              USER_ID=$(id -u "$user")
              BUS_ADDRESS="/run/user/$USER_ID/bus"
              if [ -S "$BUS_ADDRESS" ] && ([ "${config.foxflake.environment.type}" == "plasma" ] || [ "${config.foxflake.environment.type}" == "steam" ]); then
                /run/wrappers/bin/sudo -u "$user" DBUS_SESSION_BUS_ADDRESS="unix:path=$BUS_ADDRESS" notify-send --urgency=critical --hint=string:desktop-entry:foxflake-update --icon="foxflake-red-icon" "System Update Failed" "The NixOS upgrade service failed. Check 'journalctl -u nixos-upgrade' for issues related to your custom NixOS configuration."
              elif [ -S "$BUS_ADDRESS" ]; then
                /run/wrappers/bin/sudo -u "$user" DBUS_SESSION_BUS_ADDRESS="unix:path=$BUS_ADDRESS" notify-send --urgency=critical --icon="foxflake-red-icon" "System Update Failed" "The NixOS upgrade service failed. Check 'journalctl -u nixos-upgrade' for issues related to your custom NixOS configuration."
              fi
            done
          ''}/bin/nixos-upgrade-failure-notification";
        };
        restartIfChanged = false;
      };
      services."update-system-flatpaks" = {
        description = "Update system flatpaks";
        conflicts = [ "shutdown.target" ];
        path = with pkgs; [ curl flatpak foxflake-autoupdate-tests ];
        preStart = ''
          #!${pkgs.bash}
          while ! foxflake-autoupdate-tests; do
            sleep 3600
          done
        '';
        serviceConfig = {
          Type = "oneshot";
          TimeoutStartSec = "infinity";
          CPUQuota = "25%";
          ExecStart = "${pkgs.writeShellScriptBin "update-system-flatpaks" ''
            #!${pkgs.bash}
            if curl -L https://github.com/sebanc/foxflake > /dev/null 2>&1; then
              flatpak --system uninstall --unused --assumeyes --noninteractive || flatpak --system repair
              flatpak --system update --assumeyes --noninteractive || flatpak --system repair
            fi
          ''}/bin/update-system-flatpaks";
        };
        restartIfChanged = false;
      };
      timers."update-system-flatpaks" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          randomizedDelaySec = "1h";
          Unit = "update-system-flatpaks.service";
        };
      };
      user.services."update-user-flatpaks" = {
        description = "Update user flatpaks";
        conflicts = [ "shutdown.target" ];
        path = with pkgs; [ curl flatpak foxflake-autoupdate-tests ];
        preStart = ''
          #!${pkgs.bash}
          while ! ${pkgs.foxflake-autoupdate-tests}/bin/foxflake-autoupdate-tests; do
            sleep 3600
          done
        '';
        serviceConfig = {
          Type = "oneshot";
          TimeoutStartSec = "infinity";
          CPUQuota = "25%";
          ExecStart = "${pkgs.writeShellScriptBin "update-user-flatpaks" ''
            #!${pkgs.bash}
            if curl -L https://github.com/sebanc/foxflake > /dev/null 2>&1; then
              flatpak --user uninstall --unused --assumeyes --noninteractive || flatpak --user repair
              flatpak --user update --assumeyes --noninteractive || flatpak --user repair
            fi
          ''}/bin/update-user-flatpaks";
        };
        restartIfChanged = false;
      };
      user.timers."update-user-flatpaks" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          randomizedDelaySec = "1h";
          Unit = "update-user-flatpaks.service";
        };
      };
    };

  };

}
