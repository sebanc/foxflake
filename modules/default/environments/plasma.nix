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
      desktopManager.plasma6.enable = mkDefault true;
      displayManager = {
        sddm = {
          enable = mkDefault true;
          theme = mkDefault "breeze";
        };
        defaultSession = mkDefault "plasma";
      };
    };

    xdg.portal = {
      enable = mkDefault true;
      extraPortals = mkDefault [ pkgs.kdePackages.xdg-desktop-portal-kde ];
      xdgOpenUsePortal = mkDefault true;
    };

    environment = {
      etc."xdg/baloofilerc" = {
        mode = "0644";
        text = ''
          [Basic Settings]
          Indexing-Enabled=false
        '';
      };
      plasma6.excludePackages = with pkgs; [
        kdePackages.plasma-browser-integration
        kdePackages.oxygen
      ];
      systemPackages = [
        pkgs.unstable.tela-circle-icon-theme
        pkgs.kdePackages.qtwebengine
        (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
          [General]
          background="${config.foxflake.customization.environment.wallpaper}"
        '')
      ];
    };
    programs = {
      kdeconnect.enable = mkDefault true;
      partition-manager.enable = mkDefault true;
    };

    systemd.user.services = {
      plasma-defaults = {
        description = "Apply plasma global defaults and fix icons path";
        before = [ "plasma-plasmashell.service" ];
        wantedBy = [ "plasma-core.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.writeShellScriptBin "plasma-defaults" ''
            #!${pkgs.bash}

            if [ -f ''${HOME}/.config/plasma-org.kde.plasma.desktop-appletsrc ]; then
              ${pkgs.gnused}/bin/sed -i 's/file:\/\/\/nix\/store\/[^\/]*\/share\/applications\//applications:/gi' ''${HOME}/.config/plasma-org.kde.plasma.desktop-appletsrc
            fi

            if [ ! -f "''${HOME}/.config/plasmarc" ]; then
              cat >"''${HOME}/.config/kdeglobals" <<KDEGLOBALS
            [Icons]
            Theme=${config.foxflake.customization.environment.icon-theme}
            KDEGLOBALS
              cat >"''${HOME}/.config/kscreenlockerrc" <<KSCREENLOCKERRC
            [Greeter]
            WallpaperPlugin=org.kde.image
            
            [Greeter][Wallpaper][org.kde.image][General]
            Image=${config.foxflake.customization.environment.wallpaper}
            KSCREENLOCKERRC
              cat >"''${HOME}/.config/kcminputrc" <<KCMINPUTRC
            [Mouse]
            cursorTheme=${config.foxflake.customization.environment.cursor-theme}
            KCMINPUTRC
              cat >"''${HOME}/.config/ksmserverrc" <<KSMSERVERRC
            [General]
            loginMode=restoreSavedSession
            KSMSERVERRC
              if [ "${toString config.foxflake.environment.autologin}" == "1" ]; then
                cat >"''${HOME}/.config/kwalletrc" <<KWALLETRC
            [Wallet]
            Enabled=false
            KWALLETRC
              fi
            fi
          ''}/bin/plasma-defaults";
        };
        restartIfChanged = false;
      };
      plasma-theme = {
        description = "Apply plasma theme";
        after = [ "plasma-plasmashell.service" ];
        before = [ "plasma-core.target" ];
        wantedBy = [ "plasma-core.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.writeShellScriptBin "plasma-theme" ''
            #!${pkgs.bash}

            if [ ! -f "''${HOME}/.config/plasmarc" ]; then
              ${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-desktoptheme ${config.foxflake.customization.environment.theme}
              ${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-wallpaperimage -f stretch ${config.foxflake.customization.environment.wallpaper}
              cat >"''${HOME}/.config/plasmarc" <<PLASMARC
            [Theme]
            name=${config.foxflake.customization.environment.theme}
            
            [Wallpapers]
            usersWallpapers=${config.foxflake.customization.environment.wallpaper}
            PLASMARC
            fi
          ''}/bin/plasma-theme";
        };
        restartIfChanged = false;
      };
    };

  };

}
