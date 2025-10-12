{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (config.foxflake.environment.enable && config.foxflake.environment.type == "gnome") {

    services = {
      desktopManager.gnome.enable = mkDefault true;
      displayManager.gdm.enable = mkDefault true;
      displayManager.defaultSession = mkDefault "gnome";
      power-profiles-daemon.enable = mkDefault true;
      udev.packages = mkDefault [ pkgs.gnome-settings-daemon ];
    };

    xdg.portal = {
      enable = mkDefault true;
      extraPortals = mkDefault [ pkgs.xdg-desktop-portal-gnome ];
      xdgOpenUsePortal = mkDefault true;
    };

    systemd.services."getty@tty1".enable = mkDefault false;
    systemd.services."autovt@tty1".enable = mkDefault false;

    programs.kdeconnect = {
      enable = mkDefault true;
      package = mkDefault pkgs.gnomeExtensions.gsconnect;
    };

    environment = {
      systemPackages = with pkgs; [
        gnome-themes-extra
        orchis-theme
        tela-circle-icon-theme
        gnome-tweaks
        gnomeExtensions.blur-my-shell
        gnomeExtensions.caffeine
        gnomeExtensions.gsconnect
        gnomeExtensions.appindicator
        gnomeExtensions.dash-to-dock
      ];

      gnome.excludePackages = with pkgs; [
        tali
        iagno
        hitori
        atomix
        yelp
        geary
        xterm
        totem
        epiphany
        packagekit
        gnome-tour
        gnome-contacts
        gnome-user-docs
        gnome-packagekit
        gnome-font-viewer
      ];
    };

    programs.dconf = {
      enable = mkDefault true;
      profiles.user.databases = [
        {
          settings = {
            "org/gnome/desktop/wm/preferences" = {
              button-layout = "appmenu:minimize,maximize,close";
              theme = "${config.foxflake.customization.environment.theme}";
              focus-mode = "click";
              visual-bell = false;
            };

            "org/gnome/desktop/interface" = {
              cursor-theme = "${config.foxflake.customization.environment.cursor-theme}";
              gtk-theme = "${config.foxflake.customization.environment.theme}";
              icon-theme = "${config.foxflake.customization.environment.icon-theme}";
            };

            "org/gnome/desktop/background" = {
              color-shading-type = "solid";
              picture-options = "zoom";
              picture-uri = "file://${config.foxflake.customization.environment.wallpaper}";
              picture-uri-dark = "file://${config.foxflake.customization.environment.wallpaper}";
            };

            "org/gnome/desktop/peripherals/touchpad" = {
              click-method = "areas";
              tap-to-click = true;
              two-finger-scrolling-enabled = true;
            };

            "org/gnome/desktop/peripherals/keyboard" = {
              numlock-state = true;
            };

            "org/gnome/shell" = {
              disable-user-extensions = false;
              enabled-extensions = [
                "appindicatorsupport@rgcjonas.gmail.com"
                "blur-my-shell@aunetx"
                "caffeine@patapon.info"
                "dash-to-dock@micxgx.gmail.com"
                "gsconnect@andyholmes.github.io"
              ];
              favorite-apps = [
                "firefox.desktop"
                "org.gnome.Nautilus.desktop"
                "org.gnome.Software.desktop"
              ];
            };

            "org/gnome/shell/extensions/dash-to-dock" = {
              background-opacity = 0.0;
              dock-position = "BOTTOM";
              running-indicator-style = "DOTS";
              isolate-monitor = false;
              multi-monitor = true;
              show-mounts-network = true;
              always-center-icons = true;
              custom-theme-shrink = true;
            };

            "org/gnome/mutter" = {
              check-alive-timeout = gvariant.mkUint32 30000;
              dynamic-workspaces = true;
              edge-tiling = true;
            };
          };
        }
      ];
    };

  };

}
