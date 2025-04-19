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
      randomizedDelaySec = "1m";
    };

    systemd = {
      services.update-system-flatpaks = {
        description = "Update system flatpaks";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.writeShellScriptBin "update-system-flatpaks" ''
            #!${pkgs.bash}
            if ${pkgs.curl}/bin/curl -L https://github.com/sebanc/foxflake > /dev/null 2>&1; then
              ${pkgs.flatpak}/bin/flatpak update --assumeyes --noninteractive --system
            fi
          ''}/bin/update-system-flatpaks";
        };
        wantedBy = [ "multi-user.target" ];
        startAt = "daily";
        restartIfChanged = false;
        randomizedDelaySec = "1m";
      };
      user.services.update-user-flatpaks = {
        description = "Update user flatpaks";
        after = [ "network.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.writeShellScriptBin "update-user-flatpaks" ''
            #!${pkgs.bash}
            if ${pkgs.curl}/bin/curl -L https://github.com/sebanc/foxflake > /dev/null 2>&1; then
              ${pkgs.flatpak}/bin/flatpak update --assumeyes --noninteractive
            fi
          ''}/bin/update-user-flatpaks";
        };
        wantedBy = [ "default.target" ];
        startAt = "daily";
        restartIfChanged = false;
        randomizedDelaySec = "1m";
      };
    };

  };

}
