{ lib, pkgs, osConfig, ... }:
with lib;

{

  config = mkIf (osConfig.foxflake.environment.type == "plasma") {

    programs.plasma = {
      enable = mkDefault true;
      kscreenlocker.appearance.wallpaper = mkDefault "${osConfig.foxflake.customization.environment.wallpaper}";
      workspace = {
        cursorType.theme = mkDefault "${osConfig.foxflake.customization.environment.cursor-theme}";
        iconTheme = mkDefault "${osConfig.foxflake.customization.environment.icon-theme}";
        windowDecorations.theme = "${osConfig.foxflake.customization.environment.theme}";
        wallpaper = mkDefault "${osConfig.foxflake.customization.environment.wallpaper}";
      };
      panels = mkDefault [
        {
          widgets = [
            {
              name = "org.kde.plasma.kickoff";
              config = {
                General = {
                  icon = "${osConfig.foxflake.customization.environment.launcher-icon}";
                };
              };
            }
            {
              name = "org.kde.plasma.icontasks";
              config = {
                General = {
                  launchers = if builtins.elem "standard" osConfig.foxflake.system.bundles then [
                    "applications:firefox.desktop"
                    "applications:org.kde.dolphin.desktop"
                    "applications:org.kde.discover.desktop"
                  ] else [
                    "applications:org.kde.dolphin.desktop"
                    "applications:org.kde.discover.desktop"
                  ];
                };
              };
            }
            "org.kde.plasma.marginsseparator"
            "org.kde.plasma.systemtray"
            "org.kde.plasma.digitalclock"
            "org.kde.plasma.showdesktop"
          ];
        }
      ];
    };

  };

}
