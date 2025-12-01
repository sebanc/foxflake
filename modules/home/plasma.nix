{ lib, pkgs, osConfig, ... }:
with lib;

{

  config = mkIf (osConfig.foxflake.environment.type == "plasma") {

    programs.plasma = {
      enable = mkDefault true;
      kscreenlocker.appearance.wallpaper = mkDefault osConfig.foxflake.customization.environment.wallpaper;
      workspace = {
        cursor.theme = mkDefault osConfig.foxflake.customization.environment.cursor-theme;
        iconTheme = mkDefault osConfig.foxflake.customization.environment.icon-theme;
        windowDecorations.theme = osConfig.foxflake.customization.environment.theme;
        wallpaper = mkDefault osConfig.foxflake.customization.environment.wallpaper;
      };
      panels = mkDefault [
        {
          widgets = [
            {
              name = "org.kde.plasma.kickoff";
              config = {
                General = {
                  icon = mkDefault osConfig.foxflake.customization.environment.launcher-icon;
                };
              };
            }
            {
              name = "org.kde.plasma.icontasks";
            }
            "org.kde.plasma.marginsseparator"
            "org.kde.plasma.systemtray"
            "org.kde.plasma.digitalclock"
            "org.kde.plasma.showdesktop"
          ];
        }
      ];
      session.sessionRestore.restoreOpenApplicationsOnLogin = mkDefault "whenSessionWasManuallySaved";
    };
      session.sessionRestore.restoreOpenApplicationsOnLogin = mkDefault "whenSessionWasManuallySaved";
    };

    home.file = {
      ".config/kwalletrc" = {
        text = ''
          [Wallet]
          Enabled=false
        '';
        executable = false;
        enable = if osConfig.foxflake.environment.autologin then
          true
        else
          false;
      };
    };

  };

}
