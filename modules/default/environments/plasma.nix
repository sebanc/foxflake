{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (config.foxflake.environment.enable && config.foxflake.environment.type == "plasma") {
    services = {
      displayManager = {
        defaultSession = mkDefault "plasma";
        sddm = {
          enable = mkDefault true;
          theme = mkDefault "breeze";
        };
      };
      desktopManager.plasma6.enable = mkDefault true;
    };

    xdg.portal = {
      enable = mkDefault true;
      extraPortals = mkDefault [ pkgs.kdePackages.xdg-desktop-portal-kde ];
      xdgOpenUsePortal = mkDefault true;
    };

    systemd.services."getty@tty1".enable = mkDefault false;
    systemd.services."autovt@tty1".enable = mkDefault false;

    environment = {
      plasma6.excludePackages = with pkgs; [
        kdePackages.plasma-browser-integration
        kdePackages.oxygen
      ];
      systemPackages = [
        pkgs.unstable.tela-circle-icon-theme

        (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
          [General]
          background="${config.foxflake.customization.environment.wallpaper}"
        '')
      ];
    };
    programs.kdeconnect.enable = mkDefault true;
  };

}
