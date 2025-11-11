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
