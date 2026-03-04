{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "discord" config.foxflake.system.applications) {

    environment.systemPackages = with pkgs; [ discord ];

    systemd.user.services."init-discord-settings" = {
      unitConfig = {
        Description = "Add SKIP_HOST_UPDATE by default to discord settings";
        ConditionPathExists = "!%h/.config/discord/settings.json";
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScriptBin "init-discord-settings" ''
          #!${pkgs.bash}
          mkdir -p $HOME/.config/discord
          echo -e '{\n  "SKIP_HOST_UPDATE": true\n}' > $HOME/.config/discord/settings.json
        ''}/bin/init-discord-settings";
      };
      wantedBy = [ "default.target" ];
      restartIfChanged = false;
    };

  };

}
