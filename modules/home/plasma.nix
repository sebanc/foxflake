{ lib, pkgs, osConfig, ... }:
with lib;

{
  config = mkIf (osConfig.foxflake.environment.type == "plasma") {

    programs.plasma = {
      enable = mkDefault true;
      kscreenlocker.appearance.wallpaper = mkDefault "${osConfig.foxflake.customization.wallpaper}";
      workspace = {
        iconTheme = mkDefault "Tela-circle";
        wallpaper = mkDefault "${osConfig.foxflake.customization.wallpaper}";
      };
      panels = mkDefault [
        {
          widgets = [
            {
              name = "org.kde.plasma.kickoff";
              config = {
                General = {
                  icon = "foxflake-default-icon";
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
